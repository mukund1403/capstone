#include "actuators.h"

// ------------------ Buzzer ------------------
void successBuzzer() {
    Serial.println("Buzzer: SUCCESS tone");
}

void errorBuzzer() {
    Serial.println("Buzzer: ERROR tone");
}

// ------------------ LED Strip ------------------
void lifeLostLED() {
    Serial.println("LED Strip: Life lost animation");
}

void fullHealthLED() {
    Serial.println("LED Strip: Full health animation");
}


// ------------------ Generic action ------------------
void customAction(const String &device, const String &action) {
    Serial.print("Custom action for device: ");
    Serial.print(device);
    Serial.print(", action: ");
    Serial.println(action);
}
