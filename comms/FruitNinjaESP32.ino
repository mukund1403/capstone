#include <WiFi.h>
#include <PubSubClient.h>
#include <secrets.h>
#include <ArduinoJson.h>
#include <actuators.h>

// Forward declaration
void callback(char *topic, byte *payload, unsigned int length);

WiFiClient espClient;
PubSubClient client(espClient);


// Building up MQTT topics per player
// This way we can separate out the IMUs for each player and also have a wii style connect/disconnect thing
#define PLAYER_ID 1

String baseTopic() {
  return "fruitninja/player/" + String(PLAYER_ID);
}

String statusTopic() {
  return baseTopic() + "/status";
}

String imuTopic() {
  return baseTopic() + "/imu/window";
}

String controlTopic() {
  return baseTopic() + "/control";
}

void connectMQTT() {
  while (!client.connected()) {
    String client_id = "esp32-player-" + String(PLAYER_ID);

    Serial.printf("Connecting to MQTT broker as %s\n", client_id.c_str());

    bool conn_status = client.connect(
      client_id.c_str(),
      mqtt_username,
      mqtt_password,
      statusTopic().c_str(),
      1,
      true,
      "offline");

    if (conn_status) {
      Serial.println("Connected to MQTT broker");

      client.subscribe(controlTopic().c_str());  // we will get commands to esp32 from here

      client.publish(statusTopic().c_str(), "online", true);  // send health status to ultra96 from here
    } else {
      Serial.print("MQTT connect failed, state=");
      Serial.println(client.state());
      delay(2000);
    }
  }
}


void setup() {
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < 20) {
    delay(500);
    Serial.print(".");
    retries++;
  }

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("\nWiFi FAILED");
    Serial.print("Status code: ");
    Serial.println(WiFi.status());
    return;
  }

  Serial.println("\nWiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  const char *mqtt_broker = mqtt_broker_school;  

  if (String(ssid) == "SINGTEL-A620") {
    mqtt_broker = mqtt_broker_home;
  }

  client.setServer(mqtt_broker, mqtt_port);
  client.setCallback(callback);

  connectMQTT();

  client.publish(imuTopic().c_str(), "ESP32 online");
}

// Any actuator logic needs to be handled from here
void callback(char *topic, byte *payload, unsigned int length) {
  // Copy payload to a null-terminated string
  char msg[length + 1];
  memcpy(msg, payload, length);
  msg[length] = '\0';

  Serial.print("Message on topic: ");
  Serial.println(topic);
  Serial.print("Payload: ");
  Serial.println(msg);

  // Parse JSON
  StaticJsonDocument<400> doc;  // adjust size based on your JSON
  DeserializationError error = deserializeJson(doc, msg);
  if (error) {
    Serial.print("Failed to parse JSON: ");
    Serial.println(error.c_str());
    return;
  }

  const char* device = doc["device"];
  const char* action = doc["action"];

  // Example mappings I thought of
  if (strcmp(device, "buzzer") == 0 && strcmp(action, "success") == 0) {
    successBuzzer();
  } else if (strcmp(device, "led") == 0 && strcmp(action, "lifeLost") == 0) {
    lifeLostLED();
  } else {
    customAction(device, action);
  }
}

void loop() {
  if (!client.connected()) {
    connectMQTT();
  }
  client.loop();
}
