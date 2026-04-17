import paho.mqtt.client as mqtt
import json
import time
import curses
import threading
from dotenv import load_dotenv
load_dotenv()

BROKER_HOST = "localhost"
BROKER_PORT = 8883
CA_CERT_PATH = "../ca.crt"

PLAYERS = ["attacker", "defender|sword", "defender|hand"]

# --- Shared state (updated by MQTT thread, read by display thread) ---
stats = {
    p: {
        "status":        "unknown",
        "imu_count":     0,          # total IMU messages received
        "imu_per_sec":   0.0,        # rolling messages/sec
        "imu_last_sec":  0,          # count in current second window
        "imu_window_ts": time.time(),
        "gesture_total": 0,
        "gesture_last":  "—",
        "confidence_last": 0.0,
        "confidence_avg":  0.0,
        "confidence_sum":  0.0,
        "control_count": 0,
        "control_last":  "—",
    }
    for p in PLAYERS
}
stats_lock = threading.Lock()


def topic_to_player(topic: str) -> str | None:
    """fruitninja/defender/sword/... → 'defender|sword' etc."""
    parts = topic.split("/")
    if len(parts) < 3:
        return None
    if parts[1] == "defender":
        return f"defender|{parts[2]}"
    return parts[1]


def on_message(client, userdata, msg):
    topic = msg.topic
    player = topic_to_player(topic)
    if player not in stats:
        return

    payload_str = msg.payload.decode()

    # Handle plain-string status BEFORE attempting JSON parse
    if topic.endswith("/status"):
        with stats_lock:
            stats[player]["status"] = payload_str
        return

    try:
        data = json.loads(payload_str)
    except Exception:
        return

    now = time.time()
    with stats_lock:
        s = stats[player]

        if topic.endswith("/imu/stream") or topic.endswith("/imu/window"):
            s["imu_count"] += 1
            s["imu_last_sec"] += 1
            # rolling per-sec calc
            elapsed = now - s["imu_window_ts"]
            if elapsed >= 1.0:
                s["imu_per_sec"] = s["imu_last_sec"] / elapsed
                s["imu_last_sec"] = 0
                s["imu_window_ts"] = now

        elif topic.endswith("/gesture/detected"):
            s["gesture_total"] += 1
            s["gesture_last"] = data.get("gesture", "?")
            conf = float(data.get("confidence", 0))
            s["confidence_last"] = conf
            s["confidence_sum"] += conf
            s["confidence_avg"] = s["confidence_sum"] / s["gesture_total"]

        elif topic.endswith("/control"):
            s["control_count"] += 1
            s["control_last"] = f"{data.get('device')}:{data.get('action')}"


def draw(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.init_pair(1, curses.COLOR_GREEN,   curses.COLOR_BLACK)  # online
    curses.init_pair(2, curses.COLOR_RED,     curses.COLOR_BLACK)  # offline
    curses.init_pair(3, curses.COLOR_CYAN,    curses.COLOR_BLACK)  # header
    curses.init_pair(4, curses.COLOR_YELLOW,  curses.COLOR_BLACK)  # values

    COL_W = 22
    REFRESH = 1  # seconds

    while True:
        stdscr.erase()
        now_str = time.strftime("%H:%M:%S")

        # --- Header ---
        stdscr.addstr(0, 0, f"FRUIT NINJA — SYSTEM DASHBOARD   {now_str}", curses.color_pair(3) | curses.A_BOLD)
        stdscr.addstr(1, 0, "─" * (COL_W * (len(PLAYERS) + 1)))

        # Column headers
        stdscr.addstr(2, 0, f"{'':20}", curses.A_BOLD)
        with stats_lock:
            for i, p in enumerate(PLAYERS):
                stdscr.addstr(2, 20 + i * COL_W, f"{p:^{COL_W}}", curses.color_pair(3) | curses.A_BOLD)

        stdscr.addstr(3, 0, "─" * (COL_W * (len(PLAYERS) + 1)))

        rows = [
            ("Status",          lambda s: s["status"]),
            ("IMU msg/sec",     lambda s: f"{s['imu_per_sec']:.1f}"),
            ("IMU total",       lambda s: str(s["imu_count"])),
            ("Gestures total",  lambda s: str(s["gesture_total"])),
            ("Last gesture",    lambda s: s["gesture_last"]),
            ("Last confidence", lambda s: f"{s['confidence_last']:.2f}"),
            ("Avg confidence",  lambda s: f"{s['confidence_avg']:.2f}"),
            ("Control total",   lambda s: str(s["control_count"])),
            ("Last control",    lambda s: s["control_last"]),
        ]

        with stats_lock:
            for row_i, (label, fn) in enumerate(rows):
                stdscr.addstr(4 + row_i, 0, f"{label:20}", curses.A_BOLD)
                for col_i, p in enumerate(PLAYERS):
                    s = stats[p]
                    val = fn(s)
                    # colour status specially
                    if label == "Status":
                        colour = curses.color_pair(1) if val == "online" or val == "resumed" else curses.color_pair(2)
                    else:
                        colour = curses.color_pair(4)
                    stdscr.addstr(4 + row_i, 20 + col_i * COL_W, f"{val:^{COL_W}}", colour)

        stdscr.addstr(4 + len(rows), 0, "─" * (COL_W * (len(PLAYERS) + 1)))
        stdscr.addstr(5 + len(rows), 0, "ctrl+c to exit", curses.color_pair(3))
        stdscr.refresh()
        time.sleep(REFRESH)


def main():
    client = mqtt.Client(client_id="summary")
    client.tls_set(ca_certs=CA_CERT_PATH)
    client.tls_insecure_set(False)
    client.username_pw_set(username="bigbrother", password="capstone")
    client.on_message = on_message
    client.connect(BROKER_HOST, BROKER_PORT)
    client.subscribe("fruitninja/#")
    client.loop_start()  # runs MQTT in background thread

    try:
        curses.wrapper(draw)  # blocks, runs display in main thread
    except KeyboardInterrupt:
        pass
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()