import threading
import serial
from datetime import datetime

PORT = "COM4"      # change if needed
BAUD = 115200

ts = datetime.now().strftime("%Y%m%d_%H%M%S")
outfile = f"imu_log_{ts}.txt"

ser = serial.Serial(PORT, BAUD, timeout=1)

print(f"Connected on {PORT}")
print(f"Saving to {outfile}")
print("Type 1 + Enter to start/stop logging")
print("Type q + Enter to quit")

logging = False

def keyboard():
    while True:
        cmd = input().strip()
        if cmd == "1":
            ser.write(b"1\n")
        elif cmd.lower() == "q":
            ser.write(b"1\n")  # stop logging if active
            break

threading.Thread(target=keyboard, daemon=True).start()

with open(outfile, "w") as f:
    while True:
        line = ser.readline().decode(errors="ignore").strip()
        if not line:
            continue

        print(line)

        if line == "LOG_START":
            logging = True
            continue
        if line == "LOG_STOP":
            logging = False
            f.flush()
            continue

        if logging:
            f.write(line + "\n")
