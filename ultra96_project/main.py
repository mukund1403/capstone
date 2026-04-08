import paho.mqtt.client as mqtt
from driver import MockPYNQDriver, PYNQDriver  # @jon swap with real PYNQDriver later
from collections import deque
import json
import os
import numpy as np

from dotenv import load_dotenv
load_dotenv()

# CONFIG
WINDOW_SIZE = 75
"""
min stride = inference_time x sample_rate
    E.g.
        = 0.05s x 100Hz
        = 5 samples minimum
    
    If stride = 1 then we are covering all possible windows
    A lower stride means less chance of gesture falling in between windows BUT higher load on FPGA
"""        
STRIDE = 1 #0.2*WINDOW_SIZE # 20% of window size for now

# confidence level to accept the gesture
CONFIDENCE_THRESHOLD = 0.0


# Initialize driver
driver = PYNQDriver()  # @jon need to replace here also

# MQTT configuration
BROKER_HOST = "localhost"
BROKER_PORT = 8883
SENSOR_DEFENDER_SWORD_TOPIC = "fruitninja/defender/sword/imu/window"
SENSOR_DEFENDER_HAND_TOPIC = "fruitninja/defender/hand/imu/window"
SENSOR_ATTACKER_TOPIC = "fruitninja/attacker/imu/window"
GESTURE_ATTACKER_TOPIC = "fruitninja/attacker/gesture/detected"
GESTURE_DEFENDER_HAND_TOPIC = "fruitninja/defender/hand/gesture/detected"
GESTURE_DEFENDER_SWORD_TOPIC = "fruitninja/defender/sword/gesture/detected"
CA_CERT_PATH = "ca.crt"

pub_sub_dict = {
    SENSOR_DEFENDER_SWORD_TOPIC: GESTURE_DEFENDER_SWORD_TOPIC,
    SENSOR_DEFENDER_HAND_TOPIC: GESTURE_DEFENDER_HAND_TOPIC,
    SENSOR_ATTACKER_TOPIC: GESTURE_ATTACKER_TOPIC
}

# per-topic buffers — sword/hand/attacker each need independent sliding windows
buffers       = {topic: deque(maxlen=WINDOW_SIZE) for topic in pub_sub_dict}
stride_counts = {topic: 0 for topic in pub_sub_dict}

def parse_sensor_payload(payload) -> list:
    """
    Need to edit this for AI!
    Convert raw MQTT payload to input for driver.run().
    Replace with actual parsing logic (e.g. np array of sensor data)
    """
    data = json.loads(payload.decode("utf-8"))
    if isinstance(data, list):
        return [[s["ax"], s["ay"], s["az"], s["gx"], s["gy"], s["gz"]] for s in data]
    else:
        return [[data["ax"], data["ay"], data["az"], data["gx"], data["gy"], data["gz"]]]



def on_message(client: mqtt.Client, userdata, msg):
    topic = msg.topic

    # --- Sliding window ---
    samples = parse_sensor_payload(msg.payload)
    buf = buffers[topic]

    for sample in samples:
        buf.append(sample)
        stride_counts[topic] += 1

    if len(buf) == WINDOW_SIZE and stride_counts[topic] >= STRIDE:
        stride_counts[topic] = 0
        window = np.array(buf, dtype=np.float32)  # shape: (Window_size, 6)

        print(f"window length: {len(window)}")
        gesture, confidence = driver.run(window, WINDOW_SIZE)

        if confidence >= CONFIDENCE_THRESHOLD and gesture != "idle":
            if topic == SENSOR_DEFENDER_SWORD_TOPIC and (gesture == "throw" or gesture == "block"):
                return
            if topic == SENSOR_DEFENDER_HAND_TOPIC and gesture != "block":
                return
            if topic == SENSOR_ATTACKER_TOPIC and gesture != "throw":
                return

            gesture_msg = {"gesture": gesture, "confidence": confidence}
            client.publish(pub_sub_dict[topic], json.dumps(gesture_msg), qos=0)
            print(f"[MQTT] {topic} -> {gesture} ({confidence:.2f})")

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