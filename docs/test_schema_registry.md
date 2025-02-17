# Step-by-Step Guide
## Access the Kafka Broker Container
This command opens a bash session in the Kafka broker container.
```bash
docker exec -it broker /bin/bash
```
## Navigate to Kafka Binaries Directory
Change directory to the Kafka installation's bin folder where the Kafka scripts are located.
```bash
cd /opt/kafka/bin
```
## List All Kafka Topics
Lists all the topics available in the Kafka cluster.
```bash
./kafka-topics.sh --bootstrap-server localhost:9092 --list
```
## Produce a Valid JSON Message
Start the Kafka console producer to send messages to the auth_events topic.
```bash
./kafka-console-producer.sh --broker-list localhost:9092 --topic auth_events
```
## Send a Valid JSON Message
Type and send a valid JSON message to the auth_events topic.
```json
{"city":"Tokyo","firstName":"John","gender":"male","itemInSession":1,"lastName":"Doe","lat":35.6895,"level":"free","lon":139.6917,"registration":1582605074,"sessionId":123,"state":"Tokyo","success":true,"ts":1582605074,"userAgent":"Mozilla/5.0","userId":1,"zip":"100-0001"}
```
## Send an Invalid JSON Message
Type and send an invalid JSON message to simulate a schema validation failure.
```json
{"city":"Decatur","firstName":"Ryan"}
```
## Exit the Producer Console
Press Ctrl+D to exit the Kafka console producer.
```
Ctrl+D
```
## Consume Messages from the Topic
Start the Kafka console consumer to read messages from the auth_events topic. It will fetch one message from the beginning of the topic.
```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic auth_events --from-beginning --max-messages 1
```
## Ping the Schema Registry
Check if the Schema Registry is reachable from the broker container.
```bash
ping schema-registry
```
## List All Registered Subjects
Use wget to list all subjects (schemas) registered in the Schema Registry.
```bash
wget -qO- http://schema-registry:8085/subjects
```
## List Schema Versions for a Specific Subject
Use wget to list all versions of the auth-events schema.
```bash
wget -qO- http://schema-registry:8085/subjects/auth-events/versions
```
## Get Schema Details for a Specific Version
Use wget to get the details of version 1 of the auth-events schema.
```bash
wget -qO- http://schema-registry:8085/subjects/auth-events/versions/1
```
