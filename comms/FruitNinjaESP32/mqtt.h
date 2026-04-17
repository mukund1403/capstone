#pragma once
#include <PubSubClient.h>
#include <ArduinoJson.h>

extern PubSubClient client;
void publishIMUWindow(JsonDocument& doc);
