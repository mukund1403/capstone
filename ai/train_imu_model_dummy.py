import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, Dropout, BatchNormalization
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split

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
        Dropout(0.4),
        Dense(num_classes, activation='softmax') 
    ])
    
    model.compile(
        optimizer='adam', 
        loss='categorical_crossentropy', 
        metrics=['accuracy']
    )
    
    model.summary()
    return model

def create_dummy_data(n_samples=1200, timesteps=100, n_classes=6, n_features=6):
    """
    Create dummy data that actually has learnable patterns
    """
    X = []
    y = []
    
    for sample_idx in range(n_samples):
        class_label = np.random.randint(0, n_classes)
        
        time = np.linspace(0, 4*np.pi, timesteps)
        
        if class_label == 0:  # Straight slash - clean sine wave
            base_signal = np.sin(time + np.random.uniform(0, np.pi))
        elif class_label == 1:  # V shape - triangle wave
            base_signal = 2 * np.abs((time % (2*np.pi)) / np.pi - 1) - 1
        elif class_label == 2:  # Circle - two sine waves
            base_signal = np.sin(time) * np.cos(time/2)
        elif class_label == 3:  # Throw bomb - sudden spike
            base_signal = np.zeros_like(time)
            spike_pos = np.random.randint(30, 70)
            base_signal[spike_pos:spike_pos+10] = 1.0
        elif class_label == 4:  # Time stop - flat with noise
            base_signal = np.random.normal(0, 0.1, timesteps)
        else:  # Zigzag - sawtooth
            base_signal = (time % (2*np.pi)) / (2*np.pi)
        
        # Create 6 features (accelerometer + gyroscope)
        sample = np.zeros((timesteps, n_features))
        
        for feature_idx in range(n_features):
            # Each feature is base signal + some variation + noise
            phase_shift = np.random.uniform(0, np.pi/2)
            amplitude = np.random.uniform(0.5, 1.5)
            noise = np.random.normal(0, 0.1, timesteps)
            
            # Different features correlate differently
            if feature_idx < 3:  # Accelerometer
                sample[:, feature_idx] = amplitude * np.sin(time + phase_shift) * base_signal + noise
            else:  # Gyroscope
                sample[:, feature_idx] = amplitude * np.cos(time + phase_shift) * base_signal + noise
        
        X.append(sample)
        y.append(class_label)
    
    X = np.array(X)
    y = np.array(y)
    
    print(f"Created dummy data: {X.shape}")
    print(f"Class distribution: {np.bincount(y)}")
    
    return X, y

# ==================== MAIN TRAINING ====================
# Create dummy data
print("Generating dummy data with patterns...")
X, y = create_dummy_data(n_samples=1200, timesteps=100, n_classes=6)

# Convert to categorical
y_categorical = tf.keras.utils.to_categorical(y, 6)

X_train, X_val, y_train, y_val = train_test_split(
    X, y_categorical, test_size=0.2, random_state=42, stratify=y
)

print(f"\nData split:")
print(f"  Training: {X_train.shape[0]} samples")
print(f"  Validation: {X_val.shape[0]} samples")

# Create model
model = create_shape_model()

# Add callbacks
callbacks = [
    EarlyStopping(
        monitor='val_loss',
        patience=5,
        restore_best_weights=True,
        verbose=1
    ),
    ModelCheckpoint(
        'best_dummy_model.h5',
        monitor='val_accuracy',
        save_best_only=True,
        verbose=1
    )
]

# Train with validation
print("\nTraining model...")
history = model.fit(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=30,
    batch_size=32,
    callbacks=callbacks,
    verbose=1
)

val_loss, val_acc = model.evaluate(X_val, y_val, verbose=0)
print(f"\nValidation Accuracy: {val_acc:.4f}")
print(f"Validation Loss: {val_loss:.4f}")

# Save model
model.save('shape_recognition_model.h5')
print("Model saved as shape_recognition_model.h5")

# ==================== PLOT TRAINING HISTORY ====================
# Plot training history
plt.figure(figsize=(12, 4))

plt.subplot(1, 2, 1)
plt.plot(history.history['accuracy'], label='Train Accuracy')
plt.plot(history.history['val_accuracy'], label='Val Accuracy')
plt.title('Model Accuracy')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.legend()
plt.grid(True)

plt.subplot(1, 2, 2)
plt.plot(history.history['loss'], label='Train Loss')
plt.plot(history.history['val_loss'], label='Val Loss')
plt.title('Model Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend()
plt.grid(True)

plt.tight_layout()
plt.savefig('training_history_dummy.png', dpi=300)
plt.show()

print("\n" + "="*50)
print("Testing predictions on new dummy samples...")
print("="*50)

# Create some test samples
test_samples = 10
X_test, y_test = create_dummy_data(n_samples=test_samples, timesteps=100, n_classes=6)

# Make predictions
predictions = model.predict(X_test)
predicted_classes = np.argmax(predictions, axis=1)

# Display results
for i in range(test_samples):
    true_class = y_test[i]
    pred_class = predicted_classes[i]
    confidence = predictions[i][pred_class]
    
    print(f"Sample {i+1}: True={true_class}, Predicted={pred_class}, "
          f"Confidence={confidence:.3f}, "
          f"Correct={'✓' if true_class == pred_class else '✗'}")
