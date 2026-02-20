import tensorflow as tf
import numpy as np

model = tf.keras.models.load_model('best_dummy_model.h5')

with open('weights.h', 'w') as f:
    f.write("#ifndef WEIGHTS_H\n#define WEIGHTS_H\n\n")
    
    for layer in model.layers:
        weights = layer.get_weights()
        if not weights:
            continue
            
        name = layer.name.replace("/", "_").replace(":", "_")
        print(f"Processing layer: {layer.name} ({len(weights)} parameters)")

        for i, w in enumerate(weights):
            var_name = f"{name}_param_{i}"
            
            # Map common indices for your report/understanding:
            # Conv/Dense: 0=Weights, 1=Bias
            # BatchNorm: 0=Gamma, 1=Beta, 2=Mean, 3=Variance
            
            f.write(f"// Layer: {layer.name}, Param: {i}\n")
            f.write(f"const float {var_name}[] = {{")
            f.write(", ".join(map(str, w.flatten())))
            f.write("};\n\n")
            
    f.write("#endif")
print("Success! weights.h generated.")
