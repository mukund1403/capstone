import paho.mqtt.client as mqtt
from driver import MockPYNQDriver  # @jon swap with real PYNQDriver later
import json
import os

from dotenv import load_dotenv
load_dotenv()


# Initialize driver
driver = MockPYNQDriver()  # @jon need to replace here also

# MQTT configuration
BROKER_HOST = "localhost"
BROKER_PORT = 8883
SENSOR_DEFENDER_SWORD_TOPIC = "fruitninja/defender/sword/imu/window"
SENSOR_DEFENDER_HAND_TOPIC = "fruitninja/defender/hand/imu/window"
SENSOR_ATTACKER_TOPIC = "fruitninja/attacker/imu/window"
GESTURE_ATTACKER_TOPIC = "fruitninja/attacker/gesture/detected"
GESTURE_DEFENDER_HAND_TOPIC = "fruitninja/defender/hand/gesture/detected"
GESTURE_DEFENDER_SWORD_TOPIC = "fruitninja/defender/sword/gesture/detected"
CA_CERT_PATH = "../ca.crt"

pub_sub_dict = {
    SENSOR_DEFENDER_SWORD_TOPIC: GESTURE_DEFENDER_SWORD_TOPIC,
    SENSOR_DEFENDER_HAND_TOPIC: GESTURE_DEFENDER_HAND_TOPIC,
    SENSOR_ATTACKER_TOPIC: GESTURE_ATTACKER_TOPIC
}


def parse_sensor_payload(payload):
    """
    Need to edit this for AI!
    Convert raw MQTT payload to input for driver.run().
    Replace with actual parsing logic (e.g. np array of sensor data)
    """
    try:
        data = json.loads(payload.decode("utf-8"))
    except Exception:
        data = payload  # fallback for mock but can also use this and parse in run if you want
    return data


def on_message(client: mqtt.Client, userdata, msg):
    sensor_data = parse_sensor_payload(msg.payload)
    gesture = driver.run(sensor_data)

    # this whole thing can be deleted and we should just json.dumps(gesture)
    # json structure returned from driver.run should be {"gesture":str, "confidence":int}
    gesture_msg = {
        "gesture": gesture,
        "confidence": 0.93
    }
    incoming_topic = msg.topic
    outgoing_topic = pub_sub_dict[incoming_topic]
    client.publish(outgoing_topic, json.dumps(gesture_msg), qos=0)

    print(f"[MQTT] Published gesture: {gesture}")


def main():
    client = mqtt.Client(client_id=os.getenv("ULTRA96_USERNAME"))
    client.tls_set(ca_certs=CA_CERT_PATH)
    client.tls_insecure_set(False)  # helps me verify broker
    client.username_pw_set(username=os.getenv(
        "ULTRA96_USERNAME"), password=os.getenv("ULTRA96_PASSWORD"))
    client.on_message = on_message
    client.connect(BROKER_HOST, BROKER_PORT)
    client.subscribe([
        (SENSOR_DEFENDER_SWORD_TOPIC, 0),
        (SENSOR_DEFENDER_HAND_TOPIC, 0),
        (SENSOR_ATTACKER_TOPIC, 0)
    ])

    print("[MQTT] Connected and subscribed to sensor topics")
    client.loop_forever()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        driver.close()
        print("Exiting...")
