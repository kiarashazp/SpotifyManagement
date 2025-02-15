#!/bin/bash

# Function to register a schema
register_schema() {
  local schema_file=$1
  local subject_name=$2

  # Check if the schema file exists and is readable
  if [[ -r ${schema_file} ]]; then
    local schema=$(cat ${schema_file})
    echo "Registering schema for ${subject_name}..."
    echo "Schema content: ${schema}"  # Debugging: Print schema content

    wget --quiet --method=POST --header=Content-Type:application/vnd.schemaregistry.v1+json \
    --body-data="{\"schema\": \"${schema//\"/\\\"}\"}" \
    --output-document=- http://schema-registry:8085/subjects/${subject_name}/versions
  else
    echo "Error: Schema file ${schema_file} not found or not readable."
  fi
}

# Wait for schema registry to be up
echo "Waiting for schema registry..."
while ! wget -qO- http://schema-registry:8085/; do
  sleep 5
done

# Register schemas with corrected filenames
register_schema /schemas/avro/auth_events_schema.avsc AuthEvent
register_schema /schemas/avro/listen_events_schema.avsc ListenEvent
register_schema /schemas/avro/page_view_events_schema.avsc PageViewEvent
register_schema /schemas/avro/status_change_events_schema.avsc StatusChangeEvent
