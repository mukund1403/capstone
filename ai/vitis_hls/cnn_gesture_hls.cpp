#include <ap_fixed.h>
#include <ap_axi_sdata.h>
#include <ap_int.h>
#include <hls_math.h>
#include <hls_stream.h>
#include "weights.h"

#define SEQ_LENGTH 75
#define FEATURES 6
#define CONV1_FILTERS 32
#define CONV2_FILTERS 64
#define DENSE1_UNITS 128
#define NUM_CLASSES 6
#define KERNEL_SIZE 3

typedef ap_fixed<16, 6> data_t;
typedef ap_fixed<32, 12> acc_t;
typedef ap_axiu<32, 0, 0, 0> axis_t;

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
#pragma HLS PIPELINE II=1
                        int wi = conv_index(k, c, f, FEATURES, CONV1_FILTERS);
                        sum += input[idx][c] * (data_t)conv1d_param_0[wi];
                    }
                }
            }

            // Conv bias
            sum += (data_t)conv1d_param_1[f];

            // Keras Conv1D has activation='relu'
            data_t act = relu((data_t)sum);

            // BatchNorm folded to scale+bias: y = scale * act + bias
            data_t scale = (data_t)batch_normalization_param_0[f];
            data_t bias = (data_t)batch_normalization_param_1[f];
            output[t][f] = scale * act + bias;
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
#pragma HLS PIPELINE II=1
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
#pragma HLS PIPELINE II=1
                        int wi = conv_index(k, c, f, CONV1_FILTERS, CONV2_FILTERS);
                        sum += input[idx][c] * (data_t)conv1d_1_param_0[wi];
                    }
                }
            }

            sum += (data_t)conv1d_1_param_1[f];
            data_t act = relu((data_t)sum);

            data_t scale = (data_t)batch_normalization_1_param_0[f];
            data_t bias = (data_t)batch_normalization_1_param_1[f];
            output[t][f] = scale * act + bias;
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
#pragma HLS PIPELINE II=1
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
#pragma HLS PIPELINE II=1
            output[idx++] = input[t][c];
        }
    }
}

static void dense1(
    data_t input[(SEQ_LENGTH / 4) * CONV2_FILTERS],
    data_t output[DENSE1_UNITS]
) {
#pragma HLS INLINE

    const int in_dim = (SEQ_LENGTH / 4) * CONV2_FILTERS; // 1152 when SEQ_LENGTH=75

    for (int o = 0; o < DENSE1_UNITS; o++) {
        acc_t sum = (data_t)dense_param_1[o]; // bias

        for (int i = 0; i < in_dim; i++) {
#pragma HLS PIPELINE II=1
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
#pragma HLS PIPELINE II=1
            int wi = dense_index(i, o, NUM_CLASSES);
            sum += input[i] * (data_t)dense_1_param_0[wi];
        }

        output[o] = (data_t)sum;
    }
}

// Internal compute core (array form).
static void cnn_gesture_core(
    data_t input[SEQ_LENGTH][FEATURES],
    data_t output[NUM_CLASSES]
) {
#pragma HLS INLINE off

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
    dense2_logits(fc1, output);
}

// Top function for AXI DMA integration (AXI4-Stream + AXI-Lite control).
void cnn_gesture_top(
    hls::stream<axis_t>& input_stream,
    hls::stream<axis_t>& output_stream
) {
#pragma HLS INTERFACE axis port=input_stream
#pragma HLS INTERFACE axis port=output_stream
#pragma HLS INTERFACE s_axilite port=return bundle=CTRL

    data_t input[SEQ_LENGTH][FEATURES];
    data_t output[NUM_CLASSES];

    // Input packing order: timestep-major, then feature.
    for (int t = 0; t < SEQ_LENGTH; t++) {
        for (int c = 0; c < FEATURES; c++) {
#pragma HLS PIPELINE II=1
            axis_t pkt = input_stream.read();
            ap_uint<16> raw = pkt.data.range(15, 0);
            data_t val;
            val.range(15, 0) = raw;
            input[t][c] = val;
        }
    }

    cnn_gesture_core(input, output);

    for (int i = 0; i < NUM_CLASSES; i++) {
#pragma HLS PIPELINE II=1
        axis_t pkt;
        ap_uint<16> raw = output[i].range(15, 0);
        pkt.data = (ap_uint<32>)raw;
        pkt.keep = -1;
        pkt.strb = -1;
        pkt.last = (i == NUM_CLASSES - 1) ? 1 : 0;
        output_stream.write(pkt);
    }
}
