#include <Wire.h>
#include <SPI.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

// --- Pin Definitions ---
#define CS_PIN        15 // SPI for IMU5
#define I2C1_SDA_PIN  21
#define I2C1_SCL_PIN  22
#define I2C2_SDA_PIN  16
#define I2C2_SCL_PIN  17
#define SPI_SCK_PIN   18
#define SPI_MISO_PIN  19
#define SPI_MOSI_PIN  23

// --- I2C Buses ---
TwoWire I2C_1 = TwoWire(0);
TwoWire I2C_2 = TwoWire(1);

// --- MPU6500 I2C Address ---
#define MPU_ADDR_LOW  0x68
#define MPU_ADDR_HIGH 0x69

// ---- I2C functions ----
void initMPU(TwoWire &bus, uint8_t addr) {
  bus.beginTransmission(addr);
  bus.write(0x6B);
  bus.write(0x00);
  bus.endTransmission();
}

void readMPU(TwoWire &bus, uint8_t addr, int16_t *ax, int16_t *ay, int16_t *az,
                                          int16_t *gx, int16_t *gy, int16_t *gz) {
  bus.beginTransmission(addr);
  bus.write(0x3B);
  bus.endTransmission(false);
  bus.requestFrom(addr, (uint8_t)14);

  *ax = (bus.read() << 8) | bus.read();
  *ay = (bus.read() << 8) | bus.read();
  *az = (bus.read() << 8) | bus.read();
  int16_t temp = (bus.read() << 8) | bus.read(); // skip temp
  *gx = (bus.read() << 8) | bus.read();
  *gy = (bus.read() << 8) | bus.read();
  *gz = (bus.read() << 8) | bus.read();
}

// ---- SPI functions ----
uint8_t spiRead(uint8_t reg) {
  digitalWrite(CS_PIN, LOW);
  SPI.transfer(reg | 0x80);
  uint8_t val = SPI.transfer(0x00);
  digitalWrite(CS_PIN, HIGH);
  return val;
}

void spiWrite(uint8_t reg, uint8_t val) {
  digitalWrite(CS_PIN, LOW);
  SPI.transfer(reg & 0x7F);
  SPI.transfer(val);
  digitalWrite(CS_PIN, HIGH);
}

void initMPU_SPI() {
  spiWrite(0x6B, 0x00);
}

void readMPU_SPI(int16_t *ax, int16_t *ay, int16_t *az,
                 int16_t *gx, int16_t *gy, int16_t *gz) {
  digitalWrite(CS_PIN, LOW);
  SPI.transfer(0x3B | 0x80);
  *ax = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *ay = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *az = (SPI.transfer(0) << 8) | SPI.transfer(0);
  int16_t temp = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *gx = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *gy = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *gz = (SPI.transfer(0) << 8) | SPI.transfer(0);
  digitalWrite(CS_PIN, HIGH);
}

// ============================================================
// STUB: Replace body with real MQTT publish logic later
// ============================================================
void publishIMU(int16_t ax1, int16_t ay1, int16_t az1, int16_t gx1, int16_t gy1, int16_t gz1,
                int16_t ax2, int16_t ay2, int16_t az2, int16_t gx2, int16_t gy2, int16_t gz2,
                int16_t ax3, int16_t ay3, int16_t az3, int16_t gx3, int16_t gy3, int16_t gz3,
                int16_t ax4, int16_t ay4, int16_t az4, int16_t gx4, int16_t gy4, int16_t gz4,
                int16_t ax5, int16_t ay5, int16_t az5, int16_t gx5, int16_t gy5, int16_t gz5) {

  Serial.print("IMU1 | ");
  Serial.print("Ax:"); Serial.print(ax1);
  Serial.print(" Ay:"); Serial.print(ay1);
  Serial.print(" Az:"); Serial.print(az1);
  Serial.print(" Gx:"); Serial.print(gx1);
  Serial.print(" Gy:"); Serial.print(gy1);
  Serial.print(" Gz:"); Serial.println(gz1);

  Serial.print("IMU2 | ");
  Serial.print("Ax:"); Serial.print(ax2);
  Serial.print(" Ay:"); Serial.print(ay2);
  Serial.print(" Az:"); Serial.print(az2);
  Serial.print(" Gx:"); Serial.print(gx2);
  Serial.print(" Gy:"); Serial.print(gy2);
  Serial.print(" Gz:"); Serial.println(gz2);

  Serial.print("IMU3 | ");
  Serial.print("Ax:"); Serial.print(ax3);
  Serial.print(" Ay:"); Serial.print(ay3);
  Serial.print(" Az:"); Serial.print(az3);
  Serial.print(" Gx:"); Serial.print(gx3);
  Serial.print(" Gy:"); Serial.print(gy3);
  Serial.print(" Gz:"); Serial.println(gz3);

  Serial.print("IMU4 | ");
  Serial.print("Ax:"); Serial.print(ax4);
  Serial.print(" Ay:"); Serial.print(ay4);
  Serial.print(" Az:"); Serial.print(az4);
  Serial.print(" Gx:"); Serial.print(gx4);
  Serial.print(" Gy:"); Serial.print(gy4);
  Serial.print(" Gz:"); Serial.println(gz4);

  Serial.print("IMU5 | ");
  Serial.print("Ax:"); Serial.print(ax5);
  Serial.print(" Ay:"); Serial.print(ay5);
  Serial.print(" Az:"); Serial.print(az5);
  Serial.print(" Gx:"); Serial.print(gx5);
  Serial.print(" Gy:"); Serial.print(gy5);
  Serial.print(" Gz:"); Serial.println(gz5);

  Serial.println("------");
}

// ============================================================
// SETUP
// ============================================================
void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
  Serial.begin(115200);
  delay(2000);

  I2C_1.begin(I2C1_SDA_PIN, I2C1_SCL_PIN, 400000);
  delay(200);
  I2C_2.begin(I2C2_SDA_PIN, I2C2_SCL_PIN, 400000);
  delay(200);

  pinMode(CS_PIN, OUTPUT);
  digitalWrite(CS_PIN, HIGH);
  SPI.begin(SPI_SCK_PIN, SPI_MISO_PIN, SPI_MOSI_PIN, CS_PIN);
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));

  initMPU(I2C_1, MPU_ADDR_LOW);
  initMPU(I2C_1, MPU_ADDR_HIGH);
  initMPU(I2C_2, MPU_ADDR_LOW);
  initMPU(I2C_2, MPU_ADDR_HIGH);
  initMPU_SPI();
}

// ============================================================
// LOOP
// ============================================================
void loop() {
  int16_t ax1, ay1, az1, gx1, gy1, gz1;
  int16_t ax2, ay2, az2, gx2, gy2, gz2;
  int16_t ax3, ay3, az3, gx3, gy3, gz3;
  int16_t ax4, ay4, az4, gx4, gy4, gz4;
  int16_t ax5, ay5, az5, gx5, gy5, gz5;

  readMPU(I2C_1, MPU_ADDR_LOW,  &ax1, &ay1, &az1, &gx1, &gy1, &gz1);
  readMPU(I2C_1, MPU_ADDR_HIGH, &ax2, &ay2, &az2, &gx2, &gy2, &gz2);
  readMPU(I2C_2, MPU_ADDR_LOW,  &ax3, &ay3, &az3, &gx3, &gy3, &gz3);
  readMPU(I2C_2, MPU_ADDR_HIGH, &ax4, &ay4, &az4, &gx4, &gy4, &gz4);
  readMPU_SPI(&ax5, &ay5, &az5, &gx5, &gy5, &gz5);

  publishIMU(ax1, ay1, az1, gx1, gy1, gz1,
             ax2, ay2, az2, gx2, gy2, gz2,
             ax3, ay3, az3, gx3, gy3, gz3,
             ax4, ay4, az4, gx4, gy4, gz4,
             ax5, ay5, az5, gx5, gy5, gz5);

  delay(20);
}