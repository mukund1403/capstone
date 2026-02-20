#include <iostream>
#include <cmath>
#include <ap_fixed.h>

#define SEQ_LENGTH 100
#define FEATURES 6
#define NUM_CLASSES 6

typedef ap_fixed<16, 6> data_t;

// Top function declaration from cnn_gesture_hls.cpp
void cnn_gesture_top(
    data_t input[SEQ_LENGTH][FEATURES],
    data_t output[NUM_CLASSES]
);

static int argmax(const data_t v[NUM_CLASSES]) {
    int idx = 0;
    data_t best = v[0];
    for (int i = 1; i < NUM_CLASSES; i++) {
        if (v[i] > best) {
            best = v[i];
            idx = i;
        }
    }
    return idx;
}

static bool sanity_check_probs(const data_t probs[NUM_CLASSES]) {
    float sum = 0.0f;
    for (int i = 0; i < NUM_CLASSES; i++) {
        float p = (float)probs[i];
        if (std::isnan(p) || std::isinf(p)) return false;
        if (p < -1e-3f || p > 1.001f) return false;
        sum += p;
    }
    return (std::fabs(sum - 1.0f) < 0.15f);
}

int main() {
    data_t input[SEQ_LENGTH][FEATURES];
    data_t output[NUM_CLASSES];

    // Case 1: all zeros
    for (int t = 0; t < SEQ_LENGTH; t++) {
        for (int c = 0; c < FEATURES; c++) {
            input[t][c] = 0;
        }
    }

    cnn_gesture_top(input, output);

    std::cout << "Case 1 (zero input) probs: ";
    for (int i = 0; i < NUM_CLASSES; i++) {
        std::cout << (float)output[i] << " ";
    }
    std::cout << " | pred=" << argmax(output) << std::endl;

    if (!sanity_check_probs(output)) {
        std::cerr << "FAIL: Case 1 probability sanity check failed." << std::endl;
        return 1;
    }

    // Case 2: simple synthetic motion pulse (generic)
    for (int t = 0; t < SEQ_LENGTH; t++) {
        for (int c = 0; c < FEATURES; c++) {
            input[t][c] = 0;
        }

        if (t >= 35 && t < 45) {
            input[t][0] = (data_t)0.8;  // acc_x pulse
            input[t][3] = (data_t)0.6;  // gyro_x pulse
        }
    }

    cnn_gesture_top(input, output);

    std::cout << "Case 2 (pulse input) probs: ";
    for (int i = 0; i < NUM_CLASSES; i++) {
        std::cout << (float)output[i] << " ";
    }
    std::cout << " | pred=" << argmax(output) << std::endl;

    if (!sanity_check_probs(output)) {
        std::cerr << "FAIL: Case 2 probability sanity check failed." << std::endl;
        return 2;
    }

    std::cout << "PASS: Testbench completed." << std::endl;
    return 0;
}
