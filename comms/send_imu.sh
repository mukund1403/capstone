#!/bin/bash

# Topic and broker info
BROKER="localhost"
PORT="8883"
TOPIC="fruitninja/attacker/gesture/detected"
CAFILE="ca.crt"
USERNAME="ultra96"
PASSWORD="capstone"

# JSON payload
PAYLOAD='{"gesture":"throw", "confidence":0.99}' 

# Send 101 messages
for i in $(seq 1 101); do
    mosquitto_pub \
        -h "$BROKER" \
        -p "$PORT" \
        -t "$TOPIC" \
        --cafile "$CAFILE" \
        -u "$USERNAME" \
        -P "$PASSWORD" \
        -m "$PAYLOAD"
done

echo "Sent 101 messages to $TOPIC"