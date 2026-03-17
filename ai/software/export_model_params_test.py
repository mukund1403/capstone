import numpy as np
import tensorflow as tf
from pathlib import Path
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, Dropout, BatchNormalization, Input
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split

OUTPUT_DIR = Path(__file__).resolve().parent


def create_shape_model(input_shape=(100, 6), num_classes=6):
    model = Sequential([
        Input(shape=input_shape),
        # Layer 1: Captures local motion features
        Conv1D(32, kernel_size=3, activation='relu', padding='same'),
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
    """Create dummy IMU-like data with class-specific patterns."""
    X = []
    y = []

    for _ in range(n_samples):
        class_label = np.random.randint(0, n_classes)
        time = np.linspace(0, 4 * np.pi, timesteps)

        if class_label == 0:      # slash pattern 1
            base_signal = np.sin(time + np.random.uniform(0, np.pi))
        elif class_label == 1:    # slash pattern 2
            base_signal = 2 * np.abs((time % (2 * np.pi)) / np.pi - 1) - 1
        elif class_label == 2:    # slash pattern 3
            base_signal = np.sin(time) * np.cos(time / 2)
        elif class_label == 3:    # slash pattern 4
            base_signal = (time % (2 * np.pi)) / (2 * np.pi)
        elif class_label == 4:    # throw bomb
            base_signal = np.zeros_like(time)
            spike_pos = np.random.randint(30, 70)
            base_signal[spike_pos:spike_pos + 10] = 1.0
        else:                     # time slow
            base_signal = np.random.normal(0, 0.1, timesteps)

        sample = np.zeros((timesteps, n_features), dtype=np.float32)

        for feature_idx in range(n_features):
            phase_shift = np.random.uniform(0, np.pi / 2)
            amplitude = np.random.uniform(0.5, 1.5)
            noise = np.random.normal(0, 0.1, timesteps)

            if feature_idx < 3:  # Accelerometer
                sample[:, feature_idx] = amplitude * np.sin(time + phase_shift) * base_signal + noise
            else:                # Gyroscope
                sample[:, feature_idx] = amplitude * np.cos(time + phase_shift) * base_signal + noise

        X.append(sample)
        y.append(class_label)

    X = np.array(X, dtype=np.float32)
    y = np.array(y, dtype=np.int32)

    print(f"Created dummy data: {X.shape}")
    print(f"Class distribution: {np.bincount(y)}")
    return X, y

# training
print("Generating dummy data...")
X, y = create_dummy_data(n_samples=1200, timesteps=100, n_classes=6)

y_categorical = tf.keras.utils.to_categorical(y, 6)

X_train, X_val, y_train, y_val = train_test_split(
    X, y_categorical, test_size=0.2, random_state=42, stratify=y
)

print("\nData split:")
print(f"  Training: {X_train.shape[0]} samples")
print(f"  Validation: {X_val.shape[0]} samples")

model = create_shape_model()

callbacks = [
    EarlyStopping(
        monitor='val_loss',
        patience=5,
        restore_best_weights=True,
        verbose=1
    ),
    ModelCheckpoint(
        str(OUTPUT_DIR / 'best_dummy_model.h5'),
        monitor='val_accuracy',
        save_best_only=True,
        verbose=1
    )
]

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

# Keep a single model artifact via ModelCheckpoint: best_dummy_model.h5
print("Using best checkpoint only: best_dummy_model.h5")

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
plt.savefig(OUTPUT_DIR / 'training_history_dummy.png', dpi=300)
print("Saved training plot as training_history_dummy.png")

print("\nTesting predictions on new dummy samples...")
X_test, y_test = create_dummy_data(n_samples=10, timesteps=100, n_classes=6)
# Use checkpoint model so exported golden outputs match weights.h export source.
model = tf.keras.models.load_model(OUTPUT_DIR / 'best_dummy_model.h5')
predictions = model.predict(X_test)
predicted_classes = np.argmax(predictions, axis=1)

# Export reference inputs/outputs for HLS/C++ testbench comparison.
np.savetxt(OUTPUT_DIR / 'reference_input.txt', X_test.reshape(X_test.shape[0], -1), fmt='%.6f')
np.savetxt(OUTPUT_DIR / 'reference_logits.txt', predictions, fmt='%.6f')
print("Saved reference inputs to reference_input.txt")
print("Saved reference logits to reference_logits.txt")

for i in range(10):
    true_class = y_test[i]
    pred_class = predicted_classes[i]
    confidence = predictions[i][pred_class]
    mark = 'OK' if true_class == pred_class else 'NO'
    print(
        f"Sample {i + 1}: True={true_class}, Predicted={pred_class}, "
        f"Confidence={confidence:.3f}, Correct={mark}"
    )
