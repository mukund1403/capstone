import os
from glob import glob

# Change this to your folder if needed
folder = "./data_collection/defender_sword_idle"

output_file = "./data_collection/defender_sword_idle/combined.txt"

# Get all imu_*.txt files and sort them
files = sorted(glob(os.path.join(folder, "imu_*.txt")))

print(f"Found {len(files)} files")

with open(output_file, "w") as outfile:
    for i, file in enumerate(files):
        print(f"Adding: {file}")

        with open(file, "r") as f:
            outfile.write(f.read().strip())

        # Add ONE blank line between files (not after last)
        if i != len(files) - 1:
            outfile.write("\n\n")

print(f"\nDone! Output saved to {output_file}")