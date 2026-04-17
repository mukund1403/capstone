# COMMS FOR: Fruit Ninja, FPGA-Accelerated Gesture Recognition Game

![Gesture Recognition](https://img.shields.io/badge/gesture%20recognition-enabled-blue) ![FPGA Accelerated](https://img.shields.io/badge/FPGA-Ultra96-orange) ![Real--Time](https://img.shields.io/badge/latency-%7E10ms-green)

A real-time multiplayer gesture recognition gaming system that combines embedded sensors, FPGA acceleration, and machine learning inference at the edge. Three players control a competitive Fruit Ninja game using hand and motion gestures detected by IMU sensors and processed by an FPGA-accelerated CNN.

## Features

- 🎮 **Multiplayer Gesture Control**: Three-player competitive gameplay (2 defenders vs 1 attacker) controlled by hand gestures
- ⚡ **FPGA Acceleration**: ~10ms CNN inference using Xilinx HLS on Ultra96 FPGA for responsive gameplay
- 📡 **Real-Time MQTT Communication**: Encrypted over TLS with certificate-based authentication
- 🧠 **8 Gesture Classes**: idle, block, throw, circle, z, checkmark, carat, infinity
- 📊 **Multi-Sensor Fusion**: 3 independent ESP32s with distributed IMU sensors (MPU6050/MPU6500)
- 🔐 **Secure**: TLS-encrypted MQTT broker with credential validation
- 🧪 **Comprehensive Testing**: Mock modules for development without hardware, data collection utilities, and monitoring tools

## Project Structure

```
CAPSTONE/
├── FruitNinjaESP32/           # ESP32 firmware (Arduino)
│   ├── FruitNinjaESP32.ino    # Main firmware entry
│   ├── actuators.cpp/h        # Motor/LED control
│   ├── imu.cpp                # Sensor reading & buffering
│   ├── mqtt.h                 # MQTT client setup
│   ├── attacker.h             # Attacker gesture definitions
│   ├── defender_hand.h        # Defender hand gesture definitions
│   └── defender_sword.h       # Defender sword gesture definitions
│
├── ultra96_project/           # Backend (Python/FPGA)
│   ├── main.py                # Real-time gesture recognition pipeline
│   ├── driver.py              # FPGA hardware abstraction
│   ├── training.py            # Interactive gesture data collection
│   ├── summary.py             # Live system monitoring
│   ├── requirements.txt       # Python dependencies
│   └── demo/
│       ├── big_brother.py     # MQTT traffic analyzer
│       ├── file_transfer.py   # MQTT file transfer protocol
│       └── initiator.py       # Game session management
│
├── mosquitto.conf             # MQTT broker configuration
├── passwordfile               # MQTT credentials
├── ca.srl                      # Certificate authority serial
├── esp32_mock.py              # Simulates ESP32 devices
├── unity_mock.py              # Simulates game client
└── send_imu.sh                # Synthetic data generator for testing
```

## How It Works

### System Architecture

Three ESP32 microcontrollers collect accelerometer/gyroscope data at ~50 Hz from IMU sensors and publish to an MQTT broker over encrypted TLS:

```
Attacker (1× MPU6050)
    ↓
    MQTT: fruitninja/attacker/imu/window
         ↓
Defender Hand (3× MPU6050/MPU6500) → MQTT: fruitninja/defender/hand/imu/window
    ↓
Defender Sword (1× MPU6050) → MQTT: fruitninja/defender/sword/imu/window
         ↓
    ┌────────────────────────────┐
    │   Ultra96 Backend (main.py) │
    │  • Buffers sensor windows   │
    │  • Batches for inference    │
    └────────────────┬───────────┘
                     ↓
    ┌────────────────────────────┐
    │ FPGA CNN Accelerator       │
    │ (driver.py + HLS IP)       │
    │ ~10ns inference latency    │
    └────────────────┬───────────┘
                     ↓
    ┌────────────────────────────┐
    │ Detected Gestures          │
    │ + Confidence Scores        │
    └────────────────┬───────────┘
                     ↓
         MQTT: fruitninja/{player}/gesture/detected
                     ↓
              Game Client (Unity)
```

### Gesture Recognition Pipeline

1. **Sensor Collection**: Each device collects 75 samples (1.5 seconds at 50 Hz) of 6-axis IMU data (accel + gyro)
2. **Feature Packaging**: Sends sensor window via MQTT to backend
3. **Normalization**: Ultra96 normalizes using pre-computed mean/std statistics
4. **Hardware Inference**: Custom CNN on FPGA processes normalized window in ~10 ms
5. **Validation**: Backend applies gesture rules (e.g., only attacker can throw) then publishes result
6. **Game Update**: Game client receives gesture event and updates game state

## Getting Started

### Prerequisites

- **Hardware**:
  - 3× ESP32 microcontrollers with integrated WiFi
  - 3-4× MPU6050 or MPU6500 IMU sensors
  - Xilinx Ultra96 FPGA board (or mock driver for testing)
  - Optional: Vibration motors, buzzers, RGB LEDs, buttons for actuators

- **Software**:
  - Arduino IDE with ESP32 board support
  - Python 3.8+
  - PYNQ framework (for FPGA) or mock for development
  - Mosquitto MQTT broker

### Installation

#### 1. Set Up MQTT Broker

```bash
# Install Mosquitto (macOS)
brew install mosquitto

# Or on Linux:
# sudo apt-get install mosquitto

# Copy configuration and start broker
cp mosquitto.conf /path/to/mosquitto/config/
cp passwordfile /path/to/mosquitto/config/
mosquitto -c mosquitto.conf
```

MQTT will listen on port 8883 with TLS. Default credentials: `esp32` / `capstone`

#### 2. Set Up Ultra96 Backend

```bash
# Install dependencies
cd ultra96_project
pip install -r requirements.txt

# Start the gesture recognition pipeline
python main.py

# In a separate terminal, monitor system performance
python summary.py
```

- **main.py**: Subscribes to sensor topics, runs inference, publishes gestures
- **summary.py**: Real-time dashboard showing sensor rates, gesture confidences, and system health

#### 3. Flash ESP32 Firmware

```bash
# Open Arduino IDE and load FruitNinjaESP32.ino
# Configure WiFi SSID/password in secrets.h
# Select ESP32 board and flash each device

# Three different firmware instances needed:
# - Device 1: Attacker sensor + wireless, no actuators
# - Device 2: Defender hand sensor + actuators (vibro, buzzer, LED, button)
# - Device 3: Defender sword sensor + actuators
```

#### 4. Test Without Hardware (Mock Mode)

For development and testing without physical devices:

```bash
# Terminal 1: Start MQTT broker
mosquitto -c mosquitto.conf

# Terminal 2: Start backend pipeline
cd ultra96_project
python main.py

# Terminal 3: Simulate 3 ESP32 devices
python ../esp32_mock.py

# Terminal 4: Monitor gesture events (optional)
cd ultra96_project/demo
python big_brother.py
```

### Usage Example

Once all components are running, the system continuously:

1. Receives IMU sensor streams from 3 devices via MQTT
2. Buffers 75-sample windows and sends to FPGA for inference
3. Publishes detected gestures with confidence scores to MQTT output topics
4. Game client listens to gesture topics and updates gameplay

To send synthetic data for testing:

```bash
# Generate and publish test IMU data
./send_imu.sh
```

## Building ML Models

Collect and train custom gesture recognition models:

```bash
# Interactive gesture collection mode
cd ultra96_project
python training.py

# Prompts to:
# - Select player (attacker/hand/sword)
# - Record gesture label
# - Collect sensor windows into training.txt
# - Repeat to build training dataset

# Train CNN on collected data
python training.py --train training.txt --output model.h5
```

The trained model must be quantized to `ap_fixed<16,6>` format and synthesized into FPGA using Xilinx HLS.

## Monitoring & Debugging

### Real-Time System Monitor

```bash
cd ultra96_project
python summary.py
```

Displays live:
- Sensor message rate (msg/sec) per player
- Window buffering progress
- Gesture detection confidence scores
- System health and inference latency

### Network Traffic Analysis

```bash
cd ultra96_project/demo
python big_brother.py
```

Color-coded MQTT message analysis with latency measurements.

## Configuration

### MQTT Settings

Edit `mosquitto.conf`:
- **Port**: 8883 (default TLS)
- **User**: `esp32`
- **Password**: `capstone`
- **CA Certificate**: `ca.srl`

Change in `mosquitto.conf` and `passwordfile` if using external broker.

### Inference Batching

In `ultra96_project/main.py`, adjust:
- **Window size**: 75 samples × 6 features (configurable)
- **Batch size**: Number of windows before triggering inference
- **Sample rate**: 50 Hz per device (adjustable in firmware)

### Gesture Classes

Edit gesture definitions in ESP32 firmware:
- `attacker.h`: Throw only
- `defender_hand.h`: Block only
- `defender_sword.h`: Circle, z, checkmark, carat, infinity

## Architecture Details

### ESP32 Firmware

Each device:
- Samples IMU at 50 Hz (I2C or SPI depending on sensor)
- Buffers into 75-sample windows (1.5 sec)
- Publishes via MQTT TLS to broker
- Receives inference results and controls actuators

### Ultra96 Backend

Python pipeline:
- **main.py**: Subscribes to 3 sensor topics, maintains ring buffers, triggers FPGA calls, publishes results
- **driver.py**: Abstracts FPGA hardware with normalization, DMA transfer, softmax conversion
  - **PYNQDriver**: Real FPGA inference via Xilinx PYNQ Python API
  - **MockPYNQDriver**: Simulated inference for testing without hardware

### FPGA Accelerator

Custom CNN IP (Xilinx HLS):
- Input: 75 × 6 fixed-point array (ap_fixed<16,6>)
- Processing: 3-5 layer CNN with batch normalization
- Output: 8 logits (one per gesture class)
- Latency: ~10 ms per inference

## Troubleshooting

### Sensor Connection Issues

```bash
# Verify I2C/SPI connections
# Check ESP32 serial output for MPU initialization errors
# Confirm I2C address (0x68 for MPU6050, 0x69 with AD0 high)
```

### MQTT Connection Failures

```bash
# Test broker connectivity
mosquitto_pub -h localhost -p 8883 --cafile ca.crt -u esp32 -P capstone -t test -m "hello"

# Check encrypted port is open
netstat -an | grep 8883

# Verify certificate authentication
openssl s_client -connect localhost:8883 -cert client.crt -key client.key -CAfile ca.crt
```

### No Gesture Recognition

- Verify all 3 ESP32s are publishing IMU data: `mosquitto_sub -h localhost -p 8883 -u esp32 -P capstone -t 'fruitninja/+/imu/window'`
- Check `main.py` is running and connected to broker
- Review inference confidence scores in `summary.py` output
- Collect more training data for underperforming gestures

### Latency Issues

- Reduce window size or batch size in `main.py`
- Profile FPGA inference with timing measurements in `driver.py`
- Check MQTT network bandwidth (`big_brother.py`)

## Support & Documentation

- **Hardware Setup**: See comments in `FruitNinjaESP32/*.h` for pin mappings and sensor initialization
- **ML Training**: Review `ultra96_project/training.py` docstrings for data collection workflow
- **FPGA Workflow**: Xilinx PYNQ documentation for synthesizing custom HLS IP cores
- **MQTT Protocol**: Mosquitto documentation for broker configuration and authentication

## Contributing

Contributions welcome! Areas for enhancement:
- Additional gesture classes
- Improved CNN architecture for faster inference
- Multi-region deployment with broker federation
- Game UI implementation (currently mocked)
- Wireless sensor synchronization techniques
- Robustness testing across player sizes/movement styles

## License

This project is provided as-is for educational and research purposes.

## Authors & Acknowledgments

- **Core Team**: Graduate research project combining embedded systems, ML, and FPGA acceleration
- **Hardware**: Xilinx Ultra96, ESP32, Invensense MPU6050/MPU6500 sensors
- **Frameworks**: Arduino, PYNQ, Mosquitto, TensorFlow (training backend)

---

**Last Updated**: April 2026  
**Status**: Active Development
