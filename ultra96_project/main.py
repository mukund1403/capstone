import paho.mqtt.client as mqtt
from driver import MockPYNQDriver  # swap with real PYNQDriver later
import json
import os

from dotenv import load_dotenv
load_dotenv()


# Initialize driver
driver = MockPYNQDriver()

# MQTT configuration
BROKER_HOST = "localhost"
BROKER_PORT = 1883  # Reverse tunnel port
SENSOR_TOPIC = "fruitninja/imu/window"
GESTURE_TOPIC = "fruitninja/gesture/detected"


def parse_sensor_payload(payload):
    """
    Need to edit this for AI!
    Convert raw MQTT payload to input for driver.run().
    Replace with actual parsing logic (e.g. np array of sensor data)
    """
    try:
        data = json.loads(payload.decode("utf-8"))
    except Exception:
        data = payload  # fallback for mock
    return data

def on_message(client:mqtt.Client, userdata, msg):
    sensor_data = parse_sensor_payload(msg.payload)
    gesture = driver.run(sensor_data)
    
    gesture_msg = {
        "gesture": gesture,
        "confidence": 0.93  # placeholder
    }   

    client.publish(GESTURE_TOPIC, json.dumps(gesture_msg), qos=1)

    print(f"[MQTT] Published gesture: {gesture}")

def main():
    client = mqtt.Client(client_id=os.getenv("ULTRA96_USERNAME"))
    client.username_pw_set(username=os.getenv("ULTRA96_USERNAME"), password=os.getenv("ULTRA96_PASSWORD"))
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
