from confluent_kafka import Consumer, KafkaError

# Kafka configuration
conf = {
    'bootstrap.servers': 'localhost:9092',  # Adjust the broker address as needed
    'group.id': 'eventsim_inspector',  # Consumer group ID
    'auto.offset.reset': 'earliest'
}

topics = ['auth_events', 'listen_events', 'page_view_events', 'status_change_events']  # List of topics
batch_size = 10  # Number of messages to read from each topic
eventsim_output_file = 'kafka_messages.txt'  # File to save the results


def consume_messages(topic, batch_size):
    consumer = Consumer(conf)
    consumer.subscribe([topic])
    messages = []

    try:
        while len(messages) < batch_size:
            msg = consumer.poll(timeout=1.0)
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    # End of partition event
                    continue
                else:
                    print(msg.error())
                    break

            # Process the message
            messages.append(msg.value().decode('utf-8'))

    except KeyboardInterrupt:
        pass
    finally:
        # Close down consumer to commit final offsets.
        consumer.close()

    return messages


with open(eventsim_output_file, 'w') as f:
    for topic in topics:
        f.write(f"\nConsuming messages from topic: {topic}\n")
        messages = consume_messages(topic, batch_size)
        for i, message in enumerate(messages):
            f.write(f"Message {i + 1}: {message}\n")

print(f"Results saved to {eventsim_output_file}")
