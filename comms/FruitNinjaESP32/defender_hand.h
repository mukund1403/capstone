#include <Wire.h>

// --- Pin Definitions ---
#define PIN_SDA         21
#define PIN_SCL         22

// --- MPU6050 I2C Address ---
#define MPU_ADDR        0x68

// --- Timing ---
#define READ_INTERVAL_MS  20

// --- MPU6050 sensitivities ---
#define ACC_LSB_PER_G     16384.0f
#define GYRO_LSB_PER_DPS  131.0f

// --- Filter coefficients ---
#define ACC_ALPHA         0.85f
#define GYRO_ALPHA        0.85f
#define GRAV_ALPHA        0.98f

unsigned long lastReadTime = 0;

typedef void (*PublishFn)(float, float, float, float, float, float);
typedef void (*PublishPauseFn)(int);

// ============================================================
// Structs
// ============================================================
typedef struct {
  int16_t ax_raw, ay_raw, az_raw;
  int16_t gx_raw, gy_raw, gz_raw;
} IMURaw_t;

typedef struct {
  float ax_g, ay_g, az_g;
  float gx_dps, gy_dps, gz_dps;
} IMUScaled_t;

typedef struct {
  float ax_g, ay_g, az_g;
  float gx_dps, gy_dps, gz_dps;
} IMUFiltered_t;

typedef struct {
  float gx_bias_raw, gy_bias_raw, gz_bias_raw;
} GyroBias_t;

typedef struct {
  float gx, gy, gz;
} GravityEstimate_t;

typedef struct {
  float x, y, z;
} Vec3f_t;

// ============================================================
// Globals
// ============================================================
GyroBias_t gyroBias = {0};
IMUFiltered_t imuFiltered = {0};
GravityEstimate_t gravityEst = {0, 0, 1};
Vec3f_t linearAcc = {0};

// ============================================================
// Utility
// ============================================================
float lowPass(float prev, float curr, float alpha) {
  return alpha * prev + (1.0f - alpha) * curr;
}

// ============================================================
// I2C Functions
// ============================================================
void initMPU(TwoWire &bus, uint8_t addr) {
  bus.beginTransmission(addr);
  bus.write(0x6B);
  bus.write(0x00);
  bus.endTransmission();
}

void readMPU(TwoWire &bus, uint8_t addr, IMURaw_t *raw) {
  bus.beginTransmission(addr);
  bus.write(0x3B);
  bus.endTransmission(false);
  bus.requestFrom(addr, (uint8_t)14);

  raw->ax_raw = (bus.read() << 8) | bus.read();
  raw->ay_raw = (bus.read() << 8) | bus.read();
  raw->az_raw = (bus.read() << 8) | bus.read();
  int16_t temp = (bus.read() << 8) | bus.read();
  (void)temp;
  raw->gx_raw = (bus.read() << 8) | bus.read();
  raw->gy_raw = (bus.read() << 8) | bus.read();
  raw->gz_raw = (bus.read() << 8) | bus.read();
}

// ============================================================
// Calibration
// ============================================================
void calibrateGyro(TwoWire &bus, uint8_t addr, GyroBias_t *bias) {
  const int samples = 200;

  long gx_sum = 0, gy_sum = 0, gz_sum = 0;

  for (int i = 0; i < samples; i++) {
    IMURaw_t raw;
    readMPU(bus, addr, &raw);

    gx_sum += raw.gx_raw;
    gy_sum += raw.gy_raw;
    gz_sum += raw.gz_raw;

    delay(5);
  }

  bias->gx_bias_raw = (float)gx_sum / samples;
  bias->gy_bias_raw = (float)gy_sum / samples;
  bias->gz_bias_raw = (float)gz_sum / samples;
}

// ============================================================
// Processing
// ============================================================
void scaleIMU(const IMURaw_t *raw, const GyroBias_t *bias, IMUScaled_t *scaled) {
  scaled->ax_g = raw->ax_raw / ACC_LSB_PER_G;
  scaled->ay_g = raw->ay_raw / ACC_LSB_PER_G;
  scaled->az_g = raw->az_raw / ACC_LSB_PER_G;

  scaled->gx_dps = (raw->gx_raw - bias->gx_bias_raw) / GYRO_LSB_PER_DPS;
  scaled->gy_dps = (raw->gy_raw - bias->gy_bias_raw) / GYRO_LSB_PER_DPS;
  scaled->gz_dps = (raw->gz_raw - bias->gz_bias_raw) / GYRO_LSB_PER_DPS;
}

void filterIMU(const IMUScaled_t *scaled, IMUFiltered_t *filtered) {
  filtered->ax_g = lowPass(filtered->ax_g, scaled->ax_g, ACC_ALPHA);
  filtered->ay_g = lowPass(filtered->ay_g, scaled->ay_g, ACC_ALPHA);
  filtered->az_g = lowPass(filtered->az_g, scaled->az_g, ACC_ALPHA);

  filtered->gx_dps = lowPass(filtered->gx_dps, scaled->gx_dps, GYRO_ALPHA);
  filtered->gy_dps = lowPass(filtered->gy_dps, scaled->gy_dps, GYRO_ALPHA);
  filtered->gz_dps = lowPass(filtered->gz_dps, scaled->gz_dps, GYRO_ALPHA);
}

void updateGravityEstimate(const IMUFiltered_t *filtered, GravityEstimate_t *grav) {
  grav->gx = lowPass(grav->gx, filtered->ax_g, GRAV_ALPHA);
  grav->gy = lowPass(grav->gy, filtered->ay_g, GRAV_ALPHA);
  grav->gz = lowPass(grav->gz, filtered->az_g, GRAV_ALPHA);
}

void computeLinearAcceleration(const IMUFiltered_t *filtered,
                               const GravityEstimate_t *grav,
                               Vec3f_t *linAccOut) {
  linAccOut->x = filtered->ax_g - grav->gx;
  linAccOut->y = filtered->ay_g - grav->gy;
  linAccOut->z = filtered->az_g - grav->gz;
}

// ============================================================
// SETUP
// ============================================================
void hardwareSetup() {
  Wire.begin(PIN_SDA, PIN_SCL);
  initMPU(Wire, MPU_ADDR);

  delay(500);
  calibrateGyro(Wire, MPU_ADDR, &gyroBias);
}

// ============================================================
// LOOP
// ============================================================
void hardwareLoop(PublishFn publishFn) {
  unsigned long now = millis();

  if (now - lastReadTime >= READ_INTERVAL_MS) {
    lastReadTime = now;

    IMURaw_t raw;
    IMUScaled_t scaled;

    readMPU(Wire, MPU_ADDR, &raw);
    scaleIMU(&raw, &gyroBias, &scaled);
    filterIMU(&scaled, &imuFiltered);
    updateGravityEstimate(&imuFiltered, &gravityEst);
    computeLinearAcceleration(&imuFiltered, &gravityEst, &linearAcc);

    publishFn(
      linearAcc.x, linearAcc.y, linearAcc.z,
      imuFiltered.gx_dps, imuFiltered.gy_dps, imuFiltered.gz_dps
    );
  }
}