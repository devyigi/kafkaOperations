#!/bin/bash

# Kafka home directory
KAFKA_HOME=<kafka-home-directory>
# Bootstrap server addresses
BOOTSTRAP_SERVER=ibm1.example.com:9092,ibm2.example.com:9092,ibm3.example.com:9092

TMP_JSON="/tmp/resize.json"
GENERATE_JSON_SCRIPT="/tmp/createKafkaRebalanceJson"

INPUT_FILE1="/tmp/output-replication-1.txt"
INPUT_FILE2="/tmp/output-replication-2.txt"

source "$GENERATE_JSON_SCRIPT"

process_file() {
  local INPUT_FILE="$1"
  echo "=== Processing file: $INPUT_FILE ==="
  while read -r line; do
      [[ -z "$line" ]] && continue

      echo "Processing: $line"
      getKafkaResizeJson $line > "$TMP_JSON"

      $KAFKA_HOME/bin/kafka-reassign-partitions.sh --bootstrap-server "$BOOTSTRAP_SERVER" \
        --reassignment-json-file "$TMP_JSON" --execute

      $KAFKA_HOME/bin/kafka-reassign-partitions.sh --bootstrap-server "$BOOTSTRAP_SERVER" \
        --reassignment-json-file "$TMP_JSON" --verify

      rm -f "$TMP_JSON"
      sleep 15
  done < "$INPUT_FILE"
}

# Process both files
process_file "$INPUT_FILE1"
process_file "$INPUT_FILE2"
