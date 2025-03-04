#!/bin/bash

# Wait for the Schema Registry to be up and running
until curl -s http://schema-registry:8085/subjects; do
  echo "Waiting for Schema Registry..."
  sleep 5
done

echo "Schema Registry is up. Registering schemas..."

# Function to register a JSON schema
register_schema() {
  local subject=$1
  local schema_file=$2

  if [ -f ${schema_file} ]; then
    local schema=$(cat ${schema_file} | sed 's/"/\\"/g' | sed 's/$/\\n/g' | tr -d '\n')
    curl -X POST -H "Content-Type: application/json" --data "{\"schema\": \"${schema}\", \"schemaType\": \"JSON\"}" http://schema-registry:8085/subjects/${subject}/versions
    echo "Registered schema for subject: ${subject}"
  else
    echo "Schema file not found: ${schema_file}"
  fi
}

# Register each schema
register_schema "auth-events" "/schemas/json/auth_events.json"
register_schema "page-view-events" "/schemas/json/page_view_events.json"
register_schema "listen-events" "/schemas/json/listen_events.json"
register_schema "status-change-events" "/schemas/json/status_change_events.json"

echo "All schemas registered successfully."
