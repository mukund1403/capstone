import paho.mqtt.client as mqtt
from driver import MockPYNQDriver  # swap with real PYNQDriver later
import json

# Initialize driver
driver = MockPYNQDriver()

# MQTT configuration
BROKER_HOST = "localhost"
BROKER_PORT = 1883  # Reverse tunnel port
SENSOR_TOPIC = "imu/window/#"
GESTURE_TOPIC = "gesture/detected"

def parse_sensor_payload(payload):
    """
    Need to edit this for AI!
    Convert raw MQTT payload to input for driver.run().
    Replace with actual parsing logic (e.g., NumPy array of sensor data)
    """
    try:
        data = json.loads(payload.decode("utf-8"))
    except Exception:
        data = payload  # fallback for mock
    return data

def on_message(client, userdata, msg):
    sensor_data = parse_sensor_payload(msg.payload)
    gesture = driver.run(sensor_data)
    client.publish(GESTURE_TOPIC, gesture)
    print(f"[MQTT] Published gesture: {gesture}")

def main():
    client = mqtt.Client()
    client.on_message = on_message
    client.connect(BROKER_HOST, BROKER_PORT)
    client.subscribe(SENSOR_TOPIC)
    
    print("[MQTT] Connected and subscribed to sensor topic")
    client.loop_forever()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        driver.close()
        print("Exiting...")
