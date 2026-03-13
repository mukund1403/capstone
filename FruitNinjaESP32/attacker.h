#include <Wire.h>

// --- Pin Definitions ---
#define PIN_SDA         21
#define PIN_SCL         22

// --- MPU6050 I2C Address ---
#define MPU_ADDR        0x68

// --- Timing ---
#define READ_INTERVAL_MS  20

unsigned long lastReadTime = 0;

typedef void (*PublishFn)(int16_t, int16_t, int16_t, int16_t, int16_t, int16_t);
typedef void (*PublishPauseFn)(int);

// ============================================================
// I2C Functions
// ============================================================
void initMPU(TwoWire &bus, uint8_t addr) {
  bus.beginTransmission(addr);
  bus.write(0x6B);
  bus.write(0x00);
  bus.endTransmission();
}

void readMPU(TwoWire &bus, uint8_t addr,
             int16_t *ax, int16_t *ay, int16_t *az,
             int16_t *gx, int16_t *gy, int16_t *gz) {
  bus.beginTransmission(addr);
  bus.write(0x3B);
  bus.endTransmission(false);
  bus.requestFrom(addr, (uint8_t)14);
  *ax = (bus.read() << 8) | bus.read();
  *ay = (bus.read() << 8) | bus.read();
  *az = (bus.read() << 8) | bus.read();
  int16_t temp = (bus.read() << 8) | bus.read();
  *gx = (bus.read() << 8) | bus.read();
  *gy = (bus.read() << 8) | bus.read();
  *gz = (bus.read() << 8) | bus.read();
}

// ============================================================
// SETUP
// ============================================================
void hardwareSetup() {
  // Serial.begin(115200);
  Wire.begin(PIN_SDA, PIN_SCL);
  initMPU(Wire, MPU_ADDR);
}

// ============================================================
// LOOP
// ============================================================
void hardwareLoop(PublishFn publishFn, PublishPauseFn pauseFn) {
  unsigned long now = millis();

  if (now - lastReadTime >= READ_INTERVAL_MS) {
    lastReadTime = now;
    int16_t ax, ay, az, gx, gy, gz;
    readMPU(Wire, MPU_ADDR, &ax, &ay, &az, &gx, &gy, &gz);
    publishFn(ax, ay, az, gx, gy, gz);
  }
}