#include <Wire.h>

// -- TO DO --
// Add paused state to ESP

// --- Pin Definitions ---
#define PIN_SDA 21
#define PIN_SCL 22
#define PIN_VIBRO 25
#define PIN_BUZZER 26
#define PIN_LED_R 27
#define PIN_LED_G 9
#define PIN_BTN_PAUSE 10

// --- MPU6050 I2C Address ---
#define MPU_ADDR 0x68

// --- Timing ---
#define READ_INTERVAL_MS 20

// --- Vibration Motor (LEDC PWM) ---
#define VIBRO_FREQ 5000
#define VIBRO_RES 8

// --- Buzzer (LEDC PWM) ---
#define BUZZER_RES 8

typedef void (*PublishFn)(int16_t, int16_t, int16_t, int16_t, int16_t, int16_t);
typedef void (*PublishPauseFn)(int);

enum VibroState { VIBRO_IDLE,
                  VIBRO_SUCCESS,
                  VIBRO_FAIL };
enum BuzzerState { BUZZER_IDLE,
                   BUZZER_SUCCESS,
                   BUZZER_FAIL };
enum LedState { LED_IDLE,
                LED_SUCCESS,
                LED_FAIL };

VibroState vibroState = VIBRO_IDLE;
BuzzerState buzzerState = BUZZER_IDLE;
LedState ledState = LED_IDLE;

int vibroStep = 0;
unsigned long vibroLastMs = 0;
int buzzerStep = 0;
unsigned long buzzerLastMs = 0;
int ledStep = 0;
unsigned long ledLastMs = 0;

unsigned long lastReadTime = 0;

volatile bool paused = false;
volatile bool btnIsrReq = false;
volatile unsigned long btnLastIsrUs = 0;

bool btnArmed = true;

void IRAM_ATTR onPauseButton() {
  unsigned long nowUs = micros();
  if (nowUs - btnLastIsrUs < 20000) return;  // 20ms ISR filter
  btnLastIsrUs = nowUs;
  btnIsrReq = true;
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
// Vibration Patterns
// ============================================================
void updateVibro() {
  if (vibroState == VIBRO_IDLE) return;

  unsigned long now = millis();

  if (vibroState == VIBRO_SUCCESS) {
    const uint8_t pwr[] = { 255, 0 };
    const uint16_t dur[] = { 600, 0 };
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
  }

  else if (vibroState == VIBRO_FAIL) {
    switch (vibroStep) {
      case 0:
        ledcWrite(PIN_VIBRO, 255);
        vibroStep++;
        vibroLastMs = now;
        break;
      case 1:
        if (now - vibroLastMs >= 300) {
          ledcWrite(PIN_VIBRO, 0);
          vibroStep++;
          vibroLastMs = now;
        }
        break;
      case 2:
        if (now - vibroLastMs >= 150) {
          ledcWrite(PIN_VIBRO, 255);
          vibroStep++;
          vibroLastMs = now;
        }
        break;
      case 3:
        if (now - vibroLastMs >= 300) {
          ledcWrite(PIN_VIBRO, 0);
          vibroStep++;
          vibroLastMs = now;
        }
        break;
      case 4:
        if (now - vibroLastMs >= 150) {
          ledcWrite(PIN_VIBRO, 255);
          vibroStep++;
          vibroLastMs = now;
        }
        break;
      case 5:
        if (now - vibroLastMs >= 300) {
          ledcWrite(PIN_VIBRO, 0);
          vibroState = VIBRO_IDLE;
          vibroStep = 0;
        }
        break;
    }
  }
}

void triggerVibro(int result) {
  vibroStep = 0;
  vibroLastMs = millis();
  vibroState = (result == 1) ? VIBRO_SUCCESS : VIBRO_FAIL;
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
      case 0:
        ledcWriteTone(PIN_BUZZER, 523);
        ledcWrite(PIN_BUZZER, 128);
        buzzerStep++;
        buzzerLastMs = now;
        break;
      case 1:
        if (now - buzzerLastMs >= 150) {
          ledcWriteTone(PIN_BUZZER, 659);
          ledcWrite(PIN_BUZZER, 128);
          buzzerStep++;
          buzzerLastMs = now;
        }
        break;
      case 2:
        if (now - buzzerLastMs >= 150) {
          ledcWriteTone(PIN_BUZZER, 784);
          ledcWrite(PIN_BUZZER, 128);
          buzzerStep++;
          buzzerLastMs = now;
        }
        break;
      case 3:
        if (now - buzzerLastMs >= 150) {
          ledcWriteTone(PIN_BUZZER, 0);
          ledcWrite(PIN_BUZZER, 0);
          buzzerState = BUZZER_IDLE;
          buzzerStep = 0;
        }
        break;
    }
  }

  else if (buzzerState == BUZZER_FAIL) {
    switch (buzzerStep) {
      case 0:
        ledcWriteTone(PIN_BUZZER, 392);
        ledcWrite(PIN_BUZZER, 128);
        buzzerStep++;
        buzzerLastMs = now;
        break;
      case 1:
        if (now - buzzerLastMs >= 300) {
          ledcWriteTone(PIN_BUZZER, 0);
          ledcWrite(PIN_BUZZER, 0);
          buzzerStep++;
          buzzerLastMs = now;
        }
        break;
      case 2:
        if (now - buzzerLastMs >= 150) {
          ledcWriteTone(PIN_BUZZER, 330);
          ledcWrite(PIN_BUZZER, 128);
          buzzerStep++;
          buzzerLastMs = now;
        }
        break;
      case 3:
        if (now - buzzerLastMs >= 300) {
          ledcWriteTone(PIN_BUZZER, 0);
          ledcWrite(PIN_BUZZER, 0);
          buzzerStep++;
          buzzerLastMs = now;
        }
        break;
      case 4:
        if (now - buzzerLastMs >= 150) {
          ledcWriteTone(PIN_BUZZER, 262);
          ledcWrite(PIN_BUZZER, 128);
          buzzerStep++;
          buzzerLastMs = now;
        }
        break;
      case 5:
        if (now - buzzerLastMs >= 300) {
          ledcWriteTone(PIN_BUZZER, 0);
          ledcWrite(PIN_BUZZER, 0);
          buzzerState = BUZZER_IDLE;
          buzzerStep = 0;
        }
        break;
    }
  }
}

void triggerBuzzer(int result) {
  buzzerStep = 0;
  buzzerLastMs = millis();
  buzzerState = (result == 1) ? BUZZER_SUCCESS : BUZZER_FAIL;
}

// ============================================================
// LED Patterns (common cathode: HIGH = on, LOW = off)
// SUCCESS: green on for 600ms
// FAIL:    red blinks x3 matching vibro fail rhythm
// ============================================================
void updateLed() {
  if (ledState == LED_IDLE) return;

  unsigned long now = millis();

  if (ledState == LED_SUCCESS) {
    switch (ledStep) {
      case 0:
        digitalWrite(PIN_LED_G, HIGH);
        ledStep++;
        ledLastMs = now;
        break;
      case 1:
        if (now - ledLastMs >= 600) {
          digitalWrite(PIN_LED_G, LOW);
          ledState = LED_IDLE;
          ledStep = 0;
        }
        break;
    }
  }

  else if (ledState == LED_FAIL) {
    switch (ledStep) {
      case 0:
        digitalWrite(PIN_LED_R, HIGH);
        ledStep++;
        ledLastMs = now;
        break;
      case 1:
        if (now - ledLastMs >= 300) {
          digitalWrite(PIN_LED_R, LOW);
          ledStep++;
          ledLastMs = now;
        }
        break;
      case 2:
        if (now - ledLastMs >= 150) {
          digitalWrite(PIN_LED_R, HIGH);
          ledStep++;
          ledLastMs = now;
        }
        break;
      case 3:
        if (now - ledLastMs >= 300) {
          digitalWrite(PIN_LED_R, LOW);
          ledStep++;
          ledLastMs = now;
        }
        break;
      case 4:
        if (now - ledLastMs >= 150) {
          digitalWrite(PIN_LED_R, HIGH);
          ledStep++;
          ledLastMs = now;
        }
        break;
      case 5:
        if (now - ledLastMs >= 300) {
          digitalWrite(PIN_LED_R, LOW);
          ledState = LED_IDLE;
          ledStep = 0;
        }
        break;
    }
  }
}

void triggerLed(int result) {
  ledStep = 0;
  ledLastMs = millis();
  ledState = (result == 1) ? LED_SUCCESS : LED_FAIL;
  digitalWrite((result == 1) ? PIN_LED_G : PIN_LED_R, HIGH);
}

// ============================================================
// STUB: Replace body with real MQTT publish and subscribe logic later
// ============================================================
void publishPauseState(int paused_now) {
  Serial.print("[PAUSE_STATE] ");
  Serial.println(paused_now ? 1 : 0);
}

void successAction() {
  Serial.println("[RESULT] SUCCESS");
  triggerVibro(1);
  triggerBuzzer(1);
  triggerLed(1);
}

void failAction() {
  Serial.println("[RESULT] FAIL");
  triggerVibro(0);
  triggerBuzzer(0);
  triggerLed(0);
}

// ============================================================
// SETUP
// ============================================================
void hardwareSetup() {
  // Serial.begin(115200);
  Wire.begin(PIN_SDA, PIN_SCL);
  initMPU(Wire, MPU_ADDR);

  ledcAttach(PIN_VIBRO, VIBRO_FREQ, VIBRO_RES);
  ledcAttach(PIN_BUZZER, 2000, BUZZER_RES);
  ledcWrite(PIN_VIBRO, 0);
  ledcWriteTone(PIN_BUZZER, 0);

  pinMode(PIN_LED_R, OUTPUT);
  digitalWrite(PIN_LED_R, LOW);
  pinMode(PIN_LED_G, OUTPUT);
  digitalWrite(PIN_LED_G, LOW);

  pinMode(PIN_BTN_PAUSE, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(PIN_BTN_PAUSE), onPauseButton, CHANGE);

  Serial.println("Ready. Enter 1 (success) or 0 (fail).");
}

// ============================================================
// LOOP
// ============================================================
void hardwareLoop(PublishFn publishFn, PublishPauseFn pauseFn) {
  unsigned long now = millis();

  if (btnIsrReq) {
    noInterrupts();
    btnIsrReq = false;
    interrupts();

    int level = digitalRead(PIN_BTN_PAUSE);

    if (level == LOW && btnArmed) {
      paused = !paused;
      btnArmed = false;
      // 1 == paused; 0 == resume
      pauseFn(paused ? 1 : 0);
    }

    else if (level == HIGH) {
      btnArmed = true;
    }
  }

  updateVibro();
  updateBuzzer();
  updateLed();

  if (!paused && (now - lastReadTime >= READ_INTERVAL_MS)) {
    lastReadTime = now;
    int16_t ax, ay, az, gx, gy, gz;
    readMPU(Wire, MPU_ADDR, &ax, &ay, &az, &gx, &gy, &gz);
    publishFn(ax, ay, az, gx, gy, gz);
  }
}
