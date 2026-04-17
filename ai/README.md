# Capstone Gesture AI Pipeline

This repository contains the AI and FPGA deployment pipeline for a real-time gesture-controlled game built around three IMUs, MQTT messaging, and an Ultra96 board. The system trains a TensorFlow/Keras 1D CNN on labeled IMU windows, exports the trained model into HLS-friendly weights, packages the accelerator as a Vivado IP, and runs live inference on the Ultra96 through PYNQ DMA.

## Project Overview

The AI subsystem classifies fixed-length IMU gesture windows into 8 classes:

- `idle`
- `block`
- `throw`
- `circle`
- `z`
- `checkmark`
- `carat`
- `infinity`

At runtime, three MQTT sensor streams are processed independently:

- defender sword IMU
- defender hand IMU
- attacker IMU

Each stream maintains its own sliding window. Once a full `75 x 6` window is ready, the Ultra96 runtime normalizes the data, transfers it to the FPGA CNN accelerator using AXI DMA, reads back the output logits, applies softmax in Python, and publishes a `(gesture, confidence)` result back to the relevant MQTT topic.

## Repository Structure

### `ai/software/`

Training, evaluation, and model export scripts.

- [`export_model_params_live.py`](./ai/software/export_model_params_live.py)
  Trains the TensorFlow/Keras model, evaluates it, prints the confusion matrix, and exports deployment artifacts.
- [`convert_to_h_script.py`](./ai/software/convert_to_h_script.py)
  Converts the trained Keras model into [`weights.h`](./ai/vitis_hls/weights.h) for the HLS implementation.
- [`best_live_model.h5`](./ai/software/best_live_model.h5)
  Latest saved trained Keras model.
- [`norm_stats.npy`](./ai/software/norm_stats.npy)
  Normalization statistics used again on the Ultra96 at inference time.
- [`reference_input.txt`](./ai/software/reference_input.txt)
  Normalized reference windows for HLS verification.
- [`reference_logits.txt`](./ai/software/reference_logits.txt)
  TensorFlow reference logits for comparison against HLS output.

### `ai/vitis_hls/`

HLS implementation of the CNN and testbench.

- [`cnn_gesture_hls.cpp`](./ai/vitis_hls/cnn_gesture_hls.cpp)
  Fixed-point HLS implementation of the 1D CNN.
- [`testbench.cpp`](./ai/vitis_hls/testbench.cpp)
  HLS verification harness using the exported reference inputs and logits.
- [`weights.h`](./ai/vitis_hls/weights.h)
  Auto-generated weights and folded BatchNorm parameters.

### `ai/ultra96/`

Runtime software for deployed inference on the Ultra96.

- [`main.py`](./ai/ultra96/main.py)
  MQTT runtime: buffers windows, calls the FPGA driver, and publishes gesture detections.
- [`driver.py`](./ai/ultra96/driver.py)
  PYNQ overlay/DMA driver for the CNN accelerator.
- [`run_cnn_dma_test.py`](./ai/ultra96/run_cnn_dma_test.py)
  Board-side DMA test script for debugging/verifying outputs.

### `ai/training/`

Labeled gesture datasets and notes used during collection and retraining.

### `comms stuff/`

Supporting communication-side files such as environment/configuration used alongside the AI runtime.

## Model Summary

The deployed model is a 1D CNN designed for multichannel IMU time-series classification.

- Input shape: `75 x 6`
- Output classes: `8`
- Architecture:
  - `Conv1D`
  - `BatchNorm`
  - `MaxPooling1D`
  - `Conv1D`
  - `BatchNorm`
  - `MaxPooling1D`
  - `Flatten`
  - `Dense`
  - `Dropout` (training only)
  - `Dense` output layer

Why 1D CNN:

- suits `75 x 6` temporal IMU windows
- learns local motion features over time
- simpler and more FPGA-friendly than an RNN
- preserves temporal structure better than flattening directly into an MLP

## Training and Export Flow

The training script performs the following steps:

1. load labeled IMU windows from a text file
2. validate labels and input shape
3. split the dataset into `70 / 15 / 15` train / validation / test
4. optionally apply one of several preprocessing modes
5. compute normalization statistics from the training split only
6. train the model with early stopping and checkpointing
7. optionally run Optuna hyperparameter search
8. evaluate the final model on validation and test data
9. export model and verification artifacts

### Main training command

```powershell
python ai/software/export_model_params_live.py --data "ai/training/7 april/training.txt"
```

### Optional Optuna search

Safe, training-side-only tuning:

```powershell
python ai/software/export_model_params_live.py --data "ai/training/7 april/training.txt" --optuna-trials 20
```

Architecture tuning that may require HLS changes:

```powershell
python ai/software/export_model_params_live.py --data "ai/training/7 april/training.txt" --optuna-trials 20 --optuna-allow-arch-tuning
```

### Exported artifacts from training

Running `export_model_params_live.py` produces four important files:

- `best_live_model.h5`
  Saved Keras model used later by the HLS export script.
- `norm_stats.npy`
  Per-channel normalization statistics used again on the Ultra96 runtime.
- `reference_input.txt`
  Normalized test windows used by the HLS testbench.
- `reference_logits.txt`
  TensorFlow pre-softmax logits used as the golden reference during HLS verification.

## HLS and FPGA Flow

After training:

1. export the trained Keras weights into `weights.h`
2. run Vitis HLS simulation, synthesis, cosimulation, and packaging
3. import or refresh the packaged IP in Vivado
4. upgrade the CNN IP in the block design
5. regenerate outputs and build the bitstream
6. deploy `.bit`, `.hwh`, and `norm_stats.npy` to the Ultra96

### Convert Keras model to HLS weights

```powershell
python ai/software/convert_to_h_script.py
```

### HLS implementation highlights

- fixed-point main data type: `ap_fixed<16,6>`
- wider accumulation type: `ap_fixed<32,12>`
- AXI4-Stream input/output
- AXI-Lite control
- BatchNorm parameters are folded at export time into scale/bias values

### HLS verification

The HLS testbench:

- reads `reference_input.txt`
- runs the accelerator
- compares HLS output with `reference_logits.txt`
- checks class agreement and logit error tolerance

## Ultra96 Runtime Flow

The Ultra96 runtime is split into two layers:

### MQTT / windowing layer

[`ai/ultra96/main.py`](./ai/ultra96/main.py)

- subscribes to IMU topics over MQTT
- maintains one sliding window buffer per IMU stream
- runs inference every time a full window and stride condition are met
- publishes `(gesture, confidence)` to gesture topics

### FPGA inference layer

[`ai/ultra96/driver.py`](./ai/ultra96/driver.py)

- loads the PYNQ overlay
- allocates DMA input/output buffers
- normalizes the `75 x 6` window using `norm_stats.npy`
- converts normalized values into fixed-point-scaled `int16`
- transfers input to the FPGA over AXI DMA MM2S
- reads output logits back over AXI DMA S2MM
- applies softmax in Python
- returns `(gesture, confidence)`

## Preprocessing Notes

The training script currently supports multiple preprocessing modes:

- `none`
- `mean_center`
- `delta`
- `mean_center_delta`

The default mode is `mean_center`.

The deployed runtime normalizes using the saved `mean` and `std` in `norm_stats.npy`. Make sure the board-side runtime and the latest training export remain consistent whenever you retrain the model.

## Typical Deployment Workflow

### 1. Train and export model artifacts

```powershell
python ai/software/export_model_params_live.py --data "ai/training/7 april/training.txt"
```

### 2. Convert model to HLS weights

```powershell
python ai/software/convert_to_h_script.py
```

### 3. Rebuild in Vitis HLS

Run:

- C simulation
- C synthesis
- C/RTL cosimulation
- package

### 4. Rebuild in Vivado

- refresh IP repository
- upgrade the CNN IP in the block design
- validate design
- generate bitstream

### 5. Deploy to Ultra96

Copy:

- `design_1_wrapper.bit`
- matching `design_1_wrapper.hwh`
- `norm_stats.npy`
- updated `main.py` / `driver.py` if needed

## Reported Hardware Characteristics

The exact numbers may vary depending on the latest trained model and bitstream, but recent reported values were approximately:

- test accuracy: `99.19%`
- HLS latency: `~6 ms`
- Vivado utilization:
  - LUT: `~8–11%`
  - FF: `~5%`
  - DSP: `~2%`
  - BRAM: `~82%`
- estimated on-chip power: `~2.0 W`

The main hardware bottleneck is BRAM, not LUT or DSP usage.

## Important Caveats

- The runtime expects the deployed `.bit` and `.hwh` files to have matching basenames.
- Any architectural change to the model, such as filter counts or dense width, must stay aligned with the constants in [`cnn_gesture_hls.cpp`](./ai/vitis_hls/cnn_gesture_hls.cpp).
- Optuna architecture tuning should only be enabled when you are prepared to update and resynthesize the HLS implementation.
- Confidence thresholding and role-based filtering are handled in the Ultra96 runtime, not in the CNN itself.

## Development Notes

Some major refinements made during development include:

- switching from constrained USB-based data collection to more realistic MQTT-based collection
- strengthening the idle class with hard-negative examples and data from all three IMUs
- experimenting with preprocessing methods to improve robustness against orientation and starting-pose variation
- restricting Optuna by default to training-side hyperparameters so retraining does not automatically break HLS compatibility

## Acknowledgements

This repository reflects the AI-side integration work across software training, HLS accelerator implementation, Vivado integration, and Ultra96 runtime deployment for the capstone project.
