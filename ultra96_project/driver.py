import time
import random
import numpy as np
# from pynq import Overlay  # uncomment when real driver is ready

GESTURE_LABELS = ["idle", "circle", "z", "checkmark", "caret", "infinity"]


class MockPYNQDriver:
    """
    Need to edit this whole file for AI!
    Mock driver simulating ML FPGA inference
    """

    def __init__(self):
        self.initialize()

    def initialize(self):
        # Initialize overlay / IP cores (for the real PYNQ you would load bitstream)
        print("[Driver] Initialized mock PYNQ driver")

    def run(self, window: np.ndarray, window_size):
        """
        Input:  np.ndarray of shape (20, 6) — float32
                columns: [ax, ay, az, gx, gy, gz]
        Output: (gesture: str, confidence: float)

        @jon: replace body of this method only — keep signature identical.
        Real implementation will be roughly:
            input_buffer[:] = window
            dma.sendchannel.transfer(input_buffer)
            dma.recvchannel.transfer(output_buffer)
            dma.sendchannel.wait()
            dma.recvchannel.wait()
            idx = np.argmax(output_buffer)
            return GESTURE_LABELS[idx], float(output_buffer[idx])
        """
        assert window.shape == (
            window_size, 6), f"[Driver] bad input shape: {window.shape}"
        
        # REMOVE FROM HERE FOR THE REAL PYNQ driver
        time.sleep(0.01)  # simulates FPGA latency
        gesture = random.choice(GESTURE_LABELS)
        confidence = round(random.uniform(0.5, 1.0), 2)
        print(f"[Driver] window {window.shape} -> {gesture} ({confidence})")
        return gesture, confidence

    def close(self):
        # Cleanup FPGA resources if necessary
        print("[Driver] Closing driver")
