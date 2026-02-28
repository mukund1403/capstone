#include <Wire.h>
#include <SPI.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

// I2C buses
TwoWire I2C_1 = TwoWire(0);
TwoWire I2C_2 = TwoWire(1);

#define MPU_ADDR_LOW  0x68
#define MPU_ADDR_HIGH 0x69

// SPI for IMU5
#define CS_PIN 15

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
  SPI.transfer(reg | 0x80); // MSB=1 for read
  uint8_t val = SPI.transfer(0x00);
  digitalWrite(CS_PIN, HIGH);
  return val;
}

void spiWrite(uint8_t reg, uint8_t val) {
  digitalWrite(CS_PIN, LOW);
  SPI.transfer(reg & 0x7F); // MSB=0 for write
  SPI.transfer(val);
  digitalWrite(CS_PIN, HIGH);
}

void initMPU_SPI() {
  spiWrite(0x6B, 0x00); // wake up
}

void readMPU_SPI(int16_t *ax, int16_t *ay, int16_t *az,
                 int16_t *gx, int16_t *gy, int16_t *gz) {
  digitalWrite(CS_PIN, LOW);
  SPI.transfer(0x3B | 0x80); // ACCEL_XOUT_H, read mode
  *ax = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *ay = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *az = (SPI.transfer(0) << 8) | SPI.transfer(0);
  int16_t temp = (SPI.transfer(0) << 8) | SPI.transfer(0); // skip temp
  *gx = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *gy = (SPI.transfer(0) << 8) | SPI.transfer(0);
  *gz = (SPI.transfer(0) << 8) | SPI.transfer(0);
  digitalWrite(CS_PIN, HIGH);
}

void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
  Serial.begin(115200);
  delay(2000);

  // Init I2C buses
  I2C_1.begin(21, 22, 400000);
  delay(200);
  I2C_2.begin(16, 17, 400000);
  delay(200);

  // Init SPI
  pinMode(CS_PIN, OUTPUT);
  digitalWrite(CS_PIN, HIGH);
  SPI.begin(18, 19, 23, CS_PIN); // SCK, MISO, MOSI, CS
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));

  // Init all 5 IMUs
  initMPU(I2C_1, MPU_ADDR_LOW);
  initMPU(I2C_1, MPU_ADDR_HIGH);
  initMPU(I2C_2, MPU_ADDR_LOW);
  initMPU(I2C_2, MPU_ADDR_HIGH);
  initMPU_SPI();

  Serial.println("All IMUs initialized");
}

void loop() {
  int16_t ax, ay, az, gx, gy, gz;

  // IMU 1-4 via I2C
  for (int imu = 0; imu < 4; imu++) {
    TwoWire *bus;
    uint8_t addr;

    if      (imu == 0) { bus = &I2C_1; addr = MPU_ADDR_LOW; }
    else if (imu == 1) { bus = &I2C_1; addr = MPU_ADDR_HIGH; }
    else if (imu == 2) { bus = &I2C_2; addr = MPU_ADDR_LOW; }
    else               { bus = &I2C_2; addr = MPU_ADDR_HIGH; }

    readMPU(*bus, addr, &ax, &ay, &az, &gx, &gy, &gz);

    Serial.print("IMU"); Serial.print(imu + 1); Serial.print(" | ");
    Serial.print("Ax:"); Serial.print(ax);
    Serial.print(" Ay:"); Serial.print(ay);
    Serial.print(" Az:"); Serial.print(az);
    Serial.print(" Gx:"); Serial.print(gx);
    Serial.print(" Gy:"); Serial.print(gy);
    Serial.print(" Gz:"); Serial.println(gz);
  }

  // IMU5 via SPI
  readMPU_SPI(&ax, &ay, &az, &gx, &gy, &gz);
  Serial.print("IMU5 | ");
  Serial.print("Ax:"); Serial.print(ax);
  Serial.print(" Ay:"); Serial.print(ay);
  Serial.print(" Az:"); Serial.print(az);
  Serial.print(" Gx:"); Serial.print(gx);
  Serial.print(" Gy:"); Serial.print(gy);
  Serial.print(" Gz:"); Serial.println(gz);

  Serial.println("------");
  delay(20);
}