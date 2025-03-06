from pyspark.sql import SparkSession
import os
from pyspark.sql.functions import col

# Create Spark session
spark = (
    SparkSession.builder.appName("HDFSToClickHouse")
    .config("spark.sql.session.timeZone", "UTC")
    .getOrCreate()
)

# HDFS paths for gold layer reports
hdfs_base_path = "hdfs://namenode:9000/user/gold"

# ClickHouse connection properties
clickhouse_host = "clickhouse-server"
clickhouse_port = 8123
clickhouse_database = "spotify"
clickhouse_user = "default"
clickhouse_password = ""
clickhouse_jdbc_url = (
    f"jdbc:clickhouse://{clickhouse_host}:{clickhouse_port}/{clickhouse_database}"
)

# ClickHouse JDBC Driver properties
jdbc_driver = "ru.yandex.clickhouse.ClickHouseDriver"
clickhouse_properties = {
    "driver": jdbc_driver,
    "user": clickhouse_user,
    "password": clickhouse_password,
}

# List of gold reports to transfer
report_tables = [
    "report_daily_user_song_count",
    "report_weekday_avg_listening_time",
    "report_city_active_users",
    "report_top_songs",
    "report_free_vs_paid_users",
    "report_avg_session_duration",
    "report_conversion_rate",
    "report_error_status_codes",
    "report_skipping_sessions",
    "report_new_user_behavior",
]


def transfer_table_to_clickhouse(table_name):
    """
    Transfer a specific table from HDFS to ClickHouse
    """
    print(f"Transferring {table_name} to ClickHouse...")

    # Read from HDFS
    hdfs_path = f"{hdfs_base_path}/{table_name}"
    df = spark.read.parquet(hdfs_path)

    # Write to ClickHouse using JDBC
    df.write.format("jdbc").option("url", clickhouse_jdbc_url).option(
        "dbtable", table_name
    ).option("driver", jdbc_driver).option("user", clickhouse_user).option(
        "password", clickhouse_password
    ).option(
        "truncate", "true"
    ).mode(
        "overwrite"
    ).save()

    print(f"Successfully transferred {table_name} to ClickHouse")


# Main execution
if __name__ == "__main__":
    print("Starting HDFS to ClickHouse data transfer...")

    # Transfer each report table
    for table in report_tables:
        transfer_table_to_clickhouse(table)

    print("Data transfer completed successfully!")
    spark.stop()
