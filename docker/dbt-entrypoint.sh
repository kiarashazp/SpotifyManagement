#!/bin/bash
set -e

# Install additional dependencies for Spark
echo "Installing dbt-spark and dependencies..."
pip install dbt-spark[thrift]==1.0.0 pyhdfs

# Install PySpark for Python operations
echo "Installing PySpark..."
pip install pyspark==3.5.0 pyhive

# Check if Hadoop client is installed
echo "Checking Hadoop installation..."
if ! command -v hdfs &> /dev/null; then
    echo "HDFS command not found. Installing Hadoop client..."
    
    # Install wget if not available
    if ! command -v wget &> /dev/null; then
        echo "Installing wget..."
        apt-get update && apt-get install -y wget
    fi
    
    # Create directory for Hadoop installation
    mkdir -p /opt/hadoop
    
    # Download and install Hadoop client
    cd /tmp
    wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
    tar -xzf hadoop-3.3.6.tar.gz
    mv hadoop-3.3.6/* /opt/hadoop/
    rm -rf hadoop-3.3.6.tar.gz hadoop-3.3.6
    
    # Set Hadoop environment variables
    export HADOOP_HOME=/opt/hadoop
    export PATH=$PATH:$HADOOP_HOME/bin
    
    # Add to .bashrc for persistence
    echo "export HADOOP_HOME=/opt/hadoop" >> ~/.bashrc
    echo "export PATH=\$PATH:\$HADOOP_HOME/bin" >> ~/.bashrc
    
    # Copy Hadoop configuration if mounted
    if [ -d "/etc/hadoop/conf" ]; then
        echo "Copying Hadoop configuration files..."
        cp -r /etc/hadoop/conf/* $HADOOP_HOME/etc/hadoop/
    fi
fi

# Try to create HDFS directories, but don't fail if it doesn't work
echo "Creating HDFS directories (if HDFS is available)..."
if command -v hdfs &> /dev/null; then
    # Try to create directories, but continue if it fails
    hdfs dfs -mkdir -p /user/bronze || echo "Could not create HDFS directories. Will continue anyway."
    hdfs dfs -mkdir -p /user/silver/dimensions || echo "Could not create HDFS directories. Will continue anyway."
    hdfs dfs -mkdir -p /user/silver/facts || echo "Could not create HDFS directories. Will continue anyway."
    hdfs dfs -mkdir -p /user/gold || echo "Could not create HDFS directories. Will continue anyway."
    hdfs dfs -chmod -R 777 /user || echo "Could not set permissions on HDFS directories. Will continue anyway."
else
    echo "HDFS command still not available. HDFS directories must be created manually."
    echo "You can do this by running the following commands on the namenode container:"
    echo "  docker exec -it namenode hdfs dfs -mkdir -p /user/bronze"
    echo "  docker exec -it namenode hdfs dfs -mkdir -p /user/silver/dimensions"
    echo "  docker exec -it namenode hdfs dfs -mkdir -p /user/silver/facts"
    echo "  docker exec -it namenode hdfs dfs -mkdir -p /user/gold"
    echo "  docker exec -it namenode hdfs dfs -chmod -R 777 /user"
fi

# Initialize DBT project if it doesn't exist
if [ ! -f "/usr/app/dbt_project.yml" ]; then
    echo "Initializing DBT project..."
    cd /usr/app
    dbt init spotify_analytics
    
    # Copy our profiles.yml to the right location
    mkdir -p /root/.dbt
    if [ -f "/usr/app/profiles/profiles.yml" ]; then
        cp /usr/app/profiles/profiles.yml /root/.dbt/profiles.yml
        echo "Copied profiles.yml to /root/.dbt/"
    else
        echo "Warning: profiles.yml not found in /usr/app/profiles/"
    fi
fi

# Run DBT commands as needed
echo "Ready to run DBT commands..."
echo "  * To run all models: dbt run"
echo "  * To run specific models: dbt run --models modelname"
echo "  * To generate docs: dbt docs generate"

# Keep container running
echo "DBT container is now running. Use 'docker exec -it dbt bash' to connect."
tail -f /dev/null