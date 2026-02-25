import argparse
import numpy as np
from pynq import Overlay, allocate


SEQ_LEN = 100
FEATURES = 6
NUM_CLASSES = 6
INPUT_LEN = SEQ_LEN * FEATURES


def load_reference_input(path, sample_idx):
    data = np.loadtxt(path, dtype=np.float32)
    if data.ndim == 1:
        data = data.reshape(1, -1)
    if sample_idx < 0 or sample_idx >= data.shape[0]:
        raise IndexError(f"sample {sample_idx} out of range, file has {data.shape[0]} rows")
    row = data[sample_idx]
    if row.size != INPUT_LEN:
        raise ValueError(f"expected {INPUT_LEN} values per row, got {row.size}")
    return row.astype(np.float32)


def load_reference_logits(path, sample_idx):
    data = np.loadtxt(path, dtype=np.float32)
    if data.ndim == 1:
        data = data.reshape(1, -1)
    if sample_idx < 0 or sample_idx >= data.shape[0]:
        raise IndexError(f"sample {sample_idx} out of range, file has {data.shape[0]} rows")
    row = data[sample_idx]
    if row.size != NUM_CLASSES:
        raise ValueError(f"expected {NUM_CLASSES} logits per row, got {row.size}")
    return row.astype(np.float32)


def main():
    parser = argparse.ArgumentParser(description="Run CNN IP via AXI DMA on Ultra96")
    parser.add_argument("--bit", required=True, help="Path to .bit file (matching .hwh must be present)")
    parser.add_argument("--input", default="reference_input.txt", help="Path to reference_input.txt")
    parser.add_argument("--sample", type=int, default=0, help="Row index to run from input file")
    parser.add_argument("--dma", default="axi_dma_0", help="DMA IP name in overlay")
    parser.add_argument("--ip", default="cnn_gesture_top_0", help="CNN IP name in overlay")
    parser.add_argument("--ref-logits", default=None, help="Optional reference_logits.txt for comparison")
    args = parser.parse_args()

    ol = Overlay(args.bit)
    dma = getattr(ol, args.dma)
    ip = getattr(ol, args.ip)

    x = load_reference_input(args.input, args.sample)

    in_buf = allocate(shape=(INPUT_LEN,), dtype=np.float32)
    out_buf = allocate(shape=(NUM_CLASSES,), dtype=np.float32)
    in_buf[:] = x
    out_buf[:] = 0.0

    # ap_ctrl_hs start bit
    ip.write(0x00, 0x01)

    dma.recvchannel.transfer(out_buf)
    dma.sendchannel.transfer(in_buf)
    dma.sendchannel.wait()
    dma.recvchannel.wait()

    y = np.array(out_buf, dtype=np.float32)
    pred = int(np.argmax(y))
    print("Output:", y.tolist())
    print("Predicted class:", pred)

    if args.ref_logits:
        ref = load_reference_logits(args.ref_logits, args.sample)
        err = np.abs(y - ref)
        print("Reference class:", int(np.argmax(ref)))
        print("Argmax match:", bool(np.argmax(ref) == pred))
        print("Max abs error:", float(np.max(err)))

    in_buf.freebuffer()
    out_buf.freebuffer()


if __name__ == "__main__":
    main()