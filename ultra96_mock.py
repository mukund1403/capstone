import json
import paho.mqtt.client as mqtt

def on_message(client, userdata, msg):
    imu = json.loads(msg.payload.decode())
    print("Ultra96 ← IMU window received")

    # Fake ML inference
    gesture = {
        "gesture": "SLASH_RIGHT",
        "confidence": 0.91
    }

    client.publish(
        "fruitninja/gesture/detected",
        json.dumps(gesture)
    )

    print("Ultra96 → Gesture published")

client = mqtt.Client()
client.connect("localhost", 1883)
client.subscribe("fruitninja/imu/window")
client.on_message = on_message

client.loop_forever()
