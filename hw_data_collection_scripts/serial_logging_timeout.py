import threading
import serial
from datetime import datetime

PORT = "COM4"      # change if needed
BAUD = 115200
TARGET_SAMPLES = 75

ts = datetime.now().strftime("%Y%m%d_%H%M%S")
outfile = f"imu_log_{ts}.csv"

ser = serial.Serial(PORT, BAUD, timeout=1)

print(f"Connected on {PORT}")
print(f"Saving to {outfile}")
print(f"Type 1 + Enter to start logging exactly {TARGET_SAMPLES} lines")

logging_active = False
sample_count = 0

lock = threading.Lock()


def keyboard():
    global logging_active, sample_count

    while True:
        cmd = input().strip()

        if cmd == "1":
            with lock:
                if logging_active:
                    print("Capture already in progress. Wait for it to finish.")
                    continue

                # Clear old serial data so capture starts fresh from now
                ser.reset_input_buffer()

                logging_active = True
                sample_count = 0
                print(f"Started logging. Capturing exactly {TARGET_SAMPLES} lines...")


threading.Thread(target=keyboard, daemon=True).start()

with open(outfile, "w", newline="") as f:
    while True:
        raw = ser.readline()
        if not raw:
            continue

        line = raw.decode(errors="ignore").strip()
        if not line:
            continue

        with lock:
            if not logging_active:
                continue

            # Save whatever comes in after typing 1
            print(line)
            f.write(line + "\n")
            sample_count += 1

            if sample_count >= TARGET_SAMPLES:
                logging_active = False
                f.flush()
                print(f"Capture finished. Saved {sample_count} lines to {outfile}")