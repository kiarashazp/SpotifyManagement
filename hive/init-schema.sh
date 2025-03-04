#!/bin/bash

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=hive psql -h hive-metastore-postgresql -U hive -d metastore -c "SELECT 1" > /dev/null 2>&1; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done
echo "PostgreSQL is up - executing schema initialization"

# Initialize schema
$HIVE_HOME/bin/schematool -dbType postgres -initSchema --verbose

# Start metastore
$HIVE_HOME/bin/hive --service metastore