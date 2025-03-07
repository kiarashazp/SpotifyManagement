from pyspark.sql import SparkSession

# Create Spark session
spark = (
    SparkSession.builder.appName("Register_Bronze_Tables")
    .config("spark.sql.session.timeZone", "UTC")
    .getOrCreate()
)

# Create bronze schema if it doesn't exist
spark.sql("CREATE SCHEMA IF NOT EXISTS bronze")

# List of event types
event_types = [
    "listen_events",
    "page_view_events",
    "auth_events",
    "status_change_events"
]

# Base path in HDFS
bronze_base_path = "hdfs://namenode:9000/user/bronze"

# Register each event type as an external table
for event_type in event_types:
    # Path to the partitioned data
    hdfs_path = f"{bronze_base_path}/{event_type}"
    
    # Register the external table
    spark.sql(f"""
    CREATE EXTERNAL TABLE IF NOT EXISTS bronze.{event_type}
    USING PARQUET
    LOCATION '{hdfs_path}'
    """)
    
    print(f"Registered external table: bronze.{event_type}")

# Verify tables were created
tables = spark.sql("SHOW TABLES IN bronze").collect()
print("\nTables in bronze schema:")
for table in tables:
    print(f"- {table.tableName}")

spark.stop()
