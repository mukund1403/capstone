import base64
import zlib
import json
import time

FILE_START_TOPIC = "fruitninja/attacker/file/start"
FILE_CHUNK_TOPIC = "fruitninja/attacker/file/chunk"
FILE_END_TOPIC = "fruitninja/attacker/file/end"
FILE_ONE_TIME_TOPIC = "fruitninja/attacker/file/onetime"

# global file transfer state
current_transfer = {
    "file_id": None,
    "filename": None,
    "size": 0,
    "chunk_size": 0,
    "total_chunks": 0,
    "checksum": None,
    "start_time": 0,
    "received_chunks": {},
}

def handle_file_one_time(payload):
    meta = json.loads(payload.decode("utf-8"))
    file_bytes, crc = base64.b64decode(meta["file_stream"]), meta["checksum"]
    
    throughput_stats = calculate_throughput(meta["start_time"], meta["size"])

    # Verify checksum
    calculated_crc = format(zlib.crc32(file_bytes) & 0xffffffff, "08x")

    if calculated_crc != crc:
        print("[FILE] Checksum mismatch")
        return
    
    print(f"calculated crc: {calculated_crc} | received crc: {crc}")

    # Save file
    output_path = f"received_{meta['filename']}"
    with open(output_path, "wb") as f:
        f.write(file_bytes)
    
    print(f"[FILE] Throughput statistics: {throughput_stats}")
    return

def handle_file_start(payload):
    global current_transfer

    meta = json.loads(payload.decode("utf-8"))

    current_transfer = {
        "file_id": meta["file_id"],
        "filename": meta["filename"],
        "size": meta["size"],
        "chunk_size": meta["chunk_size"],
        "total_chunks": meta["total_chunks"],
        "checksum": meta["checksum"],
        "received_chunks": {},
    }

    print(f"[FILE] Start transfer: {meta['filename']} ({meta['size']} bytes) ({meta['total_chunks']} chunks)")
    current_transfer["start_time"] = time.time()

def handle_file_chunk(payload):
    global current_transfer

    msg = json.loads(payload.decode("utf-8"))
    index = msg["index"]
    chunk_data = base64.b64decode(msg["data"])

    current_transfer["received_chunks"][index] = chunk_data

    print(f"[FILE] Received chunk {index}")

def handle_file_end(payload):
    global current_transfer

    throughput_stats = calculate_throughput(current_transfer["start_time"], current_transfer["size"])
    meta = json.loads(payload.decode("utf-8"))
    file_id = meta["file_id"]

    if file_id != current_transfer["file_id"]:
        print("[FILE] File ID mismatch")
        return

    if len(current_transfer["received_chunks"]) != current_transfer["total_chunks"]:
        print("[FILE] Missing chunks")
        return

    # Reassemble file
    file_bytes = b""
    for i in range(current_transfer["total_chunks"]):
        file_bytes += current_transfer["received_chunks"][i]

    # Verify checksum
    calculated_crc = format(zlib.crc32(file_bytes) & 0xffffffff, "08x")

    if calculated_crc != current_transfer["checksum"]:
        print("[FILE] Checksum mismatch")
        return
    
    print(f"calculated crc: {calculated_crc} | received crc: {current_transfer['checksum']}")

    # Save file
    output_path = f"received_{current_transfer['filename']}"
    with open(output_path, "wb") as f:
        f.write(file_bytes)

    print(f"[FILE] Transfer complete. Saved to {output_path}")
    print(f"[FILE] Throughput statistics: {throughput_stats}")

    # Reset state
    current_transfer = {
        "file_id": None,
        "filename": None,
        "size": 0,
        "chunk_size": 0,
        "total_chunks": 0,
        "checksum": None,
        "received_chunks": {},
    }

def calculate_throughput(start_time: float, file_size: bytearray):
    elapsed = time.time() - start_time

    # file_size is a byte array so len gives num bytes
    kbps = ((file_size * 8) / 1000) / elapsed

    return(
        f"time={elapsed:.4f}s | "
        f"throughput={kbps:.2f} kbps"
    )
