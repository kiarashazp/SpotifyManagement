from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_json, expr, year, month, day, hour
from pyspark.sql.types import (
    StructType,
    StructField,
    StringType,
    IntegerType,
    DoubleType,
    BooleanType,
    LongType,
)
import time

# Create Spark session with Kafka packages
spark = (
    SparkSession.builder.appName("KafkaToHDFS_Bronze")
    .config("spark.sql.session.timeZone", "UTC")
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0")
    .getOrCreate()
)

# Define schemas for different event types
listen_events_schema = StructType(
    [
        StructField("artist", StringType()),
        StructField("auth", StringType()),
        StructField("city", StringType()),
        StructField("duration", DoubleType()),
        StructField("firstName", StringType()),
        StructField("gender", StringType()),
        StructField("itemInSession", IntegerType()),
        StructField("lastName", StringType()),
        StructField("lat", DoubleType()),
        StructField("level", StringType()),
        StructField("lon", DoubleType()),
        StructField("registration", LongType()),
        StructField("sessionId", IntegerType()),
        StructField("song", StringType()),
        StructField("state", StringType()),
        StructField("success", BooleanType()),
        StructField("ts", LongType()),
        StructField("userAgent", StringType()),
        StructField("userId", IntegerType()),
        StructField("zip", StringType()),
    ]
)

page_view_events_schema = StructType(
    [
        StructField("artist", StringType()),
        StructField("auth", StringType()),
        StructField("city", StringType()),
        StructField("duration", DoubleType()),
        StructField("firstName", StringType()),
        StructField("gender", StringType()),
        StructField("itemInSession", IntegerType()),
        StructField("lastName", StringType()),
        StructField("lat", DoubleType()),
        StructField("level", StringType()),
        StructField("lon", DoubleType()),
        StructField("method", StringType()),
        StructField("page", StringType()),
        StructField("registration", LongType()),
        StructField("sessionId", IntegerType()),
        StructField("song", StringType()),
        StructField("state", StringType()),
        StructField("status", IntegerType()),
        StructField("success", BooleanType()),
        StructField("ts", LongType()),
        StructField("userAgent", StringType()),
        StructField("userId", IntegerType()),
        StructField("zip", StringType()),
    ]
)

auth_events_schema = StructType(
    [
        StructField("city", StringType()),
        StructField("firstName", StringType()),
        StructField("gender", StringType()),
        StructField("itemInSession", IntegerType()),
        StructField("lastName", StringType()),
        StructField("lat", DoubleType()),
        StructField("level", StringType()),
        StructField("lon", DoubleType()),
        StructField("registration", LongType()),
        StructField("sessionId", IntegerType()),
        StructField("state", StringType()),
        StructField("success", BooleanType()),
        StructField("ts", LongType()),
        StructField("userAgent", StringType()),
        StructField("userId", IntegerType()),
        StructField("zip", StringType()),
    ]
)

status_change_events_schema = StructType(
    [
        StructField("artist", StringType()),
        StructField("auth", StringType()),
        StructField("city", StringType()),
        StructField("duration", DoubleType()),
        StructField("firstName", StringType()),
        StructField("gender", StringType()),
        StructField("itemInSession", IntegerType()),
        StructField("lastName", StringType()),
        StructField("lat", DoubleType()),
        StructField("level", StringType()),
        StructField("lon", DoubleType()),
        StructField("method", StringType()),
        StructField("page", StringType()),
        StructField("registration", LongType()),
        StructField("sessionId", IntegerType()),
        StructField("song", StringType()),
        StructField("state", StringType()),
        StructField("status", IntegerType()),
        StructField("success", BooleanType()),
        StructField("ts", LongType()),
        StructField("userAgent", StringType()),
        StructField("userId", IntegerType()),
        StructField("zip", StringType()),
    ]
)

# Map event types to schemas
event_schemas = {
    "listen_events": listen_events_schema,
    "page_view_events": page_view_events_schema,
    "auth_events": auth_events_schema,
    "status_change_events": status_change_events_schema,
}

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
    if topic in event_schemas:
        active_streams.append(process_stream(topic, event_schemas[topic]))

# Wait for all streams to terminate (or run indefinitely)
try:
    for stream in active_streams:
        stream.awaitTermination()
except KeyboardInterrupt:
    print("Stopping streaming job...")
    for stream in active_streams:
        stream.stop()
    spark.stop()
