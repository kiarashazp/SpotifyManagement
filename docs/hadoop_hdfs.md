# **Hadoop and HDFS: Technical Overview**

## **Introduction**

Apache Hadoop is an open-source framework designed for distributed storage and processing of large datasets. Hadoop's distributed file system, HDFS (Hadoop Distributed File System), is at the core of its data storage capability, providing high-throughput access to application data. This technical documentation focuses on the implementation of HDFS within a Docker-based setup, highlighting the roles of various services such as the NameNode, DataNode, ResourceManager, NodeManager, and HistoryServer.

## **HDFS Overview**

HDFS is designed to store vast amounts of data reliably and to stream those data sets at high bandwidth to user applications. It follows a master-slave architecture where the NameNode serves as the master and DataNodes serve as slaves.

### **Key Components**

- **NameNode:** The central component responsible for managing the filesystem namespace and regulating access to files by clients. It maintains the directory tree of all files in the file system and tracks where across the cluster the file data is kept.
- **DataNode:** Responsible for storing the actual data. Each DataNode manages storage attached to the node it runs on and periodically reports the status of its stored data back to the NameNode.

## **Service Roles**

### **NameNode**

The NameNode is crucial to HDFS as it maintains the metadata for the file system. It keeps track of the file-to-block mapping and the current locations of these blocks, thus serving as the system's metadata server. High availability is achieved by using checkpoints and backup nodes.

### **DataNode**

DataNodes are the workhorses of HDFS. They manage storage attached to their nodes and handle read and write requests from clients. DataNodes also perform block creation, deletion, and replication upon instruction from the NameNode. They ensure data integrity by performing periodic checksum verification.

### **ResourceManager**

The ResourceManager is the core component of Hadoop's YARN (Yet Another Resource Negotiator) and is responsible for managing system resources and scheduling applications. It ensures that resources are allocated efficiently and tasks are executed according to priority and system capacity.

### **NodeManager**

NodeManagers run on slave nodes within the Hadoop cluster and are responsible for launching and monitoring application containers, reporting resource usage to the ResourceManager, and ensuring the node's health.

### **HistoryServer**

The HistoryServer tracks completed applications and displays job history. It provides a web interface for users to access historical job information and logs, which is invaluable for debugging and performance analysis.

## **Docker Compose Setup**

In the Docker Compose setup, we have configured several services to simulate a Hadoop cluster, each playing a crucial role in the HDFS and YARN ecosystem:

- **NameNode Service:** This service runs a Docker container based on the `bde2020/hadoop-namenode` image. It is configured to expose essential ports for HDFS operations and JMX monitoring. The NameNode persists its data to a volume to ensure data durability.
- **DataNode Service:** This service uses the `bde2020/hadoop-datanode` image to run a DataNode. It is dependent on the NameNode and also persists data to a volume. JMX monitoring is enabled for tracking performance metrics.
- **ResourceManager Service:** Using the `bde2020/hadoop-resourcemanager` image, this service manages cluster resources. It is configured with environment variables to ensure connectivity to the NameNode and DataNode.
- **NodeManager Service:** This service runs a NodeManager using the `bde2020/hadoop-nodemanager` image. It works under the supervision of the ResourceManager and ensures efficient resource utilization on its node.
- **HistoryServer Service:** The HistoryServer service uses the `bde2020/hadoop-historyserver` image to provide a web interface for viewing job history. It is configured similarly with volumes and JMX monitoring.

### **High Availability and Fault Tolerance**

HDFS is designed to be highly available and fault-tolerant. Data is replicated across multiple DataNodes to ensure reliability and availability even in the face of hardware failures. The NameNode uses a journal to log changes to the file system's metadata, which can be used to recover the metadata in case of failures.

### **JMX Monitoring**

Java Management Extensions (JMX) are used to monitor and manage system resources and application performance. In this setup, JMX exporters are configured to collect metrics and expose them for monitoring tools such as Prometheus.

## **Conclusion**

Integrating Hadoop and HDFS into a Docker-based environment offers scalable and efficient data storage and processing capabilities. This setup leverages the strengths of HDFS for managing large datasets with high availability and fault tolerance, and the convenience of containerization for ease of deployment and management. The various services, including NameNode, DataNode, ResourceManager, NodeManager, and HistoryServer, work in unison to provide a robust framework for handling big data workloads.


