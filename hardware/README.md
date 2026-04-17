# FruitAR: FPGA-Accelerated Gesture-Controlled Game

![Real-Time Gesture Recognition](https://img.shields.io/badge/gesture%20recognition-enabled-blue) ![FPGA Accelerated](https://img.shields.io/badge/FPGA-Ultra96-orange) ![AR Game](https://img.shields.io/badge/platform-Unity%20AR-green) ![Python Backend](https://img.shields.io/badge/backend-Python%20MQTT-blueviolet)

A real-time multiplayer AR game system that combines gesture recognition via IMU sensors, FPGA-accelerated machine learning inference, and an interactive mobile AR experience. Three players compete using hand and motion gestures detected by embedded sensors and processed by an Ultra96 FPGA board.

## What This Project Does

**FruitAR** is an end-to-end gesture-controlled gaming platform with three core subsystems:

1. **Mobile AR Game** — Unity-based interactive game with role-based gameplay (Attacker/Defender) using AR image tracking
2. **Real-Time Gesture Recognition** — IMU-based gesture classification via FPGA-accelerated CNN running on Ultra96
3. **Embedded Hardware** — Three ESP32 microcontrollers with IMU sensors collecting acceleration/gyroscope data

The system detects 8 gesture classes in real-time (~10ms latency):
- `idle` · `throw` (attacker) · `block` (defender hand) · `circle` · `z` · `checkmark` · `carat` · `infinity` (defender sword)

## Why This Project Is Useful

- **Complete ML-to-Hardware Pipeline** — From TensorFlow training to FPGA deployment with live inference
- **Real-Time Performance** — FPGA acceleration enables sub-15ms gesture detection at 50 Hz per sensor
- **Modular Architecture** — Independent subsystems for easy extension (new gestures, sensors, or game modes)
- **Production-Ready Integration** — MQTT middleware with TLS security for reliable multi-device communication
- **Educational Reference** — Demonstrates embedded ML, hardware acceleration, and game development integration

## Project Structure Overview

```
FruitARProject/
├── ai/                           # ML training & deployment
│   ├── train_imu_model.py       # Keras CNN training script
│   ├── hls4mlconvert.py         # FPGA conversion utilities
│   ├── convert_to_h_script.py   # Export model weights for HLS
│   └── shape_recognition_model.h5  # Trained model
│
├── comms/                        # Backend services & MQTT infrastructure
│   ├── ultra96_project/         # Ultra96 runtime (inference pipeline)
│   │   ├── main.py              # MQTT listener & gesture classifier
│   │   └── driver.py            # FPGA/DMA abstraction layer
│   ├── mosquitto.conf           # MQTT broker configuration
│   ├── FruitNinjaESP32/         # ESP32 firmware (Arduino)
│   │   ├── imu.cpp              # IMU sensor reading & buffering
│   │   ├── mqtt.h               # MQTT client & messaging
│   │   └── attacker.h / defender_*.h  # Gesture definitions
│   └── README.md                # Detailed comms documentation
│
├── vis/                          # Visualization & game client
│   ├── Assets/Scenes/           # Unity scenes (game, tutorial, menus)
│   ├── Assets/Scripts/          # Game logic & MQTT integration
│   ├── Assets/Mqtt/             # MQTT API wrapper
│   └── README.md                # Game documentation
│
├── data_collection/             # Training dataset
│   ├── attacker_glove_idle/
│   ├── attacker_glove_throw(2)/
│   ├── defender_glove_block(1)/
│   ├── defender_sword_*.../     # Various recorded gestures
│   └── */concat.py              # Data aggregation scripts
│
├── hw_components/               # Hardware prototyping
│   ├── simple_imu_reading.c
│   ├── imu_reading_normalized.c
│   └── simple_vibration.c
│
└── finalized_hardware/          # Final testing of all hardware components (excluding MQTT logic)
    ├── attacker.c
    ├── defender_left.c
    └── defender_right.c
```

## Quick Start

### 1. Game Development (Unity)

**Prerequisites:** Unity Editor 2022.3.62f3 LTS

```bash
# Clone and open project in Unity Hub
# Select FruitARProject root folder
```

**Run in Editor:**
1. Open `Assets/Scenes/FruitStartScene.unity`
2. Press Play
3. Select **Attacker** or **Defender** role

**Build for Android:**
1. File → Build Settings → Switch to Android
2. Enable ARCore and OpenXR in XR Plug-in Management
3. Build and deploy to AR-capable Android device

See [vis/README.md](./vis/README.md) for detailed game documentation.

### 2. Backend Gesture Recognition (Ultra96 + FPGA)

**Prerequisites:** Ultra96 board, Python 3.8+, MQTT broker

```bash
# Install Python dependencies
cd comms/ultra96_project
pip install -r requirements.txt

# Start MQTT broker (separate terminal)
mosquitto -c ../mosquitto.conf

# Run gesture recognition pipeline
python main.py

# In another terminal, monitor system health
python summary.py
```

The pipeline:
1. Subscribes to 3 IMU sensor streams via MQTT
2. Buffers 75-sample windows (1.5 sec at 50 Hz)
3. Transfers normalized window to FPGA via DMA
4. Reads classification logits, applies softmax
5. Publishes confidence-weighted gesture result

See [comms/README.md](./comms/README.md) for detailed backend documentation.

### 3. Hardware & Data Collection (ESP32 + IMU)

**Prerequisites:** ESP32 board, MPU6050 IMU sensor, Arduino IDE

```bash
# Flash firmware to ESP32
cd comms/FruitNinjaESP32
# Open .ino file in Arduino IDE
# Select ESP32 board and USB port
# Click Upload

# Collect training data from three devices:
# Attacker (throw gesture)
# Defender Hand (block gesture)
# Defender Sword (circle, z, checkmark, carat, infinity gestures)
```

Data appears in `data_collection/` folders with timestamps. See [comms/README.md](./comms/README.md) for sensor integration details.

### 4. Hardware Signal Processing (IMU)

Each ESP32 device implements a lightweight real-time signal processing pipeline on raw IMU data before transmission.

**Pipeline Overview:**
1. **Baseline Calibration** — Initial stationary readings are averaged to remove sensor bias
2. **Offset Correction** — All subsequent readings are zero-centered relative to baseline
3. **Low-Pass Filtering** — Exponential smoothing (α = 0.85) reduces noise while preserving motion
4. **Fixed Sampling Rate** — Data is sampled at 50 Hz (20 ms interval)

This produces a consistent **0 → peak → 0 waveform** for each gesture:
- Idle → values ≈ 0  
- Motion → values rise to peak  
- Completion → values return to 0  

This representation ensures:
- Robustness to different starting orientations
- Clear separation between motion and idle states
- Consistent temporal structure for downstream classification

### IMU Processing Pipeline
```
  Raw IMU Data (ax, ay, az, gx, gy, gz)
                  │
                  ▼
      Baseline Calibration (at rest)
                  │
                  ▼
       Offset Correction (zero-centering)
                  │
                  ▼
    Low-Pass Filter (α = 0.85 smoothing)
                  │
                  ▼
       Stable Signal (≈ 0 at idle)
                  │
                  ▼
    Motion Profile (0 → peak → 0 waveform)
                  │
                  ▼
        Ready for ML Inference
```
### 5. Actuator Control Logic (Defender Sword)
The defender sword module provides real-time feedback using an LED, buzzer, and vibration motor. Actuators are triggered based on game events and follow a short burst activation pattern to ensure responsiveness while minimizing power consumption.

### Behaviour Design

- **Success Event**
  - Green LED blink  
  - Fast buzzer tone sequence  
  - Rapid vibration pattern  

- **Failure Event**
  - Red LED blink  
  - Slower buzzer tones  
  - Slower vibration pattern  

### Design Considerations

- **Pulsed activation** avoids continuous current draw  
- **Distinct rhythms** improve user feedback clarity  
- **Short duration signals** prevent interference with IMU readings  
- **Synchronized patterns** (LED + buzzer + motor) enhance user experience  

This design ensures that feedback is immediate, distinguishable, and energy-efficient while maintaining overall system stability.

### Actuation Flow
```
  Event Trigger (e.g. success / failure)
                  │
                  ▼
         Select Feedback Pattern
                  │
                  ▼
    Activate Actuators (LED / Buzzer / Motor)
                  │
                  ▼
    Maintain ON State (short duration)
                  │
                  ▼
           Turn OFF Actuators
```

### 6. Train New Gesture Models

**Prerequisites:** Python 3.8+, TensorFlow 2.20+, HLS4ML

```bash
# Prepare labeled IMU data in data_collection/
# Run training script
python ai/train_imu_model.py

# Export model weights to C++ header for FPGA
python ai/convert_to_h_script.py

# Result: weights.h ready for Vivado HLS synthesis
```

See [ai/README.md](./ai/README.md) for ML pipeline documentation.

## System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    FruitAR System                            │
└──────────────────────────────────────────────────────────────┘

  Physical Layer               Middleware               Application
  ────────────────            ──────────               ──────────

  Attacker ESP32 ─┐
  (MPU6500)       ├─→ MQTT TLS ─→ Mosquitto Broker ─→ Ultra96
                  │    (50 Hz)     (Port 8883)       FPGA CNN
  Defender Hand ──┤   3 topics
  (MPU6050)       │
                  │                                 ↓ Result
  Defender Sword ─┘                            Gesture + Confidence
  (MPU6500)                                         ↓
                                                 MQTT Publish
                                                    ↓
                                              Mobile AR Game
                                              (Unity Android)
                                              [Game Logic]
                                                    ↓
                                            MQTT Control Signal
                                                    ↓
  Defender Sword   ◄────────────────────────────────
  (LED / Buzzer / Motor Feedback)
```

**Key Timings:**
- IMU Sampling: 50 Hz per device (with onboard filtering and zero-centering)
- Window Size: 75 samples (1.5 sec)
- Inference: ~10 ms (FPGA accelerated)
- Network Latency: TLS-encrypted MQTT

## Documentation by Subsystem

- **[ai/README.md](./ai/README.md)** — ML model training, HLS/FPGA conversion, deployment workflow
- **[comms/README.md](./comms/README.md)** — MQTT broker, ESP32 firmware, Ultra96 inference pipeline, troubleshooting
- **[vis/README.md](./vis/README.md)** — Unity game scenes, MQTT integration, AR features, Android build

Each subsystem includes:
- Setup instructions (dependencies, configuration)
- Architecture diagrams
- Build/deployment procedures
- Troubleshooting guides
- Code examples

## Key Features

### Game (Unity AR)
- Role selection UI flow
- AR image tracking (NUS Logo, bomb sprites)
- Real-time fruit spawning and interaction
- Gesture-based score updates via MQTT
- Haptic feedback control (buzzer integration)
- Tutorial scene with gameplay walkthrough

### ML & Inference
- 1D CNN (Conv1D + BatchNorm + MaxPool)
- 8-class gesture classification
- FPGA acceleration on Xilinx Ultra96 (sub-15ms latency)
- Normalized input handling
- Real-time confidence scoring

### Hardware & Communication
- Three independent ESP32 devices with IMU-based motion sensing (MPU6050 / MPU6500)
- 50 Hz IMU sampling with baseline calibration and zero-centering
- Low-pass filtering (α = 0.85) to reduce noise while preserving motion responsiveness
- Gesture signals follow a consistent 0 → peak → 0 temporal profile
- Local preprocessing pipeline (offset correction + filtering) before transmission
- Short-burst actuator control (LED, buzzer, vibration motor) for real-time feedback
- Hardware-side preprocessing reduces noise and improves gesture consistency before ML inference
  
## Development Workflow

1. **Collect Data** → Record IMU sessions for each gesture into `data_collection/`
2. **Train Model** → Run `ai/train_imu_model.py` to create new Keras model
3. **Export Weights** → Convert to C++ header with `ai/convert_to_h_script.py`
4. **Synthesize FPGA** → Use Vivado HLS to generate RTL for new model
5. **Deploy to Ultra96** → Copy bitstream and Python driver to board
6. **Test Live** → Run `comms/ultra96_project/main.py` and monitor with `summary.py`
7. **Iterate** → Refine gestures or collect more training data as needed

## Getting Help

- **Build Issues?** Check [comms/README.md](./comms/README.md#troubleshooting) troubleshooting section
- **Model Questions?** See [ai/README.md](./ai/README.md) for training and conversion details
- **Game Development?** Review [vis/README.md](./vis/README.md) and Unity AR Foundation docs
- **MQTT Setup?** Consult [comms/README.md](./comms/README.md#mqtt-settings) configuration guide
- **Open an Issue** in this repository for bugs or feature requests

## Contributing

Contributions are welcome! To contribute:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/my-gesture`)
3. **Commit** changes with clear messages
4. **Push** to your fork
5. **Submit** a pull request with a description of your changes

Areas for contribution:
- New gesture classes and training data
- Improved FPGA inference pipeline
- Additional game modes or AR interactions
- Documentation improvements
- Hardware optimizations

## License & Attribution

This project is provided for educational and research purposes. Built as a capstone project combining embedded systems, machine learning, and FPGA acceleration.

**Key Technologies:**
- **Game Engine:** Unity 2022.3 LTS with AR Foundation
- **ML Framework:** TensorFlow/Keras
- **FPGA Platform:** Xilinx Ultra96 with PYNQ
- **Embedded Systems:** ESP32 Arduino firmware
- **Communication:** MQTT over TLS, Mosquitto broker
- **Sensors:** Invensense MPU6050/MPU6500 IMUs

**Last Updated:** April 2026

