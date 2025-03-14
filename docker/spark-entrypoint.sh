#!/bin/bash
set -e

# Start Spark master (using Bitnami's script)
/opt/bitnami/scripts/spark/entrypoint.sh /opt/bitnami/scripts/spark/run.sh &

# Wait for Spark master to be ready
echo "Waiting for Spark Master to be ready..."
sleep 15

# Start Thrift Server with NOSASL authentication
echo "Starting Spark Thrift Server with NOSASL authentication..."
/opt/bitnami/spark/sbin/start-thriftserver.sh \
  --master spark://spark:7077 \
  --hiveconf hive.server2.thrift.port=10000 \
  --hiveconf hive.server2.thrift.bind.host=0.0.0.0 \
  --hiveconf hive.server2.authentication=NOSASL \
  --hiveconf hive.server2.enable.doAs=false

# Keep container running and show logs
tail -f /opt/bitnami/spark/logs/*
