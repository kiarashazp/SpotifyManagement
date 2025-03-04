# Docker Compose Setup
```
    cd docker
    docker-compose up -d
```
# HDFS Initialization
```
docker exec -it namenode hdfs dfs -mkdir -p /user/bronze
docker exec -it namenode hdfs dfs -mkdir -p /user/silver/dimensions
docker exec -it namenode hdfs dfs -mkdir -p /user/silver/facts
docker exec -it namenode hdfs dfs -mkdir -p /user/gold
docker exec -it namenode hdfs dfs -chmod -R 777 /user

```
# Verify HDFS Setup
```
docker exec -it namenode hdfs dfs -ls /user
```

# Initialize DBT Project
```
docker exec -it dbt bash
```

# Initialize ClickHouse Tables
```
cat clickhouse/table_definitions.sql | docker exec -i clickhouse-server clickhouse-client --multiquery
```

# Verify Tables Created
```
docker exec -it clickhouse-server clickhouse-client --query "SHOW TABLES FROM spotify"
```

# Data Pipeline Execution

## Step 1: Bronze Layer - Ingest Data from Kafka to HDFS

```
docker cp spark/bronze_ingest.py docker-spark-1:/opt/bitnami/spark/bronze_ingest.py

docker exec -it spark /bin/bash

./bin/spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0 bronze_ingest.py
```

## Step 2: Silver Layer - Transform Data into Star Schema

For Spark Connectivity
```
spark-submit \
  --packages org.apache.spark:spark-hive-thriftserver_2.12:3.5.0 \
  --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2
```