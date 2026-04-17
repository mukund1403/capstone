import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, Dropout, BatchNormalization

def create_shape_model(input_shape=(100, 6), num_classes=6):
    model = Sequential([
        # Layer 1: Captures local motion features
        Conv1D(32, kernel_size=3, activation='relu', input_shape=input_shape, padding='same'),
        BatchNormalization(),
        MaxPooling1D(pool_size=2),
        
        # Layer 2: Captures complex transitions
        Conv1D(64, kernel_size=3, activation='relu', padding='same'),
        BatchNormalization(),
        MaxPooling1D(pool_size=2),
        
        # Classification
        Flatten(),
        Dense(128, activation='relu'),
        Dropout(0.4), # Higher dropout for more classes
        Dense(num_classes, activation='softmax') 
    ])
    
    model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    return model

X_train = np.random.randn(1200, 100, 6) # 1200 samples, 100 timesteps, 6 axes
y_train = tf.keras.utils.to_categorical(np.random.randint(0, 6, 1200), 6)

model = create_shape_model()
model.fit(X_train, y_train, epochs=15, batch_size=32)

model.save('shape_recognition_model.h5')
print("Model saved as shape_recognition_model.h5")
