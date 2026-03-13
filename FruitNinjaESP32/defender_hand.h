#include <Wire.h>
#include <SPI.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

// --- Pin Definitions ---
#define CS_PIN 15  // SPI for IMU5
#define I2C1_SDA_PIN 21
#define I2C1_SCL_PIN 22
#define I2C2_SDA_PIN 16
#define I2C2_SCL_PIN 17
#define SPI_SCK_PIN 18
#define SPI_MISO_PIN 19
#define SPI_MOSI_PIN 23

unsigned long lastReadTime = 0;

typedef void (*PublishFn)(int16_t, int16_t, int16_t, int16_t, int16_t, int16_t);
typedef void (*PublishPauseFn)(int);

// --- I2C Buses ---
TwoWire I2C_1 = TwoWire(0);
TwoWire I2C_2 = TwoWire(1);

// --- MPU6500 I2C Address ---
#define MPU_ADDR_LOW 0x68
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
  int16_t temp = (bus.read() << 8) | bus.read();  // skip temp
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
// SETUP
// ============================================================
void hardwareSetup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
  // Serial.begin(115200);
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
void hardwareLoop(PublishFn publishFn, PublishPauseFn pauseFn) {

  unsigned long now = millis();

  if (now - lastReadTime >= READ_INTERVAL_MS) {
    int16_t ax1, ay1, az1, gx1, gy1, gz1;
    int16_t ax2, ay2, az2, gx2, gy2, gz2;
    int16_t ax3, ay3, az3, gx3, gy3, gz3;
    int16_t ax4, ay4, az4, gx4, gy4, gz4;
    int16_t ax5, ay5, az5, gx5, gy5, gz5;


    lastReadTime = now;
    readMPU(I2C_1, MPU_ADDR_LOW, &ax1, &ay1, &az1, &gx1, &gy1, &gz1);
    readMPU(I2C_1, MPU_ADDR_HIGH, &ax2, &ay2, &az2, &gx2, &gy2, &gz2);
    readMPU(I2C_2, MPU_ADDR_LOW, &ax3, &ay3, &az3, &gx3, &gy3, &gz3);
    readMPU(I2C_2, MPU_ADDR_HIGH, &ax4, &ay4, &az4, &gx4, &gy4, &gz4);
    readMPU_SPI(&ax5, &ay5, &az5, &gx5, &gy5, &gz5);
    publishFn(ax1, ay1, az1, gx1, gy1, gz1);
  }
}