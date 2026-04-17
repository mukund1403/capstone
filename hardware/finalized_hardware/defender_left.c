#include <Wire.h>

// --- Pin Definitions ---
#define PIN_SDA           21
#define PIN_SCL           22

// --- MPU6050 I2C Address ---
#define MPU_ADDR          0x68

// --- Timing ---
#define READ_INTERVAL_MS  20   // 50 Hz

// --- MPU6050 default sensitivities ---
#define ACC_LSB_PER_G     16384.0f
#define GYRO_LSB_PER_DPS  131.0f

// --- Filter coefficients ---
#define ACC_ALPHA         0.85f
#define GYRO_ALPHA        0.85f
#define GRAV_ALPHA        0.98f

unsigned long lastReadTime = 0;

// ============================================================
// Structs
// ============================================================
typedef struct {
  int16_t ax_raw;
  int16_t ay_raw;
  int16_t az_raw;
  int16_t gx_raw;
  int16_t gy_raw;
  int16_t gz_raw;
} IMURaw_t;

typedef struct {
  float ax_g;
  float ay_g;
  float az_g;
  float gx_dps;
  float gy_dps;
  float gz_dps;
} IMUScaled_t;

typedef struct {
  float ax_g;
  float ay_g;
  float az_g;
  float gx_dps;
  float gy_dps;
  float gz_dps;
} IMUFiltered_t;

typedef struct {
  float gx_bias_raw;
  float gy_bias_raw;
  float gz_bias_raw;
} GyroBias_t;

typedef struct {
  float gx;
  float gy;
  float gz;
} GravityEstimate_t;

typedef struct {
  float x;
  float y;
  float z;
} Vec3f_t;

// ============================================================
// Globals
// ============================================================
GyroBias_t gyroBias = {0.0f, 0.0f, 0.0f};

IMUFiltered_t imuFiltered = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
GravityEstimate_t gravityEst = {0.0f, 0.0f, 1.0f};

Vec3f_t linearAcc = {0.0f, 0.0f, 0.0f};

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
  bus.write(0x6B);   // PWR_MGMT_1
  bus.write(0x00);   // Wake up MPU6050
  bus.endTransmission();
}

void readMPU(TwoWire &bus, uint8_t addr, IMURaw_t *raw) {
  bus.beginTransmission(addr);
  bus.write(0x3B);   // ACCEL_XOUT_H
  bus.endTransmission(false);
  bus.requestFrom(addr, (uint8_t)14);

  raw->ax_raw = (bus.read() << 8) | bus.read();
  raw->ay_raw = (bus.read() << 8) | bus.read();
  raw->az_raw = (bus.read() << 8) | bus.read();
  int16_t temp = (bus.read() << 8) | bus.read();
  raw->gx_raw = (bus.read() << 8) | bus.read();
  raw->gy_raw = (bus.read() << 8) | bus.read();
  raw->gz_raw = (bus.read() << 8) | bus.read();
}

// ============================================================
// Calibration
// ============================================================
void calibrateGyro(TwoWire &bus, uint8_t addr, GyroBias_t *bias) {
  const int samples = 200;

  long gx_sum = 0;
  long gy_sum = 0;
  long gz_sum = 0;

  Serial.println("Calibrating gyro... keep IMU still.");

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

  Serial.print("Gyro bias raw | ");
  Serial.print("Gx: "); Serial.print(bias->gx_bias_raw);
  Serial.print(" Gy: "); Serial.print(bias->gy_bias_raw);
  Serial.print(" Gz: "); Serial.println(bias->gz_bias_raw);
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
// Output (ONLY 6 DATA POINTS)
// ============================================================
void publishProcessedData(const IMUFiltered_t *filtered,
                          const Vec3f_t *linAccOut) {
  // linAcc
  Serial.print(linAccOut->x, 3); Serial.print(" ");
  Serial.print(linAccOut->y, 3); Serial.print(" ");
  Serial.print(linAccOut->z, 3); Serial.print(" ");

  // gyro
  Serial.print(filtered->gx_dps, 3); Serial.print(" ");
  Serial.print(filtered->gy_dps, 3); Serial.print(" ");
  Serial.print(filtered->gz_dps, 3);

  Serial.println();
}

// ============================================================
// SETUP
// ============================================================
void setup() {
  Serial.begin(115200);
  Wire.begin(PIN_SDA, PIN_SCL);
  initMPU(Wire, MPU_ADDR);

  delay(500);
  calibrateGyro(Wire, MPU_ADDR, &gyroBias);
}

// ============================================================
// LOOP
// ============================================================
void loop() {
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

    publishProcessedData(&imuFiltered, &linearAcc);
  }
}

// Old code for 5 IMUs
// #include <Wire.h>
// #include <SPI.h>
// #include "soc/soc.h"
// #include "soc/rtc_cntl_reg.h"

// // --- Pin Definitions ---
// #define CS_PIN        15 // SPI for IMU5
// #define I2C1_SDA_PIN  21
// #define I2C1_SCL_PIN  22
// #define I2C2_SDA_PIN  16
// #define I2C2_SCL_PIN  17
// #define SPI_SCK_PIN   18
// #define SPI_MISO_PIN  19
// #define SPI_MOSI_PIN  23

// // --- I2C Buses ---
// TwoWire I2C_1 = TwoWire(0);
// TwoWire I2C_2 = TwoWire(1);

// // --- MPU6500 I2C Address ---
// #define MPU_ADDR_LOW  0x68
// #define MPU_ADDR_HIGH 0x69

// // ---- I2C functions ----
// void initMPU(TwoWire &bus, uint8_t addr) {
//   bus.beginTransmission(addr);
//   bus.write(0x6B);
//   bus.write(0x00);
//   bus.endTransmission();
// }

// void readMPU(TwoWire &bus, uint8_t addr, int16_t *ax, int16_t *ay, int16_t *az,
//                                           int16_t *gx, int16_t *gy, int16_t *gz) {
//   bus.beginTransmission(addr);
//   bus.write(0x3B);
//   bus.endTransmission(false);
//   bus.requestFrom(addr, (uint8_t)14);

//   *ax = (bus.read() << 8) | bus.read();
//   *ay = (bus.read() << 8) | bus.read();
//   *az = (bus.read() << 8) | bus.read();
//   int16_t temp = (bus.read() << 8) | bus.read(); // skip temp
//   *gx = (bus.read() << 8) | bus.read();
//   *gy = (bus.read() << 8) | bus.read();
//   *gz = (bus.read() << 8) | bus.read();
// }

// // ---- SPI functions ----
// uint8_t spiRead(uint8_t reg) {
//   digitalWrite(CS_PIN, LOW);
//   SPI.transfer(reg | 0x80);
//   uint8_t val = SPI.transfer(0x00);
//   digitalWrite(CS_PIN, HIGH);
//   return val;
// }

// void spiWrite(uint8_t reg, uint8_t val) {
//   digitalWrite(CS_PIN, LOW);
//   SPI.transfer(reg & 0x7F);
//   SPI.transfer(val);
//   digitalWrite(CS_PIN, HIGH);
// }

// void initMPU_SPI() {
//   spiWrite(0x6B, 0x00);
// }

// void readMPU_SPI(int16_t *ax, int16_t *ay, int16_t *az,
//                  int16_t *gx, int16_t *gy, int16_t *gz) {
//   digitalWrite(CS_PIN, LOW);
//   SPI.transfer(0x3B | 0x80);
//   *ax = (SPI.transfer(0) << 8) | SPI.transfer(0);
//   *ay = (SPI.transfer(0) << 8) | SPI.transfer(0);
//   *az = (SPI.transfer(0) << 8) | SPI.transfer(0);
//   int16_t temp = (SPI.transfer(0) << 8) | SPI.transfer(0);
//   *gx = (SPI.transfer(0) << 8) | SPI.transfer(0);
//   *gy = (SPI.transfer(0) << 8) | SPI.transfer(0);
//   *gz = (SPI.transfer(0) << 8) | SPI.transfer(0);
//   digitalWrite(CS_PIN, HIGH);
// }

// // ============================================================
// // STUB: Replace body with real MQTT publish logic later
// // ============================================================
// void publishIMU(int16_t ax1, int16_t ay1, int16_t az1, int16_t gx1, int16_t gy1, int16_t gz1,
//                 int16_t ax2, int16_t ay2, int16_t az2, int16_t gx2, int16_t gy2, int16_t gz2,
//                 int16_t ax3, int16_t ay3, int16_t az3, int16_t gx3, int16_t gy3, int16_t gz3,
//                 int16_t ax4, int16_t ay4, int16_t az4, int16_t gx4, int16_t gy4, int16_t gz4,
//                 int16_t ax5, int16_t ay5, int16_t az5, int16_t gx5, int16_t gy5, int16_t gz5) {

//   Serial.print("IMU1 | ");
//   Serial.print("Ax:"); Serial.print(ax1);
//   Serial.print(" Ay:"); Serial.print(ay1);
//   Serial.print(" Az:"); Serial.print(az1);
//   Serial.print(" Gx:"); Serial.print(gx1);
//   Serial.print(" Gy:"); Serial.print(gy1);
//   Serial.print(" Gz:"); Serial.println(gz1);

//   Serial.print("IMU2 | ");
//   Serial.print("Ax:"); Serial.print(ax2);
//   Serial.print(" Ay:"); Serial.print(ay2);
//   Serial.print(" Az:"); Serial.print(az2);
//   Serial.print(" Gx:"); Serial.print(gx2);
//   Serial.print(" Gy:"); Serial.print(gy2);
//   Serial.print(" Gz:"); Serial.println(gz2);

//   Serial.print("IMU3 | ");
//   Serial.print("Ax:"); Serial.print(ax3);
//   Serial.print(" Ay:"); Serial.print(ay3);
//   Serial.print(" Az:"); Serial.print(az3);
//   Serial.print(" Gx:"); Serial.print(gx3);
//   Serial.print(" Gy:"); Serial.print(gy3);
//   Serial.print(" Gz:"); Serial.println(gz3);

//   Serial.print("IMU4 | ");
//   Serial.print("Ax:"); Serial.print(ax4);
//   Serial.print(" Ay:"); Serial.print(ay4);
//   Serial.print(" Az:"); Serial.print(az4);
//   Serial.print(" Gx:"); Serial.print(gx4);
//   Serial.print(" Gy:"); Serial.print(gy4);
//   Serial.print(" Gz:"); Serial.println(gz4);

//   Serial.print("IMU5 | ");
//   Serial.print("Ax:"); Serial.print(ax5);
//   Serial.print(" Ay:"); Serial.print(ay5);
//   Serial.print(" Az:"); Serial.print(az5);
//   Serial.print(" Gx:"); Serial.print(gx5);
//   Serial.print(" Gy:"); Serial.print(gy5);
//   Serial.print(" Gz:"); Serial.println(gz5);

//   Serial.println("------");
// }

// // ============================================================
// // SETUP
// // ============================================================
// void setup() {
//   WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
//   Serial.begin(115200);
//   delay(2000);

//   I2C_1.begin(I2C1_SDA_PIN, I2C1_SCL_PIN, 400000);
//   delay(200);
//   I2C_2.begin(I2C2_SDA_PIN, I2C2_SCL_PIN, 400000);
//   delay(200);

//   pinMode(CS_PIN, OUTPUT);
//   digitalWrite(CS_PIN, HIGH);
//   SPI.begin(SPI_SCK_PIN, SPI_MISO_PIN, SPI_MOSI_PIN, CS_PIN);
//   SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));

//   initMPU(I2C_1, MPU_ADDR_LOW);
//   initMPU(I2C_1, MPU_ADDR_HIGH);
//   initMPU(I2C_2, MPU_ADDR_LOW);
//   initMPU(I2C_2, MPU_ADDR_HIGH);
//   initMPU_SPI();
// }

// // ============================================================
// // LOOP
// // ============================================================
// void loop() {
//   int16_t ax1, ay1, az1, gx1, gy1, gz1;
//   int16_t ax2, ay2, az2, gx2, gy2, gz2;
//   int16_t ax3, ay3, az3, gx3, gy3, gz3;
//   int16_t ax4, ay4, az4, gx4, gy4, gz4;
//   int16_t ax5, ay5, az5, gx5, gy5, gz5;

//   readMPU(I2C_1, MPU_ADDR_LOW,  &ax1, &ay1, &az1, &gx1, &gy1, &gz1);
//   readMPU(I2C_1, MPU_ADDR_HIGH, &ax2, &ay2, &az2, &gx2, &gy2, &gz2);
//   readMPU(I2C_2, MPU_ADDR_LOW,  &ax3, &ay3, &az3, &gx3, &gy3, &gz3);
//   readMPU(I2C_2, MPU_ADDR_HIGH, &ax4, &ay4, &az4, &gx4, &gy4, &gz4);
//   readMPU_SPI(&ax5, &ay5, &az5, &gx5, &gy5, &gz5);

//   publishIMU(ax1, ay1, az1, gx1, gy1, gz1,
//              ax2, ay2, az2, gx2, gy2, gz2,
//              ax3, ay3, az3, gx3, gy3, gz3,
//              ax4, ay4, az4, gx4, gy4, gz4,
//              ax5, ay5, az5, gx5, gy5, gz5);

//   delay(20);
// }

