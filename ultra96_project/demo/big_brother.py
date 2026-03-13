import paho.mqtt.client as mqtt
import json
import argparse
import time

from dotenv import load_dotenv
load_dotenv()

# MQTT configuration
BROKER_HOST = "localhost"
BROKER_PORT = 8883
CA_CERT_PATH = "../../ca.crt"

COLOURS = {
    "esp": "\033[92m",     # green
    "ultra": "\033[94m",   # blue
    "unity": "\033[95m",   # magenta 
    "laptop": "\033[93m", # yellow
    "reset": "\033[0m"    # reset to default
}

VERBOSE=False
tstart = 0

def calc_throughput(payload):
    global tstart
    elapsed = time.time() - tstart

    bytes = len(payload)
    kbps = ((bytes * 8) / 1000) / elapsed

    # reset the time so we can calc next throughput
    tstart = time.time()
    
    return f"throughput={kbps:.2f} kbps"

def summarize(arr):
    return f"min={min(arr):.2f} max={max(arr):.2f}"

def pretty_print(topic: str, payload: bytes):
    try:
        data = json.loads(payload.decode())
    except json.JSONDecodeError:
        print("[WARN] Non-JSON payload:", payload)
        return

    topicTree = topic.split("/")
    user = topicTree[1]
    if user == "defender":
        user += f"|{topicTree[2]}"

    throughput = calc_throughput(payload)

    # IMU WINDOW 
    if topic.endswith("/imu/window"):
        colour = COLOURS["esp"]
        if VERBOSE:
            print(f"{colour}[{user.upper()}|ESP] IMU RAW → {json.dumps(data)}{COLOURS['reset']}")
        else:
            print(
                f"{colour}[{user.upper()}|ESP] IMU "
                f"ax[{summarize(data.get('ax', []))}] "
                f"ay[{summarize(data.get('ay', []))}] "
                f"az[{summarize(data.get('az', []))}] "
                f"gx[{summarize(data.get('gx', []))}] "
                f"gy[{summarize(data.get('gy', []))}] "
                f"gz[{summarize(data.get('gz', []))}]\n"
                f"ESP TO ULTRA {throughput}"
                f"{COLOURS['reset']}"
            )
    

    # GESTURE
    elif topic.endswith("/gesture/detected"):
        colour = COLOURS["ultra"]
        print(
            f"{colour}[{user.upper()}|ULTRA] "
            f"gesture={data.get('gesture')} "
            f"conf={data.get('confidence')}.\n"
            f"ULTRA TO UNITY {throughput}"
            f"{COLOURS['reset']}"
        )

    # CONTROL
    elif topic.endswith("/control"):
        colour = COLOURS["unity"]
        print(
            f"{colour}[{user.upper()}|UNITY] "
            f"{data.get('device')} → {data.get('action')}"
            f"{throughput}"
            f"{COLOURS['reset']}"
        )

    # STATUS
    elif topic.endswith("/status"):
        colour = COLOURS["esp"]
        print(
            f"{colour}[{user.upper()}|ESP] STATUS → {data}"
            f"{COLOURS['reset']}"
        )
    
    # DEMO
    elif topic.endswith("/demo"):
        if 'tstart' in data:
            global tstart
            tstart = data['tstart']
        print(
            f"{COLOURS['reset']}[{user.upper()}|DEMO] "
            f"{json.dumps(data)}"
        )
    print("\n")


def on_message(client: mqtt.Client, userdata, msg):
    pretty_print(msg.topic, msg.payload)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Big Brother for Fruit Ninja Capstone"
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose (full JSON) output"
    )
    
    return parser.parse_args()


def main():
    global VERBOSE
    args = parse_args()
    VERBOSE = args.verbose

    # MQTT init stuffs
    client = mqtt.Client(client_id="bigbrother")
    client.tls_set(ca_certs=CA_CERT_PATH)
    client.tls_insecure_set(False)  # helps me verify broker
    client.username_pw_set(username="bigbrother", password="capstone")
    client.on_message = on_message
    client.connect(BROKER_HOST, BROKER_PORT)
    client.subscribe("fruitninja/#")

    print("[MQTT] BIG BROTHER IS WATCHING! View logs from all channels here.")
    if VERBOSE:
        print("Verbose mode enabled!")
    else:
        print("To get full IMU window readings enable verbose mode using -v or --verbose")
    client.loop_forever()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Exiting...")
