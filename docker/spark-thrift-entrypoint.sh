#!/bin/bash
set -e

# Start Spark Thrift Server
echo "Starting Spark Thrift Server..."

# Wait for Spark Master to be ready
echo "Waiting for Spark Master..."
until python -c "import socket; s=socket.socket(); s.connect(('spark', 8080))" 2>/dev/null; do
  echo "Spark Master not ready yet, waiting..."
  sleep 5
done

echo "Spark Master is ready, starting Thrift server..."
/opt/bitnami/spark/sbin/start-thriftserver.sh \
  --master spark://spark:7077 \
  --packages org.apache.spark:spark-hive-thriftserver_2.12:3.5.0 \
  --hiveconf hive.server2.thrift.port=10000 \
  --hiveconf hive.server2.thrift.bind.host=0.0.0.0 \
  --conf spark.sql.warehouse.dir=hdfs://namenode:9000/user/hive/warehouse

# Keep the container running
echo "Thrift server started, keeping container alive..."
tail -f /opt/bitnami/spark/logs/spark-*-org.apache.spark.sql.hive.thriftserver.HiveThriftServer2*.out
spark-submit \
  --packages org.apache.spark:spark-hive-thriftserver_2.12:3.5.0 \
  --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2

