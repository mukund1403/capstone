#include <ap_fixed.h>
#include <hls_math.h>
#include "weights.h"

// Model dimensions (must match your Python model)
#define SEQ_LENGTH 100
#define FEATURES 6
#define CONV1_FILTERS 32
#define CONV2_FILTERS 64
#define DENSE1_UNITS 128
#define NUM_CLASSES 6
#define KERNEL_SIZE 3
#define BN_EPS 0.001f

typedef ap_fixed<16, 6> data_t;
typedef ap_fixed<32, 12> acc_t;

static inline data_t relu(data_t x) {
    return (x > 0) ? x : (data_t)0;
}

// Index helpers for flattened Keras tensors
// Conv kernel shape in Keras: [kernel, in_channels, out_channels]
static inline int conv_index(int k, int c, int f, int in_ch, int out_ch) {
    return (k * in_ch + c) * out_ch + f;
}

// Dense kernel shape in Keras: [in_dim, out_dim]
static inline int dense_index(int i, int o, int out_dim) {
    return i * out_dim + o;
}

static void conv1_block(
    data_t input[SEQ_LENGTH][FEATURES],
    data_t output[SEQ_LENGTH][CONV1_FILTERS]
) {
#pragma HLS INLINE

    for (int t = 0; t < SEQ_LENGTH; t++) {
        for (int f = 0; f < CONV1_FILTERS; f++) {
            acc_t sum = 0;

            for (int k = 0; k < KERNEL_SIZE; k++) {
                int idx = t + k - 1; // padding='same'
                if (idx >= 0 && idx < SEQ_LENGTH) {
                    for (int c = 0; c < FEATURES; c++) {
                        int wi = conv_index(k, c, f, FEATURES, CONV1_FILTERS);
                        sum += input[idx][c] * (data_t)conv1d_param_0[wi];
                    }
                }
            }

            // Conv bias
            sum += (data_t)conv1d_param_1[f];

            // Keras Conv1D has activation='relu'
            data_t act = relu((data_t)sum);

            // BatchNorm (inference): gamma * (x-mean)/sqrt(var+eps) + beta
            data_t gamma = (data_t)batch_normalization_param_0[f];
            data_t beta = (data_t)batch_normalization_param_1[f];
            data_t mean = (data_t)batch_normalization_param_2[f];
            data_t var = (data_t)batch_normalization_param_3[f];

            data_t norm = (act - mean) / (data_t)hls::sqrt((float)(var + (data_t)BN_EPS));
            output[t][f] = gamma * norm + beta;
        }
    }
}

static void maxpool1(
    data_t input[SEQ_LENGTH][CONV1_FILTERS],
    data_t output[SEQ_LENGTH / 2][CONV1_FILTERS]
) {
#pragma HLS INLINE

    for (int t = 0; t < SEQ_LENGTH / 2; t++) {
        for (int f = 0; f < CONV1_FILTERS; f++) {
            data_t a = input[t * 2][f];
            data_t b = input[t * 2 + 1][f];
            output[t][f] = (a > b) ? a : b;
        }
    }
}

static void conv2_block(
    data_t input[SEQ_LENGTH / 2][CONV1_FILTERS],
    data_t output[SEQ_LENGTH / 2][CONV2_FILTERS]
) {
#pragma HLS INLINE

    for (int t = 0; t < SEQ_LENGTH / 2; t++) {
        for (int f = 0; f < CONV2_FILTERS; f++) {
            acc_t sum = 0;

            for (int k = 0; k < KERNEL_SIZE; k++) {
                int idx = t + k - 1; // padding='same'
                if (idx >= 0 && idx < SEQ_LENGTH / 2) {
                    for (int c = 0; c < CONV1_FILTERS; c++) {
                        int wi = conv_index(k, c, f, CONV1_FILTERS, CONV2_FILTERS);
                        sum += input[idx][c] * (data_t)conv1d_1_param_0[wi];
                    }
                }
            }

            sum += (data_t)conv1d_1_param_1[f];
            data_t act = relu((data_t)sum);

            data_t gamma = (data_t)batch_normalization_1_param_0[f];
            data_t beta = (data_t)batch_normalization_1_param_1[f];
            data_t mean = (data_t)batch_normalization_1_param_2[f];
            data_t var = (data_t)batch_normalization_1_param_3[f];

            data_t norm = (act - mean) / (data_t)hls::sqrt((float)(var + (data_t)BN_EPS));
            output[t][f] = gamma * norm + beta;
        }
    }
}

static void maxpool2(
    data_t input[SEQ_LENGTH / 2][CONV2_FILTERS],
    data_t output[SEQ_LENGTH / 4][CONV2_FILTERS]
) {
#pragma HLS INLINE

    for (int t = 0; t < SEQ_LENGTH / 4; t++) {
        for (int f = 0; f < CONV2_FILTERS; f++) {
            data_t a = input[t * 2][f];
            data_t b = input[t * 2 + 1][f];
            output[t][f] = (a > b) ? a : b;
        }
    }
}

static void flatten(
    data_t input[SEQ_LENGTH / 4][CONV2_FILTERS],
    data_t output[(SEQ_LENGTH / 4) * CONV2_FILTERS]
) {
#pragma HLS INLINE

    int idx = 0;
    for (int t = 0; t < SEQ_LENGTH / 4; t++) {
        for (int c = 0; c < CONV2_FILTERS; c++) {
            output[idx++] = input[t][c];
        }
    }
}

static void dense1(
    data_t input[(SEQ_LENGTH / 4) * CONV2_FILTERS],
    data_t output[DENSE1_UNITS]
) {
#pragma HLS INLINE

    const int in_dim = (SEQ_LENGTH / 4) * CONV2_FILTERS; // 1600

    for (int o = 0; o < DENSE1_UNITS; o++) {
        acc_t sum = (data_t)dense_param_1[o]; // bias

        for (int i = 0; i < in_dim; i++) {
            int wi = dense_index(i, o, DENSE1_UNITS);
            sum += input[i] * (data_t)dense_param_0[wi];
        }

        output[o] = relu((data_t)sum);
    }
}

static void dense2_logits(
    data_t input[DENSE1_UNITS],
    data_t output[NUM_CLASSES]
) {
#pragma HLS INLINE

    for (int o = 0; o < NUM_CLASSES; o++) {
        acc_t sum = (data_t)dense_1_param_1[o]; // bias

        for (int i = 0; i < DENSE1_UNITS; i++) {
            int wi = dense_index(i, o, NUM_CLASSES);
            sum += input[i] * (data_t)dense_1_param_0[wi];
        }

        output[o] = (data_t)sum;
    }
}

static void softmax(data_t logits[NUM_CLASSES], data_t probs[NUM_CLASSES]) {
#pragma HLS INLINE

    data_t max_v = logits[0];
    for (int i = 1; i < NUM_CLASSES; i++) {
        if (logits[i] > max_v) max_v = logits[i];
    }

    data_t exps[NUM_CLASSES];
    data_t sum = 0;
    for (int i = 0; i < NUM_CLASSES; i++) {
        exps[i] = (data_t)hls::exp((float)(logits[i] - max_v));
        sum += exps[i];
    }

    for (int i = 0; i < NUM_CLASSES; i++) {
        probs[i] = exps[i] / sum;
    }
}

// Top function to synthesize in Vitis HLS
void cnn_gesture_top(
    data_t input[SEQ_LENGTH][FEATURES],
    data_t output[NUM_CLASSES]
) {
#pragma HLS INTERFACE ap_memory port=input
#pragma HLS INTERFACE ap_memory port=output
#pragma HLS INTERFACE ap_ctrl_hs port=return

#pragma HLS ARRAY_PARTITION variable=input cyclic factor=2 dim=2
#pragma HLS ARRAY_PARTITION variable=output complete

    data_t conv1_out[SEQ_LENGTH][CONV1_FILTERS];
    data_t pool1_out[SEQ_LENGTH / 2][CONV1_FILTERS];
    data_t conv2_out[SEQ_LENGTH / 2][CONV2_FILTERS];
    data_t pool2_out[SEQ_LENGTH / 4][CONV2_FILTERS];
    data_t flat[(SEQ_LENGTH / 4) * CONV2_FILTERS];
    data_t fc1[DENSE1_UNITS];
    data_t logits[NUM_CLASSES];

    conv1_block(input, conv1_out);
    maxpool1(conv1_out, pool1_out);

    conv2_block(pool1_out, conv2_out);
    maxpool2(conv2_out, pool2_out);

    flatten(pool2_out, flat);
    dense1(flat, fc1);
    dense2_logits(fc1, logits);
    softmax(logits, output);
}
