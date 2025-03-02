from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StructField, StringType

# 1) Define a schema for parsing JSON messages
json_schema = StructType(
    [
        StructField("city", StringType(), True),
        StructField("zip", StringType(), True),
        StructField("state", StringType(), True),
        # Add any other fields in your JSON
        StructField("event_time", StringType(), True),
        StructField("user_id", StringType(), True),
        StructField("action", StringType(), True),
    ]
)


def main():
    # 2) Initialize Spark session
    spark = (
        SparkSession.builder.appName("KafkaToHDFSPartitioned")
        .master("spark://spark:7077")  # Adjust if needed
        .getOrCreate()
    )

    # Kafka config
    kafka_bootstrap_servers = "broker:29092"
    topics = [
        "auth_events",
        "listen_events",
        "page_view_events",
        "status_change_events",
    ]

    # We'll keep queries so we can await them later
    queries = []

    # 3) Loop over each Kafka topic
    for topic in topics:
        # Read stream from Kafka
        df = (
            spark.readStream.format("kafka")
            .option("kafka.bootstrap.servers", kafka_bootstrap_servers)
            .option("subscribe", topic)
            .option("startingOffsets", "earliest")
            .load()
        )

        # Convert the binary "value" column to STRING
        kafka_df = df.selectExpr("CAST(value AS STRING) as raw_message")

        # 4) Parse the JSON message into columns using our schema
        parsed_df = kafka_df.select(
            from_json(col("raw_message"), json_schema).alias("data")
        )

        # 5) Flatten the nested "data" struct
        #    Now we have columns: city, zip, state, event_time, etc.
        final_df = parsed_df.select(
            col("data.city").alias("city"),
            col("data.zip").alias("zip"),
            col("data.state").alias("state"),
            col("data.event_time").alias("event_time"),
            col("data.user_id").alias("user_id"),
            col("data.action").alias("action"),
        )

        # Define output paths for each topic (unique path per topic)
        output_path = f"hdfs://namenode:9000/user/hive/warehouse/{topic}/"
        checkpoint_path = (
            f"hdfs://namenode:9000/user/hive/warehouse/checkpoints/{topic}/"
        )

        # 6) Write to Parquet, partitioned by city, zip, state
        query = (
            final_df.writeStream.format("parquet")
            .outputMode("append")
            .option("path", output_path)
            .option("checkpointLocation", checkpoint_path)
            .partitionBy("city", "zip", "state")
            .start()
        )

        queries.append(query)

    # 7) Wait for any (or all) streaming queries to terminate
    spark.streams.awaitAnyTermination()


if __name__ == "__main__":
    main()
