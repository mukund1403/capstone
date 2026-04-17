# NOTE: This does convert to C++ and gives me a .h file, but seems really confusing I'm just gonna make it myself

import hls4ml
import tensorflow as tf

model = tf.keras.models.load_model('shape_recognition_model.h5')

config = hls4ml.utils.config_from_keras_model(model, granularity='name')

config['Model']['Strategy'] = 'Latency'
config['Model']['Precision'] = 'ap_fixed<16,6>'

for layer in config['LayerName'].keys():
    if 'softmax' in layer.lower():
        config['LayerName'][layer]['Strategy'] = 'Stable'

hls_model = hls4ml.converters.convert_from_keras_model(
    model,
    hls_config=config,
    output_dir='hls_shape_project',
    backend='Vitis'
)

print("Compiling C++ simulation...")
hls_model.compile()


print("Project generated in folder: hls_shape_project")
