#!/bin/bash
set -e

apt-get update && apt-get install -y libsasl2-dev python-dev libldap2-dev libssl-dev

# Install additional dependencies for Spark
echo "Installing dbt-spark and dependencies..."
pip install dbt-spark==1.0.0 pyhive dbt-spark[PyHive]

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

# Run DBT commands as needed
echo "Ready to run DBT commands..."
echo "  * To run all models: dbt run"
echo "  * To run specific models: dbt run --select modelname"
echo "  * To generate docs: dbt docs generate"

# Keep container running
echo "DBT container is now running. Use 'docker exec -it dbt bash' to connect."
tail -f /dev/null