import threading
import serial
from datetime import datetime

PORT = "COM4"      # change if needed
BAUD = 115200
TARGET_SAMPLES = 75

ts = datetime.now().strftime("%Y%m%d_%H%M%S")
outfile = f"imu_log_{ts}.txt"

ser = serial.Serial(PORT, BAUD, timeout=1)

print(f"Connected on {PORT}")
print(f"Saving to {outfile}")
print(f"Type 1 + Enter to start logging exactly {TARGET_SAMPLES} samples")

logging_active = False
capture_armed = False
stop_sent = False
sample_count = 0

lock = threading.Lock()

def keyboard():
    global capture_armed, logging_active, stop_sent, sample_count

    while True:
        cmd = input().strip()
        if cmd == "1":
            with lock:
                if capture_armed or logging_active:
                    print("Capture already in progress. Wait for it to finish.")
                    continue

                # Clear any stale buffered serial data before starting
                ser.reset_input_buffer()

                capture_armed = True
                logging_active = False
                stop_sent = False
                sample_count = 0

                ser.write(b"1\n")
                print(f"Started capture. Waiting for {TARGET_SAMPLES} samples...")

threading.Thread(target=keyboard, daemon=True).start()

with open(outfile, "w") as f:
    while True:
        raw = ser.readline()
        if not raw:
            continue

        line = raw.decode(errors="ignore").strip()
        if not line:
            continue

        print(line)

        with lock:
            if line == "LOG_START":
                if capture_armed:
                    logging_active = True
                    sample_count = 0
                    stop_sent = False
                    print("LOG_START received. Counting samples now.")
                continue

            if line == "LOG_STOP":
                if capture_armed or logging_active:
                    print(f"Capture finished. Saved {sample_count} samples.")
                capture_armed = False
                logging_active = False
                stop_sent = False
                sample_count = 0
                f.flush()
                continue

            # Only count actual IMU lines while active
            if logging_active and sample_count < TARGET_SAMPLES:
                f.write(line + "\n")
                sample_count += 1

                if sample_count == TARGET_SAMPLES and not stop_sent:
                    ser.write(b"1\n")   # tell hardware to stop
                    stop_sent = True
                    logging_active = False   # stop saving extras immediately
                    f.flush()
                    print(f"Reached {TARGET_SAMPLES} samples. Stop command sent.")

# 0 = idle
# 1 = defender block
# 2 = attacker throw bomb
# 3 = defender slice circle