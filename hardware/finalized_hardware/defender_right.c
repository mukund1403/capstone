#include <Wire.h>

// --- Pin Definitions ---
#define PIN_SDA         21
#define PIN_SCL         22
#define PIN_VIBRO       25
#define PIN_BUZZER      26
#define PIN_LED_R       15
#define PIN_LED_G       27 
#define PIN_BTN_PAUSE   13

// --- MPU6050 I2C Address ---
#define MPU_ADDR        0x68

// --- Timing ---
#define READ_INTERVAL_MS  20   // 50 Hz

// --- MPU6050 default sensitivities ---
#define ACC_LSB_PER_G     16384.0f
#define GYRO_LSB_PER_DPS  131.0f

// --- Filter coefficients ---
#define ACC_ALPHA         0.85f
#define GYRO_ALPHA        0.85f
#define GRAV_ALPHA        0.98f

// --- Vibration Motor (LEDC PWM) ---
#define VIBRO_FREQ      5000
#define VIBRO_RES       8

// --- Buzzer (LEDC PWM) ---
#define BUZZER_RES      8

enum VibroState  { VIBRO_IDLE,  VIBRO_SUCCESS,  VIBRO_FAIL  };
enum BuzzerState { BUZZER_IDLE, BUZZER_SUCCESS, BUZZER_FAIL };
enum LedState    { LED_IDLE,    LED_SUCCESS,    LED_FAIL    };

VibroState  vibroState  = VIBRO_IDLE;
BuzzerState buzzerState = BUZZER_IDLE;
LedState    ledState    = LED_IDLE;

int  vibroStep  = 0;  unsigned long vibroLastMs  = 0;
int  buzzerStep = 0;  unsigned long buzzerLastMs = 0;
int  ledStep    = 0;  unsigned long ledLastMs    = 0;

unsigned long lastReadTime = 0;

volatile bool paused = false;
volatile bool btnIsrReq = false;
volatile unsigned long btnLastIsrUs = 0;

bool btnArmed = true;

// ============================================================
// MPU Structs
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
// MPU Globals
// ============================================================
GyroBias_t gyroBias = {0.0f, 0.0f, 0.0f};
IMUFiltered_t imuFiltered = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
GravityEstimate_t gravityEst = {0.0f, 0.0f, 1.0f};
Vec3f_t linearAcc = {0.0f, 0.0f, 0.0f};

// ============================================================
// Interrupt / Serial helpers
// ============================================================
void IRAM_ATTR onPauseButton() {
  unsigned long nowUs = micros();
  if (nowUs - btnLastIsrUs < 20000) return;   // 20 ms ISR filter
  btnLastIsrUs = nowUs;
  btnIsrReq = true;
}

void drainSubscription() {
  while (Serial.available()) { (void)Serial.read(); }
}

// ============================================================
// MPU Utility
// ============================================================
float lowPass(float prev, float curr, float alpha) {
  return alpha * prev + (1.0f - alpha) * curr;
}

// ============================================================
// MPU I2C Functions
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
  (void)temp;
  raw->gx_raw = (bus.read() << 8) | bus.read();
  raw->gy_raw = (bus.read() << 8) | bus.read();
  raw->gz_raw = (bus.read() << 8) | bus.read();
}

// ============================================================
// MPU Calibration
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

}

// ============================================================
// MPU Processing
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
// Vibration Patterns
// ============================================================
void updateVibro() {
  if (vibroState == VIBRO_IDLE) return;

  unsigned long now = millis();

  if (vibroState == VIBRO_SUCCESS) {
    const uint8_t  pwr[] = {255,   0};
    const uint16_t dur[] = {600,   0};
    if (now - vibroLastMs >= dur[vibroStep]) {
      ledcWrite(PIN_VIBRO, pwr[vibroStep]);
      vibroLastMs = now;
      vibroStep++;
      if (vibroStep >= 2) {
        ledcWrite(PIN_VIBRO, 0);
        vibroState = VIBRO_IDLE;
        vibroStep = 0;
      }
    }
  } else if (vibroState == VIBRO_FAIL) {
    switch (vibroStep) {
      case 0: ledcWrite(PIN_VIBRO, 255); vibroStep++; vibroLastMs = now; break;
      case 1: if (now - vibroLastMs >= 300) { ledcWrite(PIN_VIBRO, 0);   vibroStep++; vibroLastMs = now; } break;
      case 2: if (now - vibroLastMs >= 150) { ledcWrite(PIN_VIBRO, 255); vibroStep++; vibroLastMs = now; } break;
      case 3: if (now - vibroLastMs >= 300) { ledcWrite(PIN_VIBRO, 0);   vibroStep++; vibroLastMs = now; } break;
      case 4: if (now - vibroLastMs >= 150) { ledcWrite(PIN_VIBRO, 255); vibroStep++; vibroLastMs = now; } break;
      case 5: if (now - vibroLastMs >= 300) { ledcWrite(PIN_VIBRO, 0);   vibroState = VIBRO_IDLE; vibroStep = 0; } break;
    }
  }
}

void triggerVibro(int result) {
  vibroStep   = 0;
  vibroLastMs = millis();
  vibroState  = (result == 1) ? VIBRO_SUCCESS : VIBRO_FAIL;
  ledcWrite(PIN_VIBRO, 255);
}

// ============================================================
// Buzzer Patterns
// ============================================================
void updateBuzzer() {
  if (buzzerState == BUZZER_IDLE) return;

  unsigned long now = millis();

  if (buzzerState == BUZZER_SUCCESS) {
    switch (buzzerStep) {
      case 0: ledcWriteTone(PIN_BUZZER, 523); ledcWrite(PIN_BUZZER, 128); buzzerStep++; buzzerLastMs = now; break;
      case 1: if (now - buzzerLastMs >= 150) { ledcWriteTone(PIN_BUZZER, 659); ledcWrite(PIN_BUZZER, 128); buzzerStep++; buzzerLastMs = now; } break;
      case 2: if (now - buzzerLastMs >= 150) { ledcWriteTone(PIN_BUZZER, 784); ledcWrite(PIN_BUZZER, 128); buzzerStep++; buzzerLastMs = now; } break;
      case 3: if (now - buzzerLastMs >= 150) { ledcWriteTone(PIN_BUZZER, 0); ledcWrite(PIN_BUZZER, 0); buzzerState = BUZZER_IDLE; buzzerStep = 0; } break;
    }
  } else if (buzzerState == BUZZER_FAIL) {
    switch (buzzerStep) {
      case 0: ledcWriteTone(PIN_BUZZER, 392); ledcWrite(PIN_BUZZER, 128); buzzerStep++; buzzerLastMs = now; break;
      case 1: if (now - buzzerLastMs >= 300) { ledcWriteTone(PIN_BUZZER, 0); ledcWrite(PIN_BUZZER, 0); buzzerStep++; buzzerLastMs = now; } break;
      case 2: if (now - buzzerLastMs >= 150) { ledcWriteTone(PIN_BUZZER, 330); ledcWrite(PIN_BUZZER, 128); buzzerStep++; buzzerLastMs = now; } break;
      case 3: if (now - buzzerLastMs >= 300) { ledcWriteTone(PIN_BUZZER, 0); ledcWrite(PIN_BUZZER, 0); buzzerStep++; buzzerLastMs = now; } break;
      case 4: if (now - buzzerLastMs >= 150) { ledcWriteTone(PIN_BUZZER, 262); ledcWrite(PIN_BUZZER, 128); buzzerStep++; buzzerLastMs = now; } break;
      case 5: if (now - buzzerLastMs >= 300) { ledcWriteTone(PIN_BUZZER, 0); ledcWrite(PIN_BUZZER, 0); buzzerState = BUZZER_IDLE; buzzerStep = 0; } break;
    }
  }
}

void triggerBuzzer(int result) {
  buzzerStep   = 0;
  buzzerLastMs = millis();
  buzzerState  = (result == 1) ? BUZZER_SUCCESS : BUZZER_FAIL;
}

// ============================================================
// LED Patterns
// ============================================================
void updateLed() {
  if (ledState == LED_IDLE) return;

  unsigned long now = millis();

  if (ledState == LED_SUCCESS) {
    switch (ledStep) {
      case 0: digitalWrite(PIN_LED_G, HIGH); ledStep++; ledLastMs = now; break;
      case 1: if (now - ledLastMs >= 600) { digitalWrite(PIN_LED_G, LOW); ledState = LED_IDLE; ledStep = 0; } break;
    }
  } else if (ledState == LED_FAIL) {
    switch (ledStep) {
      case 0: digitalWrite(PIN_LED_R, HIGH); ledStep++; ledLastMs = now; break;
      case 1: if (now - ledLastMs >= 300) { digitalWrite(PIN_LED_R, LOW);  ledStep++; ledLastMs = now; } break;
      case 2: if (now - ledLastMs >= 150) { digitalWrite(PIN_LED_R, HIGH); ledStep++; ledLastMs = now; } break;
      case 3: if (now - ledLastMs >= 300) { digitalWrite(PIN_LED_R, LOW);  ledStep++; ledLastMs = now; } break;
      case 4: if (now - ledLastMs >= 150) { digitalWrite(PIN_LED_R, HIGH); ledStep++; ledLastMs = now; } break;
      case 5: if (now - ledLastMs >= 300) { digitalWrite(PIN_LED_R, LOW);  ledState = LED_IDLE; ledStep = 0; } break;
    }
  }
}

void triggerLed(int result) {
  ledStep   = 0;
  ledLastMs = millis();
  ledState  = (result == 1) ? LED_SUCCESS : LED_FAIL;
  digitalWrite((result == 1) ? PIN_LED_G : PIN_LED_R, HIGH);
}

// ============================================================
// Publishing / Subscription
// ============================================================
void publishData(const IMUFiltered_t *filtered, const Vec3f_t *linAccOut) {
  // linAcc x y z
  Serial.print(linAccOut->x, 3); Serial.print(" ");
  Serial.print(linAccOut->y, 3); Serial.print(" ");
  Serial.print(linAccOut->z, 3); Serial.print(" ");

  // gyro x y z
  Serial.print(filtered->gx_dps, 3); Serial.print(" ");
  Serial.print(filtered->gy_dps, 3); Serial.print(" ");
  Serial.print(filtered->gz_dps, 3);

  Serial.println();
}

void publishPauseState(int paused_now) {
  Serial.print("[PAUSE_STATE] ");
  Serial.println(paused_now ? 1 : 0);
}

void checkSubscription() {
  if (Serial.available()) {
    char c = Serial.read();
    if (c == '1') {
      Serial.println("[RESULT] SUCCESS");
      triggerVibro(1);
      triggerBuzzer(1);
      triggerLed(1);
    } else if (c == '0') {
      Serial.println("[RESULT] FAIL");
      triggerVibro(0);
      triggerBuzzer(0);
      triggerLed(0);
    }
  }
}

// ============================================================
// SETUP
// ============================================================
void setup() {
  Serial.begin(115200);

  Wire.begin(PIN_SDA, PIN_SCL);
  initMPU(Wire, MPU_ADDR);

  ledcAttach(PIN_VIBRO,  VIBRO_FREQ, VIBRO_RES);
  ledcAttach(PIN_BUZZER, 2000,       BUZZER_RES);
  ledcWrite(PIN_VIBRO,  0);
  ledcWriteTone(PIN_BUZZER, 0);

  pinMode(PIN_LED_R, OUTPUT); digitalWrite(PIN_LED_R, LOW);
  pinMode(PIN_LED_G, OUTPUT); digitalWrite(PIN_LED_G, LOW);

  pinMode(PIN_BTN_PAUSE, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(PIN_BTN_PAUSE), onPauseButton, CHANGE);

  delay(500);
  calibrateGyro(Wire, MPU_ADDR, &gyroBias);
}

// ============================================================
// LOOP
// ============================================================
void loop() {
  unsigned long now = millis();

  if (btnIsrReq) {
    noInterrupts();
    btnIsrReq = false;
    interrupts();

    int level = digitalRead(PIN_BTN_PAUSE);

    if (level == LOW && btnArmed) {
      paused = !paused;
      btnArmed = false;
      publishPauseState(paused ? 1 : 0);
    } else if (level == HIGH) {
      btnArmed = true;
    }
  }

  if (!paused) {
    checkSubscription();
  } else {
    drainSubscription();
  }

  updateVibro();
  updateBuzzer();
  updateLed();

  if (!paused && (now - lastReadTime >= READ_INTERVAL_MS)) {
    lastReadTime = now;

    IMURaw_t raw;
    IMUScaled_t scaled;

    readMPU(Wire, MPU_ADDR, &raw);
    scaleIMU(&raw, &gyroBias, &scaled);
    filterIMU(&scaled, &imuFiltered);
    updateGravityEstimate(&imuFiltered, &gravityEst);
    computeLinearAcceleration(&imuFiltered, &gravityEst, &linearAcc);

    publishData(&imuFiltered, &linearAcc);
  }
}