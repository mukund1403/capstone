import paho.mqtt.client as mqtt
import json
import random
import time

from dotenv import load_dotenv
load_dotenv()

# MQTT configuration
BROKER_HOST = "localhost"
BROKER_PORT = 8883
PUBLISH_ATTACKER_TOPIC = "fruitninja/attacker/demo"
PUBLISHER_DEFENDER_HAND_TOPIC = "fruitninja/defender/hand/demo"
PUBLISHER_DEFENDER_SWORD_TOPIC = "fruitninja/defender/sword/demo"
SENSOR_DEFENDER_SWORD_TOPIC = "fruitninja/defender/sword/imu/window"
SENSOR_DEFENDER_HAND_TOPIC = "fruitninja/defender/hand/imu/window"
SENSOR_ATTACKER_TOPIC = "fruitninja/attacker/imu/window"
CA_CERT_PATH = "../../ca.crt"

tx_start_time = None
tx_bytes = 0

NUM_DEMO_PACKETS = 4

output_dict = {
    "a": PUBLISH_ATTACKER_TOPIC,
    "dh": PUBLISHER_DEFENDER_HAND_TOPIC,
    "ds": PUBLISHER_DEFENDER_SWORD_TOPIC
}


def on_message(client: mqtt.Client, userdata, msg):

    try:
        data = json.loads(msg.payload.decode())
    except json.JSONDecodeError:
        return

    if "tstart" in data:
        elapsed = time.time() - data["tstart"]

        # msg.payload is a byte array so len gives num bytes
        bytes = len(msg.payload)
        kbps = ((bytes * 8) / 1000) / elapsed

        print(
            f"[STATS] {msg.topic} | "
            f"time={elapsed:.4f}s | "
            f"throughput={kbps:.2f} kbps"
        )


def main():
    client = mqtt.Client(client_id="demo")
    client.tls_set(ca_certs=CA_CERT_PATH)
    client.tls_insecure_set(False)  # helps me verify broker
    client.username_pw_set(username="demo", password="capstone")
    client.on_message = on_message
    client.connect(BROKER_HOST, BROKER_PORT)
    client.subscribe([
        (SENSOR_DEFENDER_SWORD_TOPIC, 0),
        (SENSOR_DEFENDER_HAND_TOPIC, 0),
        (SENSOR_ATTACKER_TOPIC, 0)
    ])
    client.loop_start()
    print("[MQTT] Demo is live! WE GOOOD TO GOOOOO!")

    while True:
        topic_input = input(
            "press\n a for attacker\n dh for defender hand \n ds for defender sword\n followed by enter to send random packet to chosen device:")
        chosen_packet = random.randrange(NUM_DEMO_PACKETS)
        topic = topic_input.strip()
        client.publish(
            output_dict[topic],
            json.dumps({"demoIdx": chosen_packet, "tstart": time.time()}),
            qos=0
        )
        print(f"packet sent to {output_dict[topic]}\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Exiting...")
