import argparse
import tempfile
from pathlib import Path

import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
from tensorflow.keras.layers import (
    BatchNormalization,
    Conv1D,
    Dense,
    Dropout,
    Flatten,
    Input,
    MaxPooling1D,
)
from tensorflow.keras.models import Sequential

try:
    import optuna
except ImportError:
    optuna = None


SEQ_LENGTH = 75  # window size (1.5s @ 50Hz)
FEATURES = 6
NUM_CLASSES = 8
OUTPUT_DIR = Path(__file__).resolve().parent
RANDOM_STATE = 42


def create_shape_model(
    input_shape=(SEQ_LENGTH, FEATURES),
    num_classes=NUM_CLASSES,
    *,
    conv1_filters=32,
    conv2_filters=64,
    kernel_size=3,
    dense_units=128,
    dropout_rate=0.4,
    learning_rate=1e-3,
):
    model = Sequential([
        Input(shape=input_shape),
        Conv1D(
            conv1_filters,
            kernel_size=kernel_size,
            activation="relu",
            padding="same",
            name="conv1d",
        ),
        BatchNormalization(name="batch_normalization"),
        MaxPooling1D(pool_size=2),
        Conv1D(
            conv2_filters,
            kernel_size=kernel_size,
            activation="relu",
            padding="same",
            name="conv1d_1",
        ),
        BatchNormalization(name="batch_normalization_1"),
        MaxPooling1D(pool_size=2),
        Flatten(),
        Dense(dense_units, activation="relu", name="dense"),
        Dropout(dropout_rate),
        Dense(num_classes, activation="softmax", name="dense_1"),
    ])

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def load_labeled_file(path: Path):
    """
    Each gesture window is SEQ_LENGTH rows, followed by a blank line.
    Each row has 7 whitespace-separated values:

        label  ax  ay  az  gx  gy  gz
    """
    raw_text = path.read_text()
    blocks = [b.strip() for b in raw_text.split("\n\n") if b.strip()]

    X_list, y_list = [], []

    for block_idx, block in enumerate(blocks):
        rows = block.strip().splitlines()
        if len(rows) != SEQ_LENGTH:
            raise ValueError(
                f"Block {block_idx + 1}: expected {SEQ_LENGTH} rows, got {len(rows)}."
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

        unique_labels = set(labels_in_block)
        if len(unique_labels) != 1:
            raise ValueError(
                f"Block {block_idx + 1}: inconsistent labels across rows: {unique_labels}."
            )

        y_list.append(labels_in_block[0])
        X_list.append(features_in_block)

    X = np.array(X_list, dtype=np.float32)
    y = np.array(y_list, dtype=np.int32)
    return X, y


def validate_labels(y: np.ndarray):
    if y.size == 0:
        raise ValueError("Dataset is empty.")

    classes_seen = sorted(set(y.tolist()))
    invalid = [label for label in classes_seen if label < 0 or label >= NUM_CLASSES]
    if invalid:
        raise ValueError(
            f"Found labels outside valid range 0..{NUM_CLASSES - 1}: {invalid}. "
            f"Classes seen: {classes_seen}"
        )


def check_layer_names(model):
    expected_names = {
        "conv1d",
        "batch_normalization",
        "conv1d_1",
        "batch_normalization_1",
        "dense",
        "dense_1",
    }
    actual_names = {layer.name for layer in model.layers if layer.get_weights()}
    missing = expected_names - actual_names
    if missing:
        raise RuntimeError(
            f"Layer name mismatch - missing: {missing}\n"
            f"Actual layers with weights: {actual_names}\n"
            "Update layer name= arguments to match the HLS export expectations."
        )


def split_dataset(X: np.ndarray, y: np.ndarray):
    X_trainval, X_test, y_trainval, y_test = train_test_split(
        X,
        y,
        test_size=0.15,
        random_state=RANDOM_STATE,
        stratify=y,
    )

    val_ratio_within_trainval = 0.15 / 0.85
    X_train, X_val, y_train, y_val = train_test_split(
        X_trainval,
        y_trainval,
        test_size=val_ratio_within_trainval,
        random_state=RANDOM_STATE,
        stratify=y_trainval,
    )
    return X_train, X_val, X_test, y_train, y_val, y_test


def compute_norm_stats(X_train: np.ndarray):
    mean = X_train.mean(axis=(0, 1)).astype(np.float32)
    std = X_train.std(axis=(0, 1)).astype(np.float32)
    std[std < 1e-8] = 1.0
    return mean, std


def normalize_dataset(X: np.ndarray, mean: np.ndarray, std: np.ndarray):
    return ((X - mean) / std).astype(np.float32)


def to_categorical(y: np.ndarray):
    return tf.keras.utils.to_categorical(y, NUM_CLASSES)


def train_once(
    X_train,
    y_train,
    X_val,
    y_val,
    *,
    epochs,
    batch_size,
    checkpoint_path: Path,
    model_params,
    verbose=1,
):
    model = create_shape_model(**model_params)
    check_layer_names(model)

    callbacks = [
        EarlyStopping(
            monitor="val_loss",
            patience=5,
            restore_best_weights=True,
            verbose=verbose,
        ),
        ModelCheckpoint(
            str(checkpoint_path),
            monitor="val_accuracy",
            save_best_only=True,
            verbose=verbose,
        ),
    ]

    model.fit(
        X_train,
        y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        callbacks=callbacks,
        verbose=verbose,
    )

    model = tf.keras.models.load_model(checkpoint_path)
    val_loss, val_acc = model.evaluate(X_val, y_val, verbose=0)
    return model, val_loss, val_acc


def suggest_model_params(trial):
    return {
        "conv1_filters": trial.suggest_categorical("conv1_filters", [16, 32, 48]),
        "conv2_filters": trial.suggest_categorical("conv2_filters", [32, 64, 96]),
        "kernel_size": trial.suggest_categorical("kernel_size", [3, 5]),
        "dense_units": trial.suggest_categorical("dense_units", [64, 128, 192]),
        "dropout_rate": trial.suggest_float("dropout_rate", 0.2, 0.5),
        "learning_rate": trial.suggest_float("learning_rate", 1e-4, 3e-3, log=True),
    }


def build_logits(model, X_data):
    feature_model = tf.keras.Model(inputs=model.inputs, outputs=model.layers[-2].output)
    features = feature_model.predict(X_data, verbose=0)
    final_kernel, final_bias = model.layers[-1].get_weights()
    return features @ final_kernel + final_bias


def main():
    parser = argparse.ArgumentParser(description="Train model from labeled IMU windows")
    parser.add_argument("--data", required=True, help="Path to labeled data file")
    parser.add_argument("--epochs", type=int, default=20)
    parser.add_argument("--batch", type=int, default=32)
    parser.add_argument("--test-samples", type=int, default=10)
    parser.add_argument(
        "--optuna-trials",
        type=int,
        default=0,
        help="Number of Optuna trials before final training. 0 disables Optuna.",
    )
    args = parser.parse_args()

    if args.optuna_trials > 0 and optuna is None:
        raise ImportError(
            "Optuna is not installed. Install it with 'pip install optuna' "
            "or rerun with --optuna-trials 0."
        )

    data_path = Path(args.data)
    if not data_path.exists():
        raise FileNotFoundError(f"Data file not found: {data_path}")

    X, y = load_labeled_file(data_path)
    validate_labels(y)
    print(f"Loaded dataset: X={X.shape}, y={y.shape}")
    print(f"  Window size:  {SEQ_LENGTH} timesteps x {FEATURES} channels")
    print(f"  Classes seen: {sorted(set(y.tolist()))}")

    X_train_raw, X_val_raw, X_test_raw, y_train, y_val, y_test = split_dataset(X, y)
    mean, std = compute_norm_stats(X_train_raw)

    X_train = normalize_dataset(X_train_raw, mean, std)
    X_val = normalize_dataset(X_val_raw, mean, std)
    X_test = normalize_dataset(X_test_raw, mean, std)

    y_train_cat = to_categorical(y_train)
    y_val_cat = to_categorical(y_val)
    y_test_cat = to_categorical(y_test)

    print("\nData split:")
    print(f"  Training:   {X_train.shape[0]} samples")
    print(f"  Validation: {X_val.shape[0]} samples")
    print(f"  Test:       {X_test.shape[0]} samples")

    base_model_params = {
        "conv1_filters": 32,
        "conv2_filters": 64,
        "kernel_size": 3,
        "dense_units": 128,
        "dropout_rate": 0.4,
        "learning_rate": 1e-3,
    }

    best_model_params = dict(base_model_params)
    best_batch_size = args.batch

    if args.optuna_trials > 0:
        print(f"\nRunning Optuna for {args.optuna_trials} trial(s)...")

        def objective(trial):
            model_params = suggest_model_params(trial)
            batch_size = trial.suggest_categorical("batch_size", [16, 32, 64])

            with tempfile.TemporaryDirectory(dir=OUTPUT_DIR) as trial_tmp_dir_name:
                checkpoint_path = Path(trial_tmp_dir_name) / "trial_best_model.h5"
                _, _, val_acc = train_once(
                    X_train,
                    y_train_cat,
                    X_val,
                    y_val_cat,
                    epochs=args.epochs,
                    batch_size=batch_size,
                    checkpoint_path=checkpoint_path,
                    model_params=model_params,
                    verbose=0,
                )
            return val_acc

        study = optuna.create_study(direction="maximize")
        study.optimize(objective, n_trials=args.optuna_trials)
        best_model_params = suggest_model_params(study.best_trial)
        best_batch_size = study.best_trial.params["batch_size"]

        print("\nBest Optuna params:")
        for key, value in study.best_trial.params.items():
            print(f"  {key}: {value}")
        print(f"  Best validation accuracy: {study.best_value:.4f}")

    final_checkpoint_path = OUTPUT_DIR / "best_live_model.h5"
    norm_stats_path = OUTPUT_DIR / "norm_stats.npy"
    reference_input_path = OUTPUT_DIR / "reference_input.txt"
    reference_logits_path = OUTPUT_DIR / "reference_logits.txt"

    with tempfile.TemporaryDirectory(dir=OUTPUT_DIR) as tmp_dir_name:
        tmp_dir = Path(tmp_dir_name)
        checkpoint_path = tmp_dir / "best_live_model.h5"

        print("\nTraining final model...")
        model, val_loss, val_acc = train_once(
            X_train,
            y_train_cat,
            X_val,
            y_val_cat,
            epochs=args.epochs,
            batch_size=best_batch_size,
            checkpoint_path=checkpoint_path,
            model_params=best_model_params,
            verbose=1,
        )

        test_loss, test_acc = model.evaluate(X_test, y_test_cat, verbose=0)

        export_count = min(args.test_samples, X_test.shape[0])
        X_ref = X_test[:export_count]
        y_ref = y_test[:export_count]

        predictions = model.predict(X_ref, verbose=0)
        predicted_classes = np.argmax(predictions, axis=1)
        logits = build_logits(model, X_ref)

        tmp_norm_stats_path = tmp_dir / "norm_stats.npy"
        tmp_reference_input_path = tmp_dir / "reference_input.txt"
        tmp_reference_logits_path = tmp_dir / "reference_logits.txt"

        np.save(tmp_norm_stats_path, {"mean": mean, "std": std})
        np.savetxt(
            tmp_reference_input_path,
            X_ref.reshape(X_ref.shape[0], -1),
            fmt="%.6f",
        )
        np.savetxt(tmp_reference_logits_path, logits, fmt="%.6f")

        checkpoint_path.replace(final_checkpoint_path)
        tmp_norm_stats_path.replace(norm_stats_path)
        tmp_reference_input_path.replace(reference_input_path)
        tmp_reference_logits_path.replace(reference_logits_path)

    print(f"\nSaved normalisation stats -> {norm_stats_path}")
    print(f"  mean: {mean}")
    print(f"  std:  {std}")
    print("\nFinal model metrics:")
    print(f"  Validation Accuracy: {val_acc:.4f}")
    print(f"  Validation Loss:     {val_loss:.4f}")
    print(f"  Test Accuracy:       {test_acc:.4f}")
    print(f"  Test Loss:           {test_loss:.4f}")
    print("Using best checkpoint only: best_live_model.h5")
    print("Saved reference_input.txt  (normalised - feed directly to HLS testbench)")
    print("Saved reference_logits.txt (true pre-softmax logits for comparison)")

    for i in range(export_count):
        true_class = y_ref[i]
        pred_class = predicted_classes[i]
        confidence = predictions[i][pred_class]
        mark = "OK" if true_class == pred_class else "NO"
        print(
            f"Sample {i + 1}: True={true_class}, Predicted={pred_class}, "
            f"Confidence={confidence:.3f}, Correct={mark}"
        )


if __name__ == "__main__":
    main()
