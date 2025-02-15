#!/bin/bash

# Function to register a schema
register_schema() {
  local schema_file=$1
  local subject_name=$2
  local schema=$(cat ${schema_file})

  echo "Registering schema for ${subject_name}..."
  wget --quiet --method=POST --header=Content-Type:application/vnd.schemaregistry.v1+json \
  --body-data="{\"schema\": ${schema}}" \
  --output-document=- http://schema-registry:8085/subjects/${subject_name}/versions
}

# Wait for schema registry to be up
echo "Waiting for schema registry..."
while ! wget -qO- http://schema-registry:8085/; do
  sleep 5
done

# Register schemas
register_schema /schema-registry/avro/auth-event-schema.avsc auth_events
register_schema /schema-registry/avro/listen-event-schema.avsc listen_events
register_schema /schema-registry/avro/page-view-event-schema.avsc page_view_events
register_schema /schema-registry/avro/status-change-event-schema.avsc status_change_events


