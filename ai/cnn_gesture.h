#ifndef cnn_gesture
#define cnn_gesture

#include <ap_fixed.h>

#define TIMESTEPS 100 // 100 samples (imu polling at 100Hz)
#define INPUT_FEATURES 6
#define KERNEL_SIZE 3

// Layer 1
#define CONV1_FILTERS 32
#define CONV1_KERNEL 3
#define CONV1_OUTPUT_LEN 100

// Layer 2
#define CONV2_FILTERS 62
#define CONV2_KERNEL 3
#define CONV2_OUTPUT_LEN 50

// Output
#define CLUSTERS 6

typedef ap_fixed<16, 8> fixed16_t; // 16 bit, 8 int 8 fractional bits

struct ModelWeight {
  fixed16_6 conv1_weights[CONV1_FILTERS][];
};

#endif
