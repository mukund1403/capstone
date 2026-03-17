#include <ap_fixed.h>
#include <ap_axi_sdata.h>
#include <ap_int.h>
#include <hls_math.h>
#include <hls_stream.h>
#include "weights.h"

#define SEQ_LENGTH    100
#define FEATURES      6
#define CONV1_FILTERS 32
#define CONV2_FILTERS 64
#define DENSE1_UNITS  128
#define NUM_CLASSES   6
#define KERNEL_SIZE   3

typedef ap_fixed<16, 6>  data_t;
typedef ap_fixed<32, 12> acc_t;
typedef ap_axiu<32, 0, 0, 0> axis_t;

static inline data_t relu(data_t x) {
    return (x > 0) ? x : (data_t)0;
}

static inline int conv_index(int k, int c, int f, int in_ch, int out_ch) {
    return (k * in_ch + c) * out_ch + f;
}

static inline int dense_index(int i, int o, int out_dim) {
    return i * out_dim + o;
}

static void conv1_block(
    data_t input[SEQ_LENGTH][FEATURES],
    data_t output[SEQ_LENGTH][CONV1_FILTERS]
) {
#pragma HLS INLINE off

    for (int t = 0; t < SEQ_LENGTH; t++) {
        for (int f = 0; f < CONV1_FILTERS; f++) {
#pragma HLS PIPELINE II=1
#pragma HLS DEPENDENCE variable=input  inter false
#pragma HLS DEPENDENCE variable=output inter false
            acc_t sum = (acc_t)conv1d_param_1[f];

            for (int k = 0; k < KERNEL_SIZE; k++) {
#pragma HLS UNROLL factor=3
                int idx = t + k - 1;
                if (idx >= 0 && idx < SEQ_LENGTH) {
                    for (int c = 0; c < FEATURES; c++) {
#pragma HLS UNROLL factor=6
#pragma HLS RESOURCE variable=sum core=DSP48
                        sum += (data_t)input[idx][c]
                             * (data_t)conv1d_param_0[
                                   conv_index(k, c, f, FEATURES, CONV1_FILTERS)];
                    }
                }
            }

            // Folded BN applied before ReLU (correct Keras order)
            acc_t bn = (data_t)batch_normalization_param_0[f] * sum
                     + (data_t)batch_normalization_param_1[f];
            output[t][f] = relu((data_t)bn);
        }
    }
}

// -----------------------------------------------------------------------------
// maxpool1: pool_size=2, stride=2
// -----------------------------------------------------------------------------
static void maxpool1(
    data_t input[SEQ_LENGTH][CONV1_FILTERS],
    data_t output[SEQ_LENGTH / 2][CONV1_FILTERS]
) {
#pragma HLS INLINE off

    for (int t = 0; t < SEQ_LENGTH / 2; t++) {
        for (int f = 0; f < CONV1_FILTERS; f++) {
#pragma HLS PIPELINE II=1
            data_t a = input[t * 2][f];
            data_t b = input[t * 2 + 1][f];
            output[t][f] = (a > b) ? a : b;
        }
    }
}

// -----------------------------------------------------------------------------
// conv2_block
// c=CONV1_FILTERS=32: fully unrolling needs 32*3=96 MACs/stage — too many DSPs.
// Use UNROLL factor=8 on c: 8 parallel MACs, II=4. Acceptable latency tradeoff.
// -----------------------------------------------------------------------------
static void conv2_block(
    data_t input[SEQ_LENGTH / 2][CONV1_FILTERS],
    data_t output[SEQ_LENGTH / 2][CONV2_FILTERS]
) {
#pragma HLS INLINE off

    for (int t = 0; t < SEQ_LENGTH / 2; t++) {
        for (int f = 0; f < CONV2_FILTERS; f++) {
#pragma HLS PIPELINE II=4
            acc_t sum = (acc_t)conv1d_1_param_1[f];

            for (int k = 0; k < KERNEL_SIZE; k++) {
#pragma HLS UNROLL factor=3
                int idx = t + k - 1;
                if (idx >= 0 && idx < SEQ_LENGTH / 2) {
                    for (int c = 0; c < CONV1_FILTERS; c++) {
#pragma HLS UNROLL factor=8
#pragma HLS RESOURCE variable=sum core=DSP48
                        sum += (data_t)input[idx][c]
                             * (data_t)conv1d_1_param_0[
                                   conv_index(k, c, f, CONV1_FILTERS, CONV2_FILTERS)];
                    }
                }
            }

            acc_t bn = (data_t)batch_normalization_1_param_0[f] * sum
                     + (data_t)batch_normalization_1_param_1[f];
            output[t][f] = relu((data_t)bn);
        }
    }
}

// -----------------------------------------------------------------------------
// maxpool2: pool_size=2, stride=2
// -----------------------------------------------------------------------------
static void maxpool2(
    data_t input[SEQ_LENGTH / 2][CONV2_FILTERS],
    data_t output[SEQ_LENGTH / 4][CONV2_FILTERS]
) {
#pragma HLS INLINE off

    for (int t = 0; t < SEQ_LENGTH / 4; t++) {
        for (int f = 0; f < CONV2_FILTERS; f++) {
#pragma HLS PIPELINE II=1
            data_t a = input[t * 2][f];
            data_t b = input[t * 2 + 1][f];
            output[t][f] = (a > b) ? a : b;
        }
    }
}

// -----------------------------------------------------------------------------
// flatten: [SEQ_LENGTH/4][CONV2_FILTERS] -> [1600], row-major
// -----------------------------------------------------------------------------
static void flatten(
    data_t input[SEQ_LENGTH / 4][CONV2_FILTERS],
    data_t output[(SEQ_LENGTH / 4) * CONV2_FILTERS]
) {
#pragma HLS INLINE off

    for (int t = 0; t < SEQ_LENGTH / 4; t++) {
        for (int c = 0; c < CONV2_FILTERS; c++) {
#pragma HLS PIPELINE II=1
            output[t * CONV2_FILTERS + c] = input[t][c];
        }
    }
}

// -----------------------------------------------------------------------------
// dense1: 1600 -> 128 with ReLU
// Cannot unroll in_dim=1600 (would need 1600 DSPs — 4x the ZU3EG budget).
// Serial inner loop with PIPELINE II=1 on i: 128 * 1600 = 204,800 cycles.
// At 200 MHz clock: ~1 ms total. Fine for a 100-sample gesture window.
// -----------------------------------------------------------------------------
static void dense1(
    data_t input[(SEQ_LENGTH / 4) * CONV2_FILTERS],
    data_t output[DENSE1_UNITS]
) {
#pragma HLS INLINE off

    const int IN_DIM = (SEQ_LENGTH / 4) * CONV2_FILTERS; // 1600

    for (int o = 0; o < DENSE1_UNITS; o++) {
        acc_t sum = (acc_t)dense_param_1[o];

        for (int i = 0; i < IN_DIM; i++) {
#pragma HLS PIPELINE II=1
#pragma HLS RESOURCE variable=sum core=DSP48
            sum += (data_t)input[i]
                 * (data_t)dense_param_0[dense_index(i, o, DENSE1_UNITS)];
        }

        output[o] = relu((data_t)sum);
    }
}

// -----------------------------------------------------------------------------
// dense2_logits: 128 -> 6, no activation (softmax on PS/PYNQ side)
// 6 * 128 = 768 cycles — negligible
// -----------------------------------------------------------------------------
static void dense2_logits(
    data_t input[DENSE1_UNITS],
    data_t output[NUM_CLASSES]
) {
#pragma HLS INLINE off

    for (int o = 0; o < NUM_CLASSES; o++) {
        acc_t sum = (acc_t)dense_1_param_1[o];

        for (int i = 0; i < DENSE1_UNITS; i++) {
#pragma HLS PIPELINE II=1
#pragma HLS RESOURCE variable=sum core=DSP48
            sum += (data_t)input[i]
                 * (data_t)dense_1_param_0[dense_index(i, o, NUM_CLASSES)];
        }

        output[o] = (data_t)sum;
    }
}

static void cnn_gesture_core(
    data_t input[SEQ_LENGTH][FEATURES],
    data_t output[NUM_CLASSES]
) {
#pragma HLS INLINE off
#pragma HLS DATAFLOW

    data_t conv1_out[SEQ_LENGTH][CONV1_FILTERS];
    data_t pool1_out[SEQ_LENGTH / 2][CONV1_FILTERS];
    data_t conv2_out[SEQ_LENGTH / 2][CONV2_FILTERS];
    data_t pool2_out[SEQ_LENGTH / 4][CONV2_FILTERS];
    data_t flat[(SEQ_LENGTH / 4) * CONV2_FILTERS];
    data_t fc1[DENSE1_UNITS];

#pragma HLS ARRAY_PARTITION variable=conv1_out dim=2 cyclic factor=8
#pragma HLS ARRAY_PARTITION variable=pool1_out dim=2 cyclic factor=8
#pragma HLS ARRAY_PARTITION variable=conv2_out dim=2 cyclic factor=8
#pragma HLS ARRAY_PARTITION variable=pool2_out dim=2 cyclic factor=8

#pragma HLS BIND_STORAGE variable=flat type=RAM_2P impl=BRAM
#pragma HLS BIND_STORAGE variable=fc1  type=RAM_2P impl=BRAM

    conv1_block  (input,     conv1_out);
    maxpool1     (conv1_out, pool1_out);
    conv2_block  (pool1_out, conv2_out);
    maxpool2     (conv2_out, pool2_out);
    flatten      (pool2_out, flat);
    dense1       (flat,      fc1);
    dense2_logits(fc1,       output);
}

// -----------------------------------------------------------------------------
// cnn_gesture_top — AXI4-Stream + AXI-Lite top-level (unchanged interface)
//
// Input:  600 words × 32-bit AXI, lower 16 bits = ap_fixed<16,6> sample
//         Order: t=0,c=0 → t=0,c=5 → t=1,c=0 → ... → t=99,c=5
//         Apply z-score normalisation on the PS BEFORE sending over DMA.
//
// Output: 6 words = raw logits, no softmax.
//         On PYNQ: predicted_class = int(np.argmax(logits))
// -----------------------------------------------------------------------------
void cnn_gesture_top(
    hls::stream<axis_t>& input_stream,
    hls::stream<axis_t>& output_stream
) {
#pragma HLS INTERFACE axis      port=input_stream
#pragma HLS INTERFACE axis      port=output_stream
#pragma HLS INTERFACE s_axilite port=return bundle=CTRL

    data_t input[SEQ_LENGTH][FEATURES];
    data_t output[NUM_CLASSES];

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