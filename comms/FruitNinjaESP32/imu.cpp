#include "mqtt.h"

void processIMU(JsonDocument& doc) {
  // minimal modification
  JsonArray ax = doc["ax"];
  if (!ax.isNull() && ax.size() > 0) {
    ax[0] = ax[0].as<float>() + 0.01f;
  }

  publishIMUWindow(doc);
}
