import time, json
import paho.mqtt.client as mqtt

client = mqtt.Client()
client.connect("localhost", 1883)

while True:
    imu_window = {
        "ax": [0.1, 0.2, 1.4, 3.2, 5.8, 2.1, 0.4],
        "ay": [0.0, -0.5, -2.3, -4.9, -3.1, -0.8, 0.0],
        "gz": [10, 45, 120, 380, 600, 300, 80],
        "ts": [0, 10, 20, 30, 40, 50, 60]
    }

    client.publish(
        "fruitninja/imu/window",
        json.dumps(imu_window)
    )

    print("ESP32 → IMU window sent")
    time.sleep(1)
