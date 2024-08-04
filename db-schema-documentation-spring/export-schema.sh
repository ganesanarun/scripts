#!/bin/bash
set -euo pipefail

PROFILE=${1:-local}

if [ -z "$PROFILE" ]; then
    echo "Usage: ./export-schema.sh <spring-profile>"
    exit 1
fi

YAML_FILE="src/main/resources/application-${PROFILE}.yml"
MAIN_YAML_FILE="src/main/resources/application.yml"

if [ ! -f "$YAML_FILE" ]; then
    echo "File not found: $YAML_FILE"
    exit 1
fi

if [ ! -f "$MAIN_YAML_FILE" ]; then
    echo "File not found: $MAIN_YAML_FILE"
    exit 1
fi


YAML_PATH="spring.datasource"
SCHEMA_PATH="spring.datasource.hikari.schema"
OUTPUT_DIR="docs/sql"

# Extract database connection details from YAML
DB_URL=$(yq e ".$YAML_PATH.url" $YAML_FILE)
DB_USER=$(yq e ".$YAML_PATH.username" $YAML_FILE)
DB_PASSWORD=$(yq e ".$YAML_PATH.password" $YAML_FILE)
DB_SCHEMA=$(yq e ".$SCHEMA_PATH" $MAIN_YAML_FILE)

# Use 'public' as the default schema if not defined in the YAML file
DB_SCHEMA=${DB_SCHEMA:-public}

DB_HOST=$(echo "$DB_URL" | sed -n 's/jdbc:postgresql:\/\/\([^:]*\):\([0-9]*\)\/\(.*\)/\1/p')
DB_PORT=$(echo "$DB_URL" | sed -n 's/jdbc:postgresql:\/\/\([^:]*\):\([0-9]*\)\/\(.*\)/\2/p')
DB_NAME=$(echo "$DB_URL" | sed -n 's/jdbc:postgresql:\/\/\([^:]*\):\([0-9]*\)\/\(.*\)/\3/p')


if [ -z "$DB_URL" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_SCHEMA" ]; then
    echo "Database connection details not found in the YAML file"
    exit 1
fi

if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_NAME" ]; then
    echo "Invalid database URL: $DB_URL"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Export the schema using pg_dump (only table definitions, excluding functions and procedures)
PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER --schema-only -n $DB_SCHEMA $DB_NAME | \
awk 'RS="";/^(CREATE TABLE|ALTER TABLE|ALTER INDEX|CREATE INDEX)[^;]*;/' > $OUTPUT_DIR/ddl.sql


echo "Schema export completed: $OUTPUT_DIR/ddl.sql"
