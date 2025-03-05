# Data Pipeline Setup with Kafka, Spark, EventSim, and HDFS

This README provides a comprehensive guide to setting up a data pipeline using Kafka, Spark, EventSim, and HDFS. The setup includes Docker Compose to streamline the deployment process.

## Kafka 🔌

**Purpose:** 
- Receive and temporarily store large volumes of simulated (EventSim) data.

**Visualization Tools:** 
- Consider using tools like Redpanda Console, KafkaUI, or AKHQ for better visualization of Kafka data.

## Spark ⚡

**Purpose:** 
- Fetch data from Kafka in micro-batches (e.g., every 1 minute) using Structured Streaming.

**Initial Data Processing:** 
- Convert timestamps, remove bad records, but keep the data as raw as possible.

**Storage:** 
- Store the processed data in HDFS.

## HDFS (Hive Partitioned + Parquet 🗄️)

**Output Format:** 
- Write the output in Parquet format to HDFS with Hive partitioning.

**Bronze Layer:** 
- This is the raw but structured data stored here.

**Data Organization:** 
- Keep the data clean and organized in partitions (day/hour) for easier analysis. Choose the partition combination carefully based on the data.

## Docker Compose 🐳

**Services:** 
- Define and bring up all services (Kafka, Spark, EventSim, Hadoop) in the `docker-compose.yml` file.

**Development and Testing:** 
- Use Docker Compose for a simple setup, suitable for development and testing.

**Production Deployment:** 
- For production, consider using Kubernetes or similar services for better management.

## EventSim Setup

**Application:** 
- EventSim is a Scala application, Dockerized and accessible via a provided link.

## Kafka Setup

**Components:** 
- Set up Zookeeper and Kafka. Optionally, use Kafka with Kraft.

**Registry Schema:** 
- Use the registry schema if you want the data to have a schema inside Kafka.

**Visualization:** 
- Integrate a visualization tool for Kafka as mentioned above.

## Spark Setup

**Components:** 
- Define Spark Master and several Spark Workers in the Docker Compose file.

**Spark UI:** 
- Ensure the Spark UI is exposed.

**Workers' Specification:** 
- Determine the number and specifications of Spark Workers as per your requirements.

## Hadoop Setup

**Repo:** 
- Use the provided repository to set up Hadoop components separately.

**Hadoop UI:** 
- Expose the Hadoop UI (HDFS).

**Configuration:** 
- Adjust configurations if needed.

**Objective:** 
- Store the raw data in real-time.

## Conclusion

This overall structure ensures a smooth data pipeline from data generation with EventSim to storing processed data in HDFS, with visualization and monitoring tools integrated along the way.

Happy coding! 🚀
