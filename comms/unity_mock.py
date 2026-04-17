import json
import paho.mqtt.client as mqtt

def on_message(client, userdata, msg):
    gesture = json.loads(msg.payload.decode())
    print("Unity ← Gesture:", gesture)

    if gesture["gesture"] == "SLASH_RIGHT":
        print("Trigger right slash animation")

client = mqtt.Client()
client.connect("localhost", 1883)
client.subscribe("fruitninja/gesture/detected")
client.on_message = on_message

client.loop_forever()
