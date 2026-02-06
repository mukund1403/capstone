import serial
import csv
import time

def collect_training_data(port='COM3', baudrate=115200, label=0):
    """Collect IMU data for a specific gesture"""
    
    ser = serial.Serial(port, baudrate, timeout=1)
    filename = f'gesture_{label}_{int(time.time())}.csv'
    
    print(f"Recording gesture {label}. Press Enter to start, then perform gesture...")
    input()
    
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['timestamp', 'acc_x', 'acc_y', 'acc_z', 
                        'gyro_x', 'gyro_y', 'gyro_z', 'label'])
        
        start_time = time.time()
        print("Recording... Press Ctrl+C to stop")
        
        try:
            while True:
                if ser.in_waiting:
                    line = ser.readline().decode('utf-8').strip()
                    if line:
                        values = line.split(',')
                        if len(values) >= 6:
                            timestamp = time.time() - start_time
                            row = [timestamp] + [float(v) for v in values[:6]] + [label]
                            writer.writerow(row)
                            print(f"Data: {values[:6]}")
        except KeyboardInterrupt:
            print(f"\nData saved to {filename}")
    
    ser.close()
