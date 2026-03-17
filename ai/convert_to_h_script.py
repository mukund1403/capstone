import os
import tensorflow as tf
import numpy as np

script_dir = os.path.dirname(os.path.abspath(__file__))
model_path = os.path.join(script_dir, "best_dummy_model.h5")
output_path = os.path.join(script_dir, "weights.h")
model = tf.keras.models.load_model(model_path)


def write_array(f, name, arr, comment):
    f.write(f"// {comment}\n")
    f.write(f"const float {name}[] = {{")
    f.write(", ".join(map(str, arr.flatten())))
    f.write("};\n\n")

with open(output_path, "w") as f:
    f.write("#ifndef WEIGHTS_H\n#define WEIGHTS_H\n\n")

    for layer in model.layers:
        weights = layer.get_weights()
        if not weights:
            continue

        name = layer.name.replace("/", "_").replace(":", "_")
        print(f"Processing layer: {layer.name} ({len(weights)} parameters)")

        # BatchNorm folding: precompute scale and bias to avoid sqrt/div at runtime.
        if isinstance(layer, tf.keras.layers.BatchNormalization):
            gamma, beta, mean, var = weights
            eps = layer.epsilon
            scale = gamma / np.sqrt(var + eps)
            bias = beta - mean * scale

            write_array(
                f,
                f"{name}_param_0",
                scale,
                f"Layer: {layer.name}, Param: 0 (scale = gamma/sqrt(var+eps))",
            )
            write_array(
                f,
                f"{name}_param_1",
                bias,
                f"Layer: {layer.name}, Param: 1 (bias = beta - mean*scale)",
            )
            continue

        # Default: dump raw weights
        for i, w in enumerate(weights):
            var_name = f"{name}_param_{i}"
            comment = f"Layer: {layer.name}, Param: {i}"
            write_array(f, var_name, w, comment)

    f.write("#endif")

print("Success! weights.h generated.")
