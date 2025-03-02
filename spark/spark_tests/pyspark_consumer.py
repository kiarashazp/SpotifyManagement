from pyspark.sql import SparkSession
from pyspark.sql.functions import col

# Initialize Spark session
spark = SparkSession.builder \
    .appName("KafkaConsumer") \
    .master("spark://spark:7077") \
    .getOrCreate()

# Define Kafka topics and bootstrap servers
kafka_bootstrap_servers = "broker:29092"
topics = ["auth_events", "listen_events", "page_view_events", "status_change_events"]

# Read messages from Kafka
for topic in topics:
    df = spark.readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", kafka_bootstrap_servers) \
        .option("subscribe", topic) \
        .option("startingOffsets", "earliest") \
        .load()

    # Select the value from Kafka message
    kafka_df = df.selectExpr("CAST(value AS STRING) as message")

    # Process and display messages
    query = kafka_df \
        .writeStream \
        .outputMode("append") \
        .format("console") \
        .start()

    # Wait for the termination of the stream
    query.awaitTermination()

# Stop the Spark session
spark.stop()
