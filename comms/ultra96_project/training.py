import paho.mqtt.client as mqtt
from collections import deque
import json
import os
import time
import threading
import numpy as np

from dotenv import load_dotenv
load_dotenv()

# CONFIG
WINDOW_SIZE = 75
STRIDE = 1

# Training config
TRAINING_CLASS = None  # set at startup
OUTPUT_FILE = "training.txt"

# MQTT configuration
BROKER_HOST = "localhost"
BROKER_PORT = 8883
SENSOR_DEFENDER_SWORD_TOPIC = "fruitninja/defender/sword/imu/window"
SENSOR_DEFENDER_HAND_TOPIC  = "fruitninja/defender/hand/imu/window"
SENSOR_ATTACKER_TOPIC       = "fruitninja/attacker/imu/window"
CA_CERT_PATH = "../ca.crt"

TOPIC_OPTIONS = {
    "1": ("Defender Sword",  SENSOR_DEFENDER_SWORD_TOPIC),
    "2": ("Defender Hand",   SENSOR_DEFENDER_HAND_TOPIC),
    "3": ("Attacker Glove",  SENSOR_ATTACKER_TOPIC),
}

CLASS_OPTIONS = {
    "0": "idle",
    "1": "defender glove block",
    "2": "attacker glove throw",
    "3": "defender sword circle",
    "4": "defender sword z",
    "5": "defender sword checkmark",
    "6": "defender sword carat",
    "7": "defender sword infinity",
}

# Set at startup
SELECTED_TOPIC = None

# per-topic buffers (only one will be used, but kept generic)
buffers       = {topic: deque(maxlen=WINDOW_SIZE) for topic in [SENSOR_DEFENDER_SWORD_TOPIC, SENSOR_DEFENDER_HAND_TOPIC, SENSOR_ATTACKER_TOPIC]}
stride_counts = {topic: 0 for topic in [SENSOR_DEFENDER_SWORD_TOPIC, SENSOR_DEFENDER_HAND_TOPIC, SENSOR_ATTACKER_TOPIC]}

# Collection state
collecting   = False
file_lock    = threading.Lock()
window_count = 0


def countdown_and_start():
    global collecting
    print("\nGet ready...")
    for n in (3, 2, 1):
        print(f"  {n}")
        time.sleep(0.5)
    print(">>> GESTURE NOW! <<<\n")
    collecting = True


def write_window(window: np.ndarray):
    global collecting, window_count

    with file_lock:
        with open(OUTPUT_FILE, "a") as f:
            for sample in window:
                values = " ".join(f"{v:.3f}" for v in sample)
                f.write(f"{TRAINING_CLASS} {values}\n")
            f.write("\n")
        window_count += 1
        print(f"[DATA] Wrote window #{window_count} ({len(window)} samples, class {TRAINING_CLASS} - {CLASS_OPTIONS[str(TRAINING_CLASS)]})")

    # Pause collection and reset buffers
    collecting = False
    for buf in buffers.values():
        buf.clear()
    for topic in stride_counts:
        stride_counts[topic] = 0

    # Kick off next countdown
    threading.Thread(target=countdown_and_start, daemon=True).start()


def parse_sensor_payload(payload) -> list:
    data = json.loads(payload.decode("utf-8"))
    if isinstance(data, list):
        return [[float(s["ax"]), float(s["ay"]), float(s["az"]), float(s["gx"]), float(s["gy"]), float(s["gz"])] for s in data]
    else:
        return [[float(data["ax"]), float(data["ay"]), float(data["az"]), float(data["gx"]), float(data["gy"]), float(data["gz"])]]


def on_message(client: mqtt.Client, userdata, msg):
    if not collecting:
        return

    topic = msg.topic
    samples = parse_sensor_payload(msg.payload)
    buf = buffers[topic]

    for sample in samples:
        buf.append(sample)
        stride_counts[topic] += 1

    if len(buf) == WINDOW_SIZE and stride_counts[topic] >= STRIDE:
        stride_counts[topic] = 0
        window = np.array(buf, dtype=np.float32)  # shape: (WINDOW_SIZE, 6)
        write_window(window)


def prompt_topic() -> str:
    print("\nSelect sensor topic:")
    for key, (name, topic) in TOPIC_OPTIONS.items():
        print(f"  {key} - {name}  ({topic})")
    while True:
        choice = input("Enter choice (1/2/3): ").strip()
        if choice in TOPIC_OPTIONS:
            name, topic = TOPIC_OPTIONS[choice]
            print(f"Selected: {name}")
            return topic
        print("Invalid choice, try again.")


def prompt_class() -> int:
    print("\nSelect training class:")
    for key, label in CLASS_OPTIONS.items():
        print(f"  {key} - {label}")
    while True:
        choice = input("Enter class (0-7): ").strip()
        if choice in CLASS_OPTIONS:
            print(f"Selected: {choice} - {CLASS_OPTIONS[choice]}")
            return int(choice)
        print("Invalid choice, try again.")


def main():
    global TRAINING_CLASS, SELECTED_TOPIC

    SELECTED_TOPIC  = prompt_topic()
    TRAINING_CLASS  = prompt_class()

    print(f"\nOutput file: {OUTPUT_FILE}")
    print(f"Window size: {WINDOW_SIZE} samples, stride: {STRIDE} samples")
    print("\nStarting MQTT connection...")

    client = mqtt.Client(client_id=os.getenv("ULTRA96_USERNAME"))
    client.tls_set(ca_certs=CA_CERT_PATH)
    client.tls_insecure_set(False)
    client.username_pw_set(
        username=os.getenv("ULTRA96_USERNAME"),
        password=os.getenv("ULTRA96_PASSWORD")
    )
    client.on_message = on_message
    client.connect(BROKER_HOST, BROKER_PORT)
    client.subscribe([(SELECTED_TOPIC, 0)])

    print(f"[MQTT] Connected and subscribed to {SELECTED_TOPIC}")

    client.loop_start()

    # First countdown
    countdown_and_start()
    print("Collecting... Press Ctrl+C to stop.\n")

    try:
        while True:
            time.sleep(0.1)
    except KeyboardInterrupt:
        print("\n[DONE] Stopping collection.")
        client.loop_stop()
        client.disconnect()
        print(f"Total windows collected: {window_count}")
        print(f"Data saved to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()