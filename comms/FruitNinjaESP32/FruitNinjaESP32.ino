#include <WiFi.h>
#include <PubSubClient.h>
#include <secrets.h>
#include <ArduinoJson.h>
#include <actuators.h>
#include <mqtt.h>
#include <WiFiClientSecure.h>
#include "certs.h"
#include "demo_packets.h"


//============================================================
// Uncomment these based on which esp is being programmed
//============================================================
// #define PLAYER_ID "attacker"
// #define IS_ATTACKER


// #define PLAYER_ID "defender/hand"
// #define IS_DEFENDER_HAND

#define PLAYER_ID "defender/sword"
#define IS_DEFENDER_SWORD
//============================================================
#define SCHOOL true

#ifdef IS_DEFENDER_HAND
  #include "defender_hand.h"
#endif
#ifdef IS_DEFENDER_SWORD
  #include "defender_sword.h"
#endif
#ifdef IS_ATTACKER
  #include "attacker_hand.h"
#endif

WiFiClientSecure espClient;
PubSubClient client(espClient);


// Building up MQTT topics per player
// This way we can separate out the IMUs for each player and also have a wii style connect/disconnect thing

// Following are just topic builders to avoid repetition

String baseTopic() {
  return "fruitninja/" + String(PLAYER_ID);
}

// Only send disconnects using Last Will
String statusTopic() {
  return baseTopic() + "/status";
}

String imuTopic() {
  return baseTopic() + "/imu/window";
}

String controlTopic() {
  return baseTopic() + "/control";
}

String demoTopic() {
  return baseTopic() + "/demo";
}

void connectMQTT() {
  while (!client.connected()) {
    String client_id = "esp32-player-" + String(PLAYER_ID);

    Serial.printf("Connecting to MQTT broker as %s\n", client_id.c_str());

    bool conn_status = client.connect(
      client_id.c_str(),
      mqtt_username,
      mqtt_password,
      statusTopic().c_str(),  // last will topic
      1,                      // qos
      true,
      "offline"  // message to be sent on topic
    );

    if (conn_status) {
      Serial.println("Connected to MQTT broker");

      client.subscribe(controlTopic().c_str());  // commands to esp32 from unity
      client.subscribe(demoTopic().c_str());     // for individual subcomp demo
      client.publish(statusTopic().c_str(), "online");

    } else {
      Serial.print("MQTT connect failed, state=");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

void publishIMUWindow(float ax, float ay, float az,
                      float gx, float gy, float gz) {

  StaticJsonDocument<128> doc;

  char buf[16];

  snprintf(buf, sizeof(buf), "%.3f", ax);
  doc["ax"] = buf;

  snprintf(buf, sizeof(buf), "%.3f", ay);
  doc["ay"] = buf;

  snprintf(buf, sizeof(buf), "%.3f", az);
  doc["az"] = buf;

  snprintf(buf, sizeof(buf), "%.3f", gx);
  doc["gx"] = buf;

  snprintf(buf, sizeof(buf), "%.3f", gy);
  doc["gy"] = buf;

  snprintf(buf, sizeof(buf), "%.3f", gz);
  doc["gz"] = buf;

  static char out[128];
  size_t n = serializeJson(doc, out);
  client.publish(imuTopic().c_str(), out, n);
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
  StaticJsonDocument<2048> doc;  // we will minimize size based on our JSON
  DeserializationError error = deserializeJson(doc, msg);
  if (error) {
    Serial.print("Failed to parse JSON: ");
    Serial.println(error.c_str());
    return;
  }

  const char *device = doc["device"];
  const char *action = doc["action"];
  
  // Example mappings I thought of
  // if (strcmp(device, "buzzer") == 0 && strcmp(action, "successBuzz") == 0) {
  //   successAction();
  // } else if(strcmp(device, "buzzer") == 0 && strcmp(action, "failBuzz") == 0) {
  //   failAction();
  // } else if (strcmp(device, "led") == 0 && strcmp(action, "lifeLost") == 0) {
  //   lifeLostLED();
  // } else {
  //   customAction(device, action);
  // }
}

void publishPause(int isPaused) {
  if (isPaused == 1) {
    client.publish(statusTopic().c_str(), "paused");
  } else {
    client.publish(statusTopic().c_str(), "resumed");
  }
}

void setup() {
  Serial.begin(115200);
  delay(1500);


  int n = WiFi.scanNetworks();
  bool foundJon = false;
  for (int i = 0; i < n; i++) {
    Serial.println(WiFi.SSID(i));
    if (WiFi.SSID(i) == "B05") {
      foundJon = true;
    }
  }
  if (!foundJon){
    Serial.println("Could not find B05!!!!!!!");
  }

  if (SCHOOL) {
    Serial.println("wifi is school");
    ssid = school_ssid;
    password = school_password;
  }

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
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");

  Serial.print("Waiting for NTP time sync");
  while (time(nullptr) < 1700000000) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nTime synced!");

  const char *mqtt_broker = mqtt_broker_school;

  if (String(ssid) == "SINGTEL-A620") {
    mqtt_broker = mqtt_broker_home;
  }

  client.setBufferSize(2048);
  client.setServer(mqtt_broker, mqtt_port);
  client.setCallback(callback);

  // espClient.setInsecure();
  espClient.setCACert(CA_CERT);
  espClient.setHandshakeTimeout(10);  // 10 second for debug

  connectMQTT();
  // hardwareSetup();
  defenderSwordSetup();
}


void loop() {
  if (!client.connected()) {
    connectMQTT();
  }
  // hardwareLoop(publishIMUWindow);
  defenderSwordLoop(publishIMUWindow, publishPause);
  client.loop();
}
