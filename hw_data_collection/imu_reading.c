#include <Wire.h>

#define SDA_PIN 21
#define SCL_PIN 22
#define MPU_ADDR 0x68

#define PWR_MGMT_1 0x6B
#define ACCEL_XOUT_H 0x3B

bool loggingEnabled = false;

void setup() {
  Serial.begin(115200);
  delay(1000);

  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(400000);

  Wire.beginTransmission(MPU_ADDR);
  Wire.write(PWR_MGMT_1);
  Wire.write(0x00);
  Wire.endTransmission();

  Serial.println("MPU6050 initialized");
  Serial.println("Type '1' + ENTER to start/stop logging");
  Serial.println("FORMAT: ax,ay,az,gx,gy,gz");
}

void loop() {
  if (Serial.available()) {
    char c = Serial.read();
    if (c == '1') {
      loggingEnabled = !loggingEnabled;
      Serial.println(loggingEnabled ? "LOG_START" : "LOG_STOP");
    }
    // optional: clear extra chars like '\n'
  }

  if (!loggingEnabled) return;

  int16_t ax, ay, az, gx, gy, gz;

  Wire.beginTransmission(MPU_ADDR);
  Wire.write(ACCEL_XOUT_H);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);

  ax = (Wire.read() << 8) | Wire.read();
  ay = (Wire.read() << 8) | Wire.read();
  az = (Wire.read() << 8) | Wire.read();
  Wire.read(); Wire.read(); // temp
  gx = (Wire.read() << 8) | Wire.read();
  gy = (Wire.read() << 8) | Wire.read();
  gz = (Wire.read() << 8) | Wire.read();

  Serial.printf("%d,%d,%d,%d,%d,%d\n", ax, ay, az, gx, gy, gz);

  delay(10); // ~100 Hz
}
