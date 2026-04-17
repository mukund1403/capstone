import paho.mqtt.client as mqtt
import zlib
import json
import os
import base64
import time

from dotenv import load_dotenv
load_dotenv()

# MQTT configuration
BROKER_HOST = "localhost"
BROKER_PORT = 8883
FILE_ONE_TIME_TOPIC = "fruitninja/attacker/file/onetime"
FILE_START_TOPIC = "fruitninja/attacker/file/start"
FILE_CHUNK_TOPIC = "fruitninja/attacker/file/chunk"
FILE_END_TOPIC = "fruitninja/attacker/file/end"
CA_CERT_PATH = "../../ca.crt"

CHUNK_SIZE = 200_000_000

"""
CRC Error Checking - Undetected Errors
In general, bit errors and bursts up to N-bits long will be detected for a P(x) of degree N. For arbitrary bit errors longer than N-bits, the odds are one in 2N than a totally false bit pattern will nonetheless lead to a zero remainder.

In essence, 100% detection is assured for all errors E(x) not an exact multiple of P(x). For a 16-bit CRC using a primitive P(x) this means:

100% detection of single-bit errors;
100% detection of all adjacent double-bit errors;
100% detection of all burst errors spanning up to 16-bits;
100% detection of all two-bit errors not separated by exactly 216-1 bits (this means all two bit errors in practice!);
For arbitrary multiple errors spanning more than 16 bits, at worst 1 in 216 failures, which is nonetheless over 99.995% detection rate.

Source: https://www.ece.unb.ca/tervo/ece4253/crc.shtml#:~:text=CRC%20Error%20Checking%20%2D%20Undetected%20Errors&text=In%20general%2C%20bit%20errors%20and,lead%20to%20a%20zero%20remainder.
"""
# 32 bit crc
def crc32(data: bytes) -> str:
    return format(zlib.crc32(data) & 0xffffffff, "08x") # 0xff.. ensures that our CRC is always treated as unsigned integer cos zlib can return signed

def send_start(client: mqtt.Client, filepath: str):
    with open(filepath, "rb") as f:
        data = f.read()

    size = len(data)
    total_chunks = (size + CHUNK_SIZE - 1) // CHUNK_SIZE

    start_msg = {
        "file_id": os.path.basename(filepath),
        "filename": os.path.basename(filepath),
        "size": size,
        "chunk_size": CHUNK_SIZE,
        "total_chunks": total_chunks,
        "start_time": time.time(),
        "checksum": crc32(data)
    }

    if size < 256_000_000:
        client.publish(
            FILE_ONE_TIME_TOPIC,
            json.dumps({"file_stream":base64.b64encode(data).decode(), **start_msg}),
            qos=1
        )
        return True, b""

    client.publish(
        FILE_START_TOPIC,
        json.dumps(start_msg),
        qos=1
    )

    return False, data


def send_chunks(client: mqtt.Client, data: bytes):
    for i in range(0, len(data), CHUNK_SIZE):
        chunk = data[i:i + CHUNK_SIZE]

        msg = {
            "index": i // CHUNK_SIZE,
            "data": base64.b64encode(chunk).decode()
        }

        client.publish(
            FILE_CHUNK_TOPIC,
            json.dumps(msg),
            qos=1
        )

def send_end(client: mqtt.Client, file_id: str):
    client.publish(
        FILE_END_TOPIC,
        json.dumps({"file_id": file_id}),
        qos=1
    )

def send_file(client, filepath: str):
    print(f"Sending {filepath}...")

    is_one_shot, data = send_start(client, filepath)
    if is_one_shot:
        return
    send_chunks(client, data)
    send_end(client, os.path.basename(filepath))

    print("Done.")

def main():
    client = mqtt.Client(client_id="demo")
    client.tls_set(ca_certs=CA_CERT_PATH)
    client.tls_insecure_set(False)  # helps me verify broker
    client.username_pw_set(username="demo", password="capstone")
    client.connect(BROKER_HOST, BROKER_PORT)
    client.loop_start()

    while True:
        input("Press enter to send file")
        send_file(client, "AY2223_CEG1-Recommended-Schedule-Direct-1.pdf")
        # send_file(client, "IMG_1548.MOV")
        # send_file(client, "UnityHubSetup-arm64.dmg")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("Exiting...")
