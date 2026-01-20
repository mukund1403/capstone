import numpy as np
import tensorflow as tf

from tensorflow.keras.models import Sequential

model = Sequential([
    Conv1D(filters=32, kernel_size=3, activation='relu', 
           input_shape=(100, 6)),
    MaxPooling1D(pool_size=2),
    
    Conv1D(filters=64, kernel_size=3, activation='relu'),
    MaxPooling1D(pool_size=2),
    
    Flatten(),
    Dense(100, activation='relu'),
    Dropout(0.5), 
    Dense(6, activation='softmax') 
])

