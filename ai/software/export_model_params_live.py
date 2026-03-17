import argparse
from pathlib import Path

import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, Dropout, BatchNormalization, Input
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
from sklearn.model_selection import train_test_split

SEQ_LENGTH = 100 #window size, TODO: change when confirmed when bryan is done
FEATURES   = 6
NUM_CLASSES = 6
OUTPUT_DIR = Path(__file__).resolve().parent


def create_shape_model(input_shape=(SEQ_LENGTH, FEATURES), num_classes=NUM_CLASSES):
    model = Sequential([
        Input(shape=input_shape),

        Conv1D(32, kernel_size=3, activation='relu', padding='same', name='conv1d'),
        BatchNormalization(name='batch_normalization'),
        MaxPooling1D(pool_size=2),

        Conv1D(64, kernel_size=3, activation='relu', padding='same', name='conv1d_1'),
        BatchNormalization(name='batch_normalization_1'),
        MaxPooling1D(pool_size=2),

        Flatten(),
        Dense(128, activation='relu', name='dense'),
        Dropout(0.4),
        Dense(num_classes, activation='softmax', name='dense_1'),
    ])

    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    return model


def load_labeled_file(path: Path):
    """
    Expected file format
    --------------------
    Each gesture window is SEQ_LENGTH rows, followed by a blank line.
    Each row has 7 whitespace-separated values:

        label  ax  ay  az  gx  gy  gz

    where label (0..NUM_CLASSES-1) is repeated on every row of the window.
    Example (SEQ_LENGTH=3 for illustration):

        0  0.12  -0.34  0.98   45.3  -120.7   89.2
        0  0.15  -0.31  0.95   44.1  -118.3   87.5
        0  0.09  -0.36  0.99   46.0  -121.1   88.8

        1  0.45   0.11 -0.22   12.3    44.2   -3.1
        ...

    Returns
    -------
    X : float32 array, shape (N, SEQ_LENGTH, FEATURES)
    y : int32 array,   shape (N,)
    """
    raw_text = path.read_text()

    # Split on blank lines to get individual window blocks
    blocks = [b.strip() for b in raw_text.split('\n\n') if b.strip()]

    X_list, y_list = [], []

    for block_idx, block in enumerate(blocks):
        rows = block.strip().splitlines()

        if len(rows) != SEQ_LENGTH:
            raise ValueError(
                f"Block {block_idx + 1}: expected {SEQ_LENGTH} rows, "
                f"got {len(rows)}. "
                f"Check SEQ_LENGTH or your data file."
            )

        labels_in_block = []
        features_in_block = []

        for row_idx, row in enumerate(rows):
            vals = row.split()

            if len(vals) != 1 + FEATURES:
                raise ValueError(
                    f"Block {block_idx + 1}, row {row_idx + 1}: "
                    f"expected {1 + FEATURES} values, got {len(vals)}."
                )

            labels_in_block.append(int(float(vals[0])))
            features_in_block.append([float(v) for v in vals[1:]])

        # Confirm label is consistent across all rows in the window
        unique_labels = set(labels_in_block)
        if len(unique_labels) != 1:
            raise ValueError(
                f"Block {block_idx + 1}: inconsistent labels across rows: "
                f"{unique_labels}. All rows in a window must share the same label."
            )

        y_list.append(labels_in_block[0])
        X_list.append(features_in_block)

    X = np.array(X_list, dtype=np.float32)   # (N, SEQ_LENGTH, FEATURES)
    y = np.array(y_list,  dtype=np.int32)     # (N,)

    return X, y


def main():
    parser = argparse.ArgumentParser(description="Train model from labeled IMU windows")
    parser.add_argument("--data",         required=True, help="Path to labeled data file")
    parser.add_argument("--epochs",       type=int, default=20)
    parser.add_argument("--batch",        type=int, default=32)
    parser.add_argument("--test-samples", type=int, default=10)
    args = parser.parse_args()

    data_path = Path(args.data)
    if not data_path.exists():
        raise FileNotFoundError(f"Data file not found: {data_path}")

    X, y = load_labeled_file(data_path)
    print(f"Loaded dataset: X={X.shape}, y={y.shape}")
    print(f"  Window size:  {SEQ_LENGTH} timesteps x {FEATURES} channels")
    print(f"  Classes seen: {sorted(set(y.tolist()))}")

    # ------------------------------------------------------------------
    # Normalisation
    # Compute per-channel mean and std across ALL samples and timesteps.
    # Stats are saved to norm_stats.npy — SCP this to Ultra96 with your
    # bitstream. Apply the same transform in PYNQ before every DMA send.
    # ------------------------------------------------------------------
    mean = X.mean(axis=(0, 1))   # shape (FEATURES,)
    std  = X.std(axis=(0, 1))    # shape (FEATURES,)
    std[std < 1e-8] = 1.0        # guard against constant channels

    norm_stats_path = OUTPUT_DIR / 'norm_stats.npy'
    np.save(norm_stats_path, {'mean': mean, 'std': std})
    print(f"\nSaved normalisation stats → {norm_stats_path}")
    print(f"  mean: {mean}")
    print(f"  std:  {std}")

    X = (X - mean) / std         # normalise in-place before training

    # ------------------------------------------------------------------
    # Layer name sanity check — must match C++ weight array names
    # ------------------------------------------------------------------
    model = create_shape_model()

    expected_names = {
        'conv1d', 'batch_normalization',
        'conv1d_1', 'batch_normalization_1',
        'dense', 'dense_1',
    }
    actual_names = {l.name for l in model.layers if l.get_weights()}
    missing = expected_names - actual_names
    if missing:
        raise RuntimeError(
            f"Layer name mismatch — missing: {missing}\n"
            f"Actual layers with weights: {actual_names}\n"
            f"Update name= arguments in create_shape_model() to match."
        )
    print(f"\nLayer name check passed: {sorted(actual_names)}")

    # ------------------------------------------------------------------
    # Train / val split
    # ------------------------------------------------------------------
    y_categorical = tf.keras.utils.to_categorical(y, NUM_CLASSES)

    X_train, X_val, y_train, y_val = train_test_split(
        X, y_categorical, test_size=0.2, random_state=42, stratify=y
    )

    print(f"\nData split:")
    print(f"  Training:   {X_train.shape[0]} samples")
    print(f"  Validation: {X_val.shape[0]} samples")

    callbacks = [
        EarlyStopping(
            monitor='val_loss',
            patience=5,
            restore_best_weights=True,
            verbose=1
        ),
        ModelCheckpoint(
            str(OUTPUT_DIR / 'best_live_model.h5'),
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        )
    ]

    print("\nTraining model...")
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=args.epochs,
        batch_size=args.batch,
        callbacks=callbacks,
        verbose=1
    )

    val_loss, val_acc = model.evaluate(X_val, y_val, verbose=0)
    print(f"\nValidation Accuracy: {val_acc:.4f}")
    print(f"Validation Loss:     {val_loss:.4f}")
    print("Using best checkpoint only: best_live_model.h5")

    # ------------------------------------------------------------------
    # Export HLS reference files (normalised inputs)
    # reference_input.txt  → send directly to HLS testbench
    # reference_logits.txt → compare against HLS output logits
    # ------------------------------------------------------------------
    print("\nTesting predictions on sample windows...")
    test_samples = min(args.test_samples, X.shape[0])
    X_test = X[:test_samples]
    y_test = y[:test_samples]

    model = tf.keras.models.load_model(OUTPUT_DIR / 'best_live_model.h5')
    predictions = model.predict(X_test)
    predicted_classes = np.argmax(predictions, axis=1)

    # Export true logits (pre-softmax) for HLS comparison.
    logits_model = tf.keras.Model(inputs=model.input, outputs=model.layers[-1].input)
    logits = logits_model.predict(X_test)

    np.savetxt(OUTPUT_DIR / 'reference_input.txt',
               X_test.reshape(X_test.shape[0], -1), fmt='%.6f')
    np.savetxt(OUTPUT_DIR / 'reference_logits.txt',
               logits, fmt='%.6f')
    print("Saved reference_input.txt  (normalised — feed directly to HLS testbench)")
    print("Saved reference_logits.txt (true pre-softmax logits for comparison)")

    for i in range(test_samples):
        true_class = y_test[i]
        pred_class = predicted_classes[i]
        confidence = predictions[i][pred_class]
        mark = 'OK' if true_class == pred_class else 'NO'
        print(
            f"Sample {i + 1}: True={true_class}, Predicted={pred_class}, "
            f"Confidence={confidence:.3f}, Correct={mark}"
        )


if __name__ == "__main__":
    main()
