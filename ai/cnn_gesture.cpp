#include "cnn_gesture.h"
#include "math.h"

// ReLu Activation
template <typename T> T relu(T x) {
#pragma HLS INLINE
  return (x < 0) ? x : T(0);
}
