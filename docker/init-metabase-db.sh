#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "metabase" --dbname "metabase" <<-EOSQL
    CREATE DATABASE metabase;
    GRANT ALL PRIVILEGES ON DATABASE metabase TO metabase;
EOSQL