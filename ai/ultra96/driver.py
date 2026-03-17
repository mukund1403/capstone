import os
import time
from typing import Any, Dict

import numpy as np

try:
    from pynq import Overlay, allocate
except Exception:
    Overlay = None
    allocate = None


SEQ_LEN = 100
FEATURES = 6
NUM_CLASSES = 6
INPUT_LEN = SEQ_LEN * FEATURES

# ap_fixed<16,6> => 10 fractional bits
FIXED_SCALE = 1 << 10
INT16_MIN = -32768
INT16_MAX = 32767

# Update labels to match your training classes
GESTURE_LABELS = [
    "slash1",
    "slash2",
    "slash3",
    "slash4",
    "bomb",
    "slow",
]


def _normalize_input(input_data: Any) -> np.ndarray:
    """
    Convert incoming sensor payload to a flat float32 array of length 600.
    Accepts:
      - list/np.ndarray shape (100,6) or length 600
      - dict with key "data" or "window" containing the above
    """
    if isinstance(input_data, dict):
        if "data" in input_data:
            input_data = input_data["data"]
        elif "window" in input_data:
            input_data = input_data["window"]

    arr = np.array(input_data, dtype=np.float32)
    if arr.size != INPUT_LEN:
        arr = arr.reshape(INPUT_LEN)
    return arr


class PYNQDriver:
    """
    Real driver: runs CNN on Ultra96 and returns gesture + confidence.
    Expects the HLS IP to use ap_fixed<16,6> interface and output logits.
    """

    def __init__(
        self,
        bit_path: str | None = None,
        dma_name: str = "axi_dma_0",
        ip_name: str = "cnn_gesture_top_0",
        download: bool = True,
    ):
        if Overlay is None or allocate is None:
            raise RuntimeError("pynq is not available. Run on Ultra96 with PYNQ.")

        bit_path = bit_path or os.getenv("ULTRA96_BIT")
        if not bit_path:
            raise ValueError("bit_path is required (pass arg or set ULTRA96_BIT env var)")

        self.ol = Overlay(bit_path, download=download)
        self.dma = getattr(self.ol, dma_name)
        self.ip = getattr(self.ol, ip_name)

        self.in_buf = allocate(shape=(INPUT_LEN,), dtype=np.int16)
        self.out_buf = allocate(shape=(NUM_CLASSES,), dtype=np.int16)

    def run(self, input_data: Any) -> Dict[str, float | str]:
        x = _normalize_input(input_data)
        x_fixed = np.clip(np.round(x * FIXED_SCALE), INT16_MIN, INT16_MAX).astype(np.int16)

        self.in_buf[:] = x_fixed
        self.out_buf[:] = 0

        # ap_ctrl_hs start bit
        self.ip.write(0x00, 0x01)

        self.dma.recvchannel.transfer(self.out_buf)
        self.dma.sendchannel.transfer(self.in_buf)
        self.dma.sendchannel.wait()
        self.dma.recvchannel.wait()

        y_fixed = np.array(self.out_buf, dtype=np.int16)
        logits = y_fixed.astype(np.float32) / FIXED_SCALE

        idx = int(np.argmax(logits))
        confidence = float(np.max(logits))
        gesture = GESTURE_LABELS[idx] if idx < len(GESTURE_LABELS) else str(idx)
        return {"gesture": gesture, "confidence": confidence}

    def close(self) -> None:
        self.in_buf.freebuffer()
        self.out_buf.freebuffer()


class MockPYNQDriver:
    """
    Mock driver simulating ML FPGA inference.
    """

    def __init__(self):
        self.initialize()

    def initialize(self) -> None:
        print("[Driver] Initialized mock PYNQ driver")

    def run(self, input_data: Any) -> Dict[str, float | str]:
        time.sleep(0.01)
        idx = int(np.random.randint(0, len(GESTURE_LABELS)))
        gesture = GESTURE_LABELS[idx]
        confidence = float(np.random.uniform(0.6, 0.99))
        print(f"[Driver] Input: {type(input_data)} -> Gesture: {gesture}")
        return {"gesture": gesture, "confidence": confidence}

    def close(self) -> None:
        print("[Driver] Closing driver")
