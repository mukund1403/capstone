#!/bin/bash

# Topic and broker info
BROKER="localhost"
PORT="8883"
TOPIC="fruitninja/attacker/imu/window"
CAFILE="ca.crt"
USERNAME="esp32"
PASSWORD="capstone"

# JSON payload
PAYLOAD='{"ax": 0.12, "ay": 0.02, "az": 9.81, "gx": 0.08, "gy": -0.02, "gz": 15}'

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