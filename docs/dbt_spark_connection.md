# Connecting DBT to Spark 

Connecting dbt to Spark using Spark Thrift Server

## Overview

The Spark Thrift Server is a component of Apache Spark that provides a HiveServer2-compatible interface to Spark. Essentially, it allows you to run SQL queries against your Spark cluster from various client applications using the JDBC and ODBC protocols. This is particularly useful for BI tools, SQL clients, or any application that supports these protocols.

### Key Features and Benefits

- **SQL Access**: You can query your Spark data using SQL, which makes it accessible to a wide range of users and tools.
- **Compatibility**: It supports JDBC and ODBC, allowing integration with many third-party tools like Tableau, Power BI, and more.
- **Resource Sharing**: By using the Thrift Server, multiple users can share the same Spark cluster resources efficiently.
- **Security**: It can be configured to support authentication and authorization, ensuring secure access to data.

In short, the Spark Thrift Server bridges the gap between Spark's powerful data processing capabilities and traditional SQL-based tools, making it easier to interact with and analyze your data.

## Steps to Connect dbt to Spark

Follow the steps below to connect `dbt` to Spark:

1. **Check Spark logs**:
    ```sh
    docker compose logs spark
    ```

2. **Access Spark container**:
    ```sh
    docker compose exec spark bash
    ```

3. **Start Thrift Server**:
    ```sh
    /opt/bitnami/spark/sbin/start-thriftserver.sh --master spark://spark:7077
    ```

4. **Connect using Beeline**:
    ```sh
    /opt/bitnami/spark/bin/beeline -u jdbc:hive2://spark:10000 -n spark -p spark
    ```

5. **Verify connection success**: If the connection is successful, you'll see:
    ```
    Connected to: Spark SQL (version 3.5.4)
    Driver: Hive JDBC (version 2.3.9)
    Transaction isolation: TRANSACTION_REPEATABLE_READ
    Beeline version 2.3.9 by Apache Hive
    0: jdbc:hive2://spark:10000>
    ```

6. **Run a simple query to verify the connection**:
    ```sh
    SHOW DATABASES;
    ```

7. **Access dbt container**:
    ```sh
    docker compose exec dbt bash
    ```

8. **Install necessary packages**:
    ```sh
    RUN apt-get update && \
        apt-get install -y wget netcat-openbsd procps libpostgresql-jdbc-java
    ```

9. **Debug dbt connection**:
    ```sh
    dbt debug
    ```

10. **Verify dbt connection success**: If the connection is successful, you'll see:
    ```
    All checks passed!
    ```

11. **Install dbt-spark package**:
    ```sh
    pip install dbt-spark[PyHive]
    ```

12. **Check installed packages**:
    ```sh
    pip list | grep dbt-spark
    pip list | grep PyHive
    ```


Now you have a step-by-step guide for connecting `dbt` to Spark in Markdown format!

