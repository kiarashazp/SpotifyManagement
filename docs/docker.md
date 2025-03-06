# Setup Docker Compose

## Overview
This Dockerfile sets up the environment needed to run Kafka, Spark, Hadoop, schema registry, Grafana, Prometheus, ClickHouse and Metabase.

## Docker Compose Configuration

### Services

- **eventsim**
- **broker**
- **kafka-exporter**
- **akhq**
- **schema-registry**
- **schema-registry-init**
- **spark**
- **spark-worker**
- **namenode**
- **datanode**
- **resourcemanager**
- **nodemanager1**
- **history server**
- **clickhouse-server**
- **dbt**
- **postgres-metabase**
- **metabase**
- **prometheus**
- **node-exporter**
- **alertmanager**
- **grafana**

### Using Docker and Docker Compose

1️⃣ **Clone this repository**

2️⃣ **Start Services** 

```
    docker-compose up -d
```




