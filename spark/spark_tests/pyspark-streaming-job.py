from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_json, expr, year, month, day, hour
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType, BooleanType, LongType
import requests
import json
import time

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


def fetch_schema_from_registry(topic):
    """
    Fetch the schema for a given topic from the Schema Registry.
    Returns a StructType object representing the schema.
    """
    try:
        # Fetch the latest schema for the topic
        response = requests.get(f"{schema_registry_url}/subjects/{topic}-value/versions/latest")
        response.raise_for_status()  # Raise an exception for HTTP errors
        schema_info = response.json()

        # Extract the schema string
        schema_str = schema_info["schema"]

        # Parse the schema string into a dictionary
        schema_dict = json.loads(schema_str)

        # Convert the schema dictionary to a Spark StructType
        fields = []
        for field in schema_dict["fields"]:
            field_type = field["type"]
            spark_type = {
                "string": StringType(),
                "int": IntegerType(),
                "long": LongType(),
                "double": DoubleType(),
                "boolean": BooleanType(),
            }.get(field_type)
            if not spark_type:
                raise ValueError(f"Unsupported field type: {field_type}")
            fields.append(StructField(field["name"], spark_type))

        return StructType(fields)

    except Exception as e:
        print(f"Error fetching schema for topic {topic}: {e}")
        raise


def process_stream(event_type, schema):
    """Process a Kafka stream for a specific event type and write it to HDFS"""

    print(f"Processing stream for {event_type}")

    # Read from Kafka
    df = (
        spark.readStream.format("kafka")
        .option("kafka.bootstrap.servers", kafka_bootstrap_servers)
        .option("subscribe", event_type)
        .option("startingOffsets", "earliest")
        .load()
    )

    # Parse JSON data
    parsed_df = (
        df.select(
            from_json(col("value").cast("string"), schema).alias("data"), "timestamp"
        )
        .select("data.*", "timestamp")
        .withColumn("processing_time", expr("current_timestamp()"))
    )

    # Add date partitioning columns if 'ts' exists
    if "ts" in [field.name for field in schema.fields]:
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
    try:
        # Fetch the schema for the topic
        schema = fetch_schema_from_registry(topic)

        # Start processing the stream
        active_streams.append(process_stream(topic, schema))
    except Exception as e:
        print(f"Skipping topic {topic} due to error: {e}")

# Wait for all streams to terminate (or run indefinitely)
try:
    for stream in active_streams:
        stream.awaitTermination()
except KeyboardInterrupt:
    print("Stopping streaming job...")
    for stream in active_streams:
        stream.stop()
    spark.stop()
