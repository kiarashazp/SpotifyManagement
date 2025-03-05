# Eventsim: Event Data Generation for Testing and Demos

## Introduction

Eventsim is a program that generates event data for testing and demos. 
It is written in Scala and is designed to replicate page requests for a fake music website, similar to Spotify. 
The generated data resembles real user data but is entirely synthetic. Eventsim allows for configurable data generation, enabling the creation of data for a few users over a short period or for a large number of users over many years. The data can be written to files or piped to Apache Kafka.

Eventsim is useful for product development, correctness testing, demos, performance testing, and training. 
However, it is not recommended for researching machine learning algorithms or understanding real user behavior.

## Statistical Model

The simulator is based on observations of real user behavior to ensure that the generated data appears realistic. Key aspects of the statistical model include:

- Users randomly arrive at the site according to a Poisson process, with a minimum gap of 30 minutes between sessions.
- The time between events follows a log-normal distribution.
- Users randomly traverse a set of states during a session, with state transition probabilities dependent on the current state.
- User behavior in a session remains consistent regardless of the time of day or day of the week.
- Damping factors can reduce user arrivals on weekends, holidays, and nighttime, with probabilities adjusted over specified periods.

## How the Simulation Works

1. **User Generation**: The simulator generates a set of users with randomly assigned properties, including attributes like names, location, and usage characteristics.
2. **Configuration**: A configuration file specifies how sessions are generated and how the fake website operates. The simulator also loads data files describing distributions for various parameters (e.g., places, song names, user agents).
3. **Priority Queue**: The simulator creates a priority queue of user sessions, ordered by the timestamp of the next event in each session.
4. **Event Handling**: The simulator processes each session in the queue, outputs event details, determines the next event, and updates the session in the queue.
5. **State Transitions**: The simulator evaluates possible state transitions from the current state. If the total transition probability is less than 1.0, the session may end, and the user will reappear in a future session.
6. **Timing**: Events typically occur at log-normally distributed intervals, except for "nextSong" events (duration of the current song) and redirects (fixed time after form submission).

## Adding Eventsim to Docker Compose

To add `eventsim` to your Docker Compose setup, include the following service definition:

```yaml
eventsim:
  image: khoramism/event-generator-eventsim:1.2
  environment:
    - BOOTSTRAP_SERVERS=broker:29092
    - SECURITY_PROTOCOL=PLAINTEXT
    - SASL_JAAS_CONFIG=''
    - SASL_MECHANISM=''
    - CLIENT_DNS_LOOKUP=use_all_dns_ips
    - SESSION_TIMEOUT_MS=45000
    - KEY_SERIALIZER=org.apache.kafka.common.serialization.ByteArraySerializer
    - VALUE_SERIALIZER=org.apache.kafka.common.serialization.ByteArraySerializer
    - SCHEMA_REGISTRY_URL=http://schema-registry:8085
    - ACKS=all
  ports:
    - "8083:8083"
  volumes:
    - ../eventsim/examples:/eventsim/examples
  working_dir: /eventsim
  command: ./bin/eventsim -c configs/Guitar-config.json --continuous --from 200 --nusers 2000 -k 1
  depends_on:
    broker:
      condition: service_healthy
  networks:
    - data-highway

