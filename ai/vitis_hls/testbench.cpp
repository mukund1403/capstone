#include <algorithm>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include <ap_axi_sdata.h>
#include <ap_fixed.h>
#include <ap_int.h>
#include <hls_stream.h>

#define SEQ_LENGTH 100
#define FEATURES 6
#define NUM_CLASSES 6

typedef ap_fixed<16, 6> data_t;
typedef float float_t;
typedef ap_axiu<32, 0, 0, 0> axis_t;

static const int FIXED_SCALE = 1 << 10; // ap_fixed<16,6> => 10 fractional bits

// Top function declaration from cnn_gesture_hls.cpp
void cnn_gesture_top(
    hls::stream<axis_t>& input_stream,
    hls::stream<axis_t>& output_stream
);

static inline ap_int<16> float_to_fixed(float v) {
    float scaled = v * (float)FIXED_SCALE;
    if (scaled > 32767.0f) scaled = 32767.0f;
    if (scaled < -32768.0f) scaled = -32768.0f;
    int32_t rounded = (scaled >= 0.0f) ? (int32_t)(scaled + 0.5f) : (int32_t)(scaled - 0.5f);
    return (ap_int<16>)rounded;
}

static inline float fixed_to_float(ap_int<16> v) {
    return (float)v / (float)FIXED_SCALE;
}

static int argmax(const float_t logits[NUM_CLASSES]) {
    int max_idx = 0;
    float_t max_val = logits[0];
    for (int i = 1; i < NUM_CLASSES; i++) {
        if (logits[i] > max_val) {
            max_val = logits[i];
            max_idx = i;
        }
    }
    return max_idx;
}

static bool parse_line_of_floats(const std::string& line, std::vector<float_t>& out) {
    out.clear();
    std::istringstream iss(line);
    float_t v = 0.0f;
    while (iss >> v) out.push_back(v);
    return !out.empty();
}

int main() {
    const int input_values_per_sample = SEQ_LENGTH * FEATURES;
    const float_t logit_tolerance = 0.50f;

    std::ifstream input_file("../software/reference_input.txt");
    std::ifstream golden_file("../software/reference_logits.txt");

    if (!input_file.is_open() || !golden_file.is_open()) {
        std::cerr << "Failed to open reference files at:\n";
        std::cerr << "  ../software/reference_input.txt\n";
        std::cerr << "  ../software/reference_logits.txt\n";
        return 1;
    }

    std::ofstream out_file("output_logits.txt");
    if (!out_file.is_open()) {
        std::cerr << "Failed to open output_logits.txt\n";
        return 2;
    }

    std::string input_line, logits_line;
    int sample_count = 0;
    int class_mismatches = 0;
    int logit_mismatches = 0;
    float_t max_abs_err = 0.0f;

    while (std::getline(input_file, input_line) && std::getline(golden_file, logits_line)) {
        std::vector<float_t> input_vals;
        std::vector<float_t> golden_vals;

        if (!parse_line_of_floats(input_line, input_vals)) continue;
        if (!parse_line_of_floats(logits_line, golden_vals)) {
            std::cerr << "Invalid golden line at sample " << sample_count << "\n";
            return 3;
        }

        if ((int)input_vals.size() != input_values_per_sample) {
            std::cerr << "Input size mismatch at sample " << sample_count
                      << " (expected " << input_values_per_sample
                      << ", got " << input_vals.size() << ")\n";
            return 4;
        }
        if ((int)golden_vals.size() != NUM_CLASSES) {
            std::cerr << "Golden logits size mismatch at sample " << sample_count
                      << " (expected " << NUM_CLASSES
                      << ", got " << golden_vals.size() << ")\n";
            return 5;
        }

        hls::stream<axis_t> input_stream;
        hls::stream<axis_t> output_stream;
        float_t output[NUM_CLASSES];
        float_t golden[NUM_CLASSES];

        int idx = 0;
        for (int t = 0; t < SEQ_LENGTH; t++) {
            for (int ch = 0; ch < FEATURES; ch++) {
                axis_t pkt;
                ap_int<16> fx = float_to_fixed(input_vals[idx++]);
                pkt.data = (ap_uint<32>)(ap_uint<16>)fx;
                pkt.keep = -1;
                pkt.strb = -1;
                pkt.last = 0;
                input_stream.write(pkt);
            }
        }

        cnn_gesture_top(input_stream, output_stream);

        for (int c = 0; c < NUM_CLASSES; c++) {
            axis_t pkt = output_stream.read();
            ap_int<16> fx = (ap_int<16>)pkt.data.range(15, 0);
            output[c] = fixed_to_float(fx);
            golden[c] = golden_vals[c];
            if (c == NUM_CLASSES - 1 && pkt.last != 1) {
                std::cerr << "Output TLAST not asserted on final class for sample " << sample_count << "\n";
                return 7;
            }
        }

        for (int c = 0; c < NUM_CLASSES; c++) {
            out_file << output[c];
            if (c < NUM_CLASSES - 1) out_file << " ";
        }
        out_file << "\n";

        int pred_class = argmax(output);
        int golden_class = argmax(golden);
        if (pred_class != golden_class) class_mismatches++;

        for (int c = 0; c < NUM_CLASSES; c++) {
            float_t err = std::fabs(output[c] - golden[c]);
            if (err > max_abs_err) max_abs_err = err;
            if (err > logit_tolerance) logit_mismatches++;
        }

        sample_count++;
    }

    input_file.close();
    golden_file.close();
    out_file.close();

    if (sample_count == 0) {
        std::cerr << "No valid samples were processed.\n";
        return 6;
    }

    std::cout << "Processed " << sample_count << " samples.\n";
    std::cout << "Max abs error: " << std::fixed << std::setprecision(6) << max_abs_err << "\n";
    std::cout << "Class mismatches: " << class_mismatches << "\n";
    std::cout << "Logit mismatches (> " << logit_tolerance << "): " << logit_mismatches << "\n";
    std::cout << "Wrote HLS outputs to output_logits.txt\n";

    if (class_mismatches == 0) {
        std::cout << "Class check passed.\n";
    } else {
        std::cout << "Class check failed.\n";
    }

    if (logit_mismatches == 0) {
        std::cout << "Logit check passed.\n";
    } else {
        std::cout << "Logit check failed.\n";
    }

    // Return pass/fail based on class prediction match, same as common HLS TB practice.
    return (class_mismatches == 0) ? 0 : 1;
}
