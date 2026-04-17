#ifndef ACTUATORS_H
#define ACTUATORS_H

#include <Arduino.h>

// Buzzer
void successBuzzer();
void errorBuzzer();

// LED strip
void lifeLostLED();
void fullHealthLED();

// Other generic actuators
void customAction(const String &device, const String &action);

#endif
