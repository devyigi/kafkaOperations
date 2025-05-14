#!/bin/bash

# Kafka home directory
KAFKA_HOME=<kafka-home-directory>
# Bootstrap server addresses
BOOTSTRAP_SERVER=ibm1.example.com:9092,ibm2.example.com:9092,ibm3.example.com:9092

# Input and output files
TOPIC_FILE=/tmp/list-of-topics.txt
OUTPUT_FILE1=/tmp/output-replication-1.txt
OUTPUT_FILE2=/tmp/output-replication-2.txt

# Check if the topic file exists
if [[ ! -f "$TOPIC_FILE" ]]; then
    echo "Topic file '$TOPIC_FILE' not found!"
    exit 1
fi

# Clear/create the output files
> "$OUTPUT_FILE1"
# Clear/create the output files
> "$OUTPUT_FILE2"

while IFS= read -r TOPIC; do
    [[ -z "$TOPIC" ]] && continue

    # Describe each topic
    OUTPUT=$($KAFKA_HOME/bin/kafka-topics.sh --describe --bootstrap-server "$BOOTSTRAP_SERVER" --topic "$TOPIC" 2>/dev/null)

    if [[ -z "$OUTPUT" ]]; then
        continue
    fi

    PARTITIONS=$(echo "$OUTPUT" | grep -o "PartitionCount: [0-9]*" | cut -d: -f2)
    REPLICATION=$(echo "$OUTPUT" | grep -o "ReplicationFactor: [0-9]*" | cut -d: -f2)

    if [[ "$REPLICATION" -eq 1 ]]; then
        echo "$TOPIC $PARTITIONS 3 3" >> "$OUTPUT_FILE1"
    fi

    if [[ "$REPLICATION" -eq 2 ]]; then
        echo "$TOPIC $PARTITIONS 3 3" >> "$OUTPUT_FILE2"
    fi
done < "$TOPIC_FILE"

echo "Filtered results with replication factor 1 written to $OUTPUT_FILE1"
echo "Filtered results with replication factor 2 written to $OUTPUT_FILE2"