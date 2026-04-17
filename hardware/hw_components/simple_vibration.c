#define VIB_PIN 25
#define PWM_FREQ 255   // try 180–250
#define PWM_RES  8     // 0–255

void buzz(int strength, int on_ms, int off_ms) {
  ledcWrite(VIB_PIN, strength);   // write duty to pin
  delay(on_ms);
  ledcWrite(VIB_PIN, 0);
  delay(off_ms);
}

void setup() {
  pinMode(VIB_PIN, OUTPUT);

  // New ESP32 Arduino core (3.x) LEDC API
  // ledcAttach(pin, freq, resolution_bits)
  ledcAttach(VIB_PIN, PWM_FREQ, PWM_RES);
  ledcWrite(VIB_PIN, 0);
}

void loop() {
  buzz(255, 150, 300);
  buzz(220, 100, 120);
  buzz(220, 100, 600);
}
