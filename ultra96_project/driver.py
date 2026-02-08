import time
import random
# import numpy as np
# from pynq import Overlay  # uncomment when real driver is ready


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

    def run(self, input_data):
        time.sleep(0.01) # MUST REMOVE! this is just to simulate delay when predicting

        # Return a random gesture (replace with actual driver output)
        gesture = random.choice(["idle", "wave", "fist", "point"])
        print(f"[Driver] Input: {input_data} -> Gesture: {gesture}")
        return gesture

    def close(self):
        # Cleanup FPGA resources if necessary
        print("[Driver] Closing driver")
