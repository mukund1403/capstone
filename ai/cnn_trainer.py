import argparse
import csv
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.utils.class_weight import compute_class_weight


RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)
tf.random.set_seed(RANDOM_SEED)


@dataclass
class DatasetArtifacts:
    X_train: np.ndarray
    X_val: np.ndarray
    y_train: np.ndarray
    y_val: np.ndarray
    mean: np.ndarray
    std: np.ndarray


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Train a 1D CNN gesture model for 6-class IMU slash recognition"
    )
    parser.add_argument("--data-dir", type=Path, default=Path("."), help="Folder containing gesture_*.csv files")
    parser.add_argument("--pattern", type=str, default="gesture_*.csv", help="Filename pattern for gesture files")
    parser.add_argument("--window-size", type=int, default=100, help="Sequence length per sample")
    parser.add_argument("--stride", type=int, default=25, help="Sliding window stride")
    parser.add_argument("--num-classes", type=int, default=6, help="Total gesture classes")
    parser.add_argument("--val-split", type=float, default=0.2, help="Validation split ratio")
    parser.add_argument("--batch-size", type=int, default=64, help="Training batch size")
    parser.add_argument("--epochs", type=int, default=80, help="Max training epochs")
    parser.add_argument("--learning-rate", type=float, default=1e-3, help="Initial Adam learning rate")
    parser.add_argument("--model-out", type=Path, default=Path("shape_recognition_model.h5"), help="Output model path")
    parser.add_argument("--best-model-out", type=Path, default=Path("best_gesture_model.h5"), help="Best-checkpoint model path")
    parser.add_argument("--norm-out", type=Path, default=Path("normalization_stats.npz"), help="Normalization stats output path")
    parser.add_argument("--label-map-out", type=Path, default=Path("label_map.json"), help="Class label map output path")
    parser.add_argument("--history-plot-out", type=Path, default=Path("training_history.png"), help="Training curve output path")
    return parser.parse_args()


def read_csv_features(csv_path: Path) -> Tuple[np.ndarray, int]:
    rows: List[List[float]] = []
    file_label = None

    with csv_path.open("r", newline="") as f:
        reader = csv.DictReader(f)
        required_cols = ["acc_x", "acc_y", "acc_z", "gyro_x", "gyro_y", "gyro_z", "label"]
        for col in required_cols:
            if col not in reader.fieldnames:
                raise ValueError(f"{csv_path} missing required column: {col}")

        for row in reader:
            try:
                features = [
                    float(row["acc_x"]),
                    float(row["acc_y"]),
                    float(row["acc_z"]),
                    float(row["gyro_x"]),
                    float(row["gyro_y"]),
                    float(row["gyro_z"]),
                ]
                label = int(float(row["label"]))
            except (TypeError, ValueError):
                continue

            rows.append(features)
            if file_label is None:
                file_label = label

    if not rows:
        raise ValueError(f"No valid IMU rows in {csv_path}")
    if file_label is None:
        raise ValueError(f"No valid labels in {csv_path}")

    return np.asarray(rows, dtype=np.float32), file_label


def window_signal(signal: np.ndarray, window_size: int, stride: int) -> np.ndarray:
    if signal.shape[0] < window_size:
        return np.empty((0, window_size, signal.shape[1]), dtype=np.float32)

    windows = []
    for start in range(0, signal.shape[0] - window_size + 1, stride):
        windows.append(signal[start : start + window_size])

    return np.asarray(windows, dtype=np.float32)


def load_dataset(data_dir: Path, pattern: str, window_size: int, stride: int, num_classes: int) -> Tuple[np.ndarray, np.ndarray]:
    files = sorted(data_dir.glob(pattern))
    if not files:
        raise FileNotFoundError(f"No files found in {data_dir} matching pattern '{pattern}'")

    X_all = []
    y_all = []

    for csv_path in files:
        signal, label = read_csv_features(csv_path)
        if label < 0 or label >= num_classes:
            raise ValueError(f"Label {label} out of range [0, {num_classes - 1}] in {csv_path}")

        windows = window_signal(signal, window_size=window_size, stride=stride)
        if len(windows) == 0:
            continue

        X_all.append(windows)
        y_all.append(np.full((windows.shape[0],), label, dtype=np.int32))

    if not X_all:
        raise ValueError("No training windows created. Check window size, stride, and data quality.")

    X = np.concatenate(X_all, axis=0)
    y = np.concatenate(y_all, axis=0)
    return X, y


def normalize_train_val(
    X_train: np.ndarray,
    X_val: np.ndarray,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    # Global per-channel normalization using only training set stats.
    mean = X_train.reshape(-1, X_train.shape[-1]).mean(axis=0)
    std = X_train.reshape(-1, X_train.shape[-1]).std(axis=0)
    std = np.where(std < 1e-6, 1.0, std)

    X_train_norm = (X_train - mean) / std
    X_val_norm = (X_val - mean) / std
    return X_train_norm.astype(np.float32), X_val_norm.astype(np.float32), mean.astype(np.float32), std.astype(np.float32)


def build_model(window_size: int, n_features: int, n_classes: int, learning_rate: float) -> tf.keras.Model:
    model = tf.keras.Sequential(
        [
            tf.keras.layers.Input(shape=(window_size, n_features)),
            tf.keras.layers.Conv1D(32, kernel_size=5, padding="same", activation="relu"),
            tf.keras.layers.MaxPooling1D(pool_size=2),
            tf.keras.layers.Conv1D(64, kernel_size=3, padding="same", activation="relu"),
            tf.keras.layers.MaxPooling1D(pool_size=2),
            tf.keras.layers.Conv1D(96, kernel_size=3, padding="same", activation="relu"),
            tf.keras.layers.GlobalAveragePooling1D(),
            tf.keras.layers.Dense(64, activation="relu"),
            tf.keras.layers.Dropout(0.3),
            tf.keras.layers.Dense(n_classes, activation="softmax"),
        ]
    )

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def prepare_data(args: argparse.Namespace) -> DatasetArtifacts:
    X, y = load_dataset(
        data_dir=args.data_dir,
        pattern=args.pattern,
        window_size=args.window_size,
        stride=args.stride,
        num_classes=args.num_classes,
    )

    X_train, X_val, y_train, y_val = train_test_split(
        X,
        y,
        test_size=args.val_split,
        random_state=RANDOM_SEED,
        stratify=y,
    )

    X_train, X_val, mean, std = normalize_train_val(X_train, X_val)

    return DatasetArtifacts(
        X_train=X_train,
        X_val=X_val,
        y_train=y_train,
        y_val=y_val,
        mean=mean,
        std=std,
    )


def train_model(model: tf.keras.Model, data: DatasetArtifacts, args: argparse.Namespace) -> tf.keras.callbacks.History:
    class_weights_array = compute_class_weight(
        class_weight="balanced",
        classes=np.unique(data.y_train),
        y=data.y_train,
    )
    class_weight = {int(c): float(w) for c, w in zip(np.unique(data.y_train), class_weights_array)}

    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_loss",
            patience=10,
            restore_best_weights=True,
            verbose=1,
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.5,
            patience=4,
            min_lr=1e-5,
            verbose=1,
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=str(args.best_model_out),
            monitor="val_accuracy",
            mode="max",
            save_best_only=True,
            verbose=1,
        ),
    ]

    history = model.fit(
        data.X_train,
        data.y_train,
        validation_data=(data.X_val, data.y_val),
        epochs=args.epochs,
        batch_size=args.batch_size,
        class_weight=class_weight,
        callbacks=callbacks,
        verbose=1,
    )
    return history


def evaluate_model(model: tf.keras.Model, data: DatasetArtifacts) -> None:
    val_loss, val_acc = model.evaluate(data.X_val, data.y_val, verbose=0)
    print(f"Validation loss: {val_loss:.4f}")
    print(f"Validation accuracy: {val_acc:.4f}")

    probs = model.predict(data.X_val, verbose=0)
    preds = np.argmax(probs, axis=1)

    print("\nClassification report:")
    print(classification_report(data.y_val, preds, digits=4))

    print("Confusion matrix:")
    print(confusion_matrix(data.y_val, preds))


def save_artifacts(model: tf.keras.Model, history: tf.keras.callbacks.History, data: DatasetArtifacts, args: argparse.Namespace) -> None:
    model.save(args.model_out)
    np.savez(args.norm_out, mean=data.mean, std=data.std)

    label_map: Dict[str, str] = {
        "0": "slash_left",
        "1": "slash_right",
        "2": "slash_up",
        "3": "slash_down",
        "4": "throw_bomb",
        "5": "time_slow",
    }
    with args.label_map_out.open("w", encoding="utf-8") as f:
        json.dump(label_map, f, indent=2)

    plt.figure(figsize=(12, 4))
    plt.subplot(1, 2, 1)
    plt.plot(history.history["accuracy"], label="train_acc")
    plt.plot(history.history["val_accuracy"], label="val_acc")
    plt.xlabel("Epoch")
    plt.ylabel("Accuracy")
    plt.title("Training Accuracy")
    plt.legend()
    plt.grid(True)

    plt.subplot(1, 2, 2)
    plt.plot(history.history["loss"], label="train_loss")
    plt.plot(history.history["val_loss"], label="val_loss")
    plt.xlabel("Epoch")
    plt.ylabel("Loss")
    plt.title("Training Loss")
    plt.legend()
    plt.grid(True)

    plt.tight_layout()
    plt.savefig(args.history_plot_out, dpi=250)

    print(f"Saved model: {args.model_out}")
    print(f"Saved best checkpoint: {args.best_model_out}")
    print(f"Saved normalization stats: {args.norm_out}")
    print(f"Saved label map: {args.label_map_out}")
    print(f"Saved training plot: {args.history_plot_out}")


def main() -> None:
    args = parse_args()

    print("Loading and preparing IMU dataset...")
    data = prepare_data(args)
    print(f"Train set: {data.X_train.shape}, labels: {data.y_train.shape}")
    print(f"Val set:   {data.X_val.shape}, labels: {data.y_val.shape}")

    model = build_model(
        window_size=args.window_size,
        n_features=data.X_train.shape[-1],
        n_classes=args.num_classes,
        learning_rate=args.learning_rate,
    )
    model.summary()

    history = train_model(model, data, args)
    evaluate_model(model, data)
    save_artifacts(model, history, data, args)


if __name__ == "__main__":
    main()
