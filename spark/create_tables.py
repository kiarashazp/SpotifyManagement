# create_tables.py
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Create Bronze Tables") \
    .enableHiveSupport() \
    .getOrCreate()

# Create bronze schema
spark.sql("CREATE SCHEMA IF NOT EXISTS bronze")

# Create tables
spark.sql("""
CREATE EXTERNAL TABLE IF NOT EXISTS bronze.auth_events
USING parquet
LOCATION 'hdfs://namenode:9000/user/bronze/auth_events'
""")

spark.sql("""
CREATE EXTERNAL TABLE IF NOT EXISTS bronze.listen_events
USING parquet
LOCATION 'hdfs://namenode:9000/user/bronze/listen_events'
""")

spark.sql("""
CREATE EXTERNAL TABLE IF NOT EXISTS bronze.page_view_events
USING parquet
LOCATION 'hdfs://namenode:9000/user/bronze/page_view_events'
""")

spark.sql("""
CREATE EXTERNAL TABLE IF NOT EXISTS bronze.status_change_events
USING parquet
LOCATION 'hdfs://namenode:9000/user/bronze/status_change_events'
""")

# Verify tables were created
tables = spark.sql("SHOW TABLES IN bronze").collect()
for table in tables:
    print(table)

spark.stop()
