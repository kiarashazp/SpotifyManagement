#!/bin/bash
# This script should be run from the host to set up HDFS directories

echo "Setting up HDFS directories for the project..."

# Create the directory structure in HDFS
docker exec -it namenode hdfs dfs -mkdir -p /user/bronze
docker exec -it namenode hdfs dfs -mkdir -p /user/silver/dimensions
docker exec -it namenode hdfs dfs -mkdir -p /user/silver/facts
docker exec -it namenode hdfs dfs -mkdir -p /user/gold

# Set permissions to allow all containers to write to these directories
docker exec -it namenode hdfs dfs -chmod -R 777 /user

# Verify the directories were created
echo "Verifying HDFS directory structure:"
docker exec -it namenode hdfs dfs -ls -R /user

echo "HDFS setup completed successfully."