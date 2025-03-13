from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_json, expr, year, month, day, hour
from pyspark.sql.types import StructType
import requests
import json

# Create Spark session with Kafka packages
spark = (
    SparkSession.builder.appName("KafkaToHDFS_Bronze")
    .config("spark.sql.session.timeZone", "UTC")
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0")
    .getOrCreate()
)

# Schema Registry URL
schema_registry_url = "http://schema-registry:8085"

# HDFS paths
bronze_base_path = "hdfs://namenode:9000/user/bronze"

# Kafka connection parameters
kafka_bootstrap_servers = "broker:29092"
kafka_topics = [
    "listen_events",
    "page_view_events",
    "auth_events",
    "status_change_events",
]


def fetch_schema_from_registry(subject):
    """
    Fetch the latest JSON schema for a given subject from the Schema Registry.
    """
    url = f"{schema_registry_url}/subjects/{subject}-value/versions/latest"
    response = requests.get(url)
    if response.status_code == 200:
        schema_data = response.json()
        schema_str = schema_data["schema"]
        return schema_str
    else:
        raise Exception(f"Failed to fetch schema for subject {subject}. Status code: {response.status_code}")


def json_schema_to_spark_schema(schema_str):
    """
    Convert JSON schema (as string) to Spark StructType schema.
    """
    schema_dict = json.loads(schema_str)
    return StructType.fromJson(schema_dict)


def process_stream(event_type):
    """Process a Kafka stream for a specific event type and write it to HDFS"""

    print(f"Processing stream for {event_type}")

    # Fetch JSON schema from Schema Registry
    schema_str = fetch_schema_from_registry(event_type)
    schema = json_schema_to_spark_schema(schema_str)

    # Read from Kafka
    df = (
        spark.readStream.format("kafka")
        .option("kafka.bootstrap.servers", kafka_bootstrap_servers)
        .option("subscribe", event_type)
        .option("startingOffsets", "earliest")
        .load()
    )

    # Parse JSON data using the fetched schema
    parsed_df = (
        df.select(
            from_json(col("value").cast("string"), schema).alias("data"), "timestamp"
        )
        .select("data.*", "timestamp")
        .withColumn("processing_time", expr("current_timestamp()"))
    )

    # Add date partitioning columns if 'ts' exists
    if "ts" in schema.fieldNames():
        parsed_df = (
            parsed_df.withColumn(
                "event_date", expr("from_unixtime(ts/1000, 'yyyy-MM-dd')")
            )
            .withColumn("year", year(expr("from_unixtime(ts/1000)")))
            .withColumn("month", month(expr("from_unixtime(ts/1000)")))
            .withColumn("day", day(expr("from_unixtime(ts/1000)")))
            .withColumn("hour", hour(expr("from_unixtime(ts/1000)")))
        )

    # Write to HDFS in Parquet format
    query = (
        parsed_df.writeStream.format("parquet")
        .option("path", f"{bronze_base_path}/{event_type}")
        .option("checkpointLocation", f"{bronze_base_path}/{event_type}/_checkpoints")
        .partitionBy("year", "month", "day")
        .outputMode("append")
        .start()
    )

    return query


# Process each event type
active_streams = []
for topic in kafka_topics:
    active_streams.append(process_stream(topic))

# Wait for all streams to terminate (or run indefinitely)
try:
    for stream in active_streams:
        stream.awaitTermination()
except KeyboardInterrupt:
    print("Stopping streaming job...")
    for stream in active_streams:
        stream.stop()
    spark.stop()
