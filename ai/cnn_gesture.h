// gesture_model.h - ONLY the architecture, NO weights!
#ifndef GESTURE_MODEL_H
#define GESTURE_MODEL_H

#include <ap_fixed.h>

// ========== MODEL CONFIGURATION ==========
// MUST match your Python model!
#define INPUT_TIMESTEPS 100    // 100 samples
#define INPUT_FEATURES 6       // 6 IMU channels

// Layer 1: Conv1D
#define CONV1_FILTERS 32       // 32 filters
#define CONV1_KERNEL 3         // kernel_size=3
#define POOL1_SIZE 2           // pool_size=2

// Layer 2: Conv1D  
#define CONV2_FILTERS 64       // 64 filters
#define CONV2_KERNEL 3         // kernel_size=3
#define POOL2_SIZE 2           // pool_size=2

// Layer 3: Dense
#define DENSE1_UNITS 128       // 128 units

// Layer 4: Output
#define OUTPUT_UNITS 6         // 6 gestures

// ========== DATA TYPES ==========
typedef ap_fixed<16, 6> fixed16_t;  // 16-bit fixed point

// ========== FUNCTION DECLARATION ==========
void gesture_recognition_top(
    fixed16_t imu_data[INPUT_FEATURES],
    fixed16_t predictions[OUTPUT_UNITS],
    bool start_new_gesture,
    bool& prediction_ready
);

#endif