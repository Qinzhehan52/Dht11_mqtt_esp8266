#include <ArduinoJson.h>
#include <dht11.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#define DHT11PIN 2

StaticJsonBuffer<200> jsonBuffer;
char buffer[256];
JsonObject& sensor = jsonBuffer.createObject();

dht11 DHT11;
const char* ssid = "ssid";
const char* password = "passwd";

const char* server = "server_ip";

const char* user = "user";
const char* passwd = "passwd";
const char* topic = "dht11";

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println("DHT11 TEST PROGRAM ");
  Serial.print("LIBRARY VERSION: ");
  Serial.println(DHT11LIB_VERSION);
  setup_wifi();
  client.setServer(server, 1883);
  delay(10);
}

void loop() {
  // put your main code here, to run repeatedly:
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  printdht11();
}

void setup_wifi()
{
  WiFi.begin(ssid, password);
  while(WiFi.status() != WL_CONNECTED) 
  {
    delay(500);
    Serial.print("."); 
   }
   Serial.println("WiFi connected");
   Serial.println("IP address: ");
   Serial.println(WiFi.localIP());
  }

void printdht11()
{
 int chk = DHT11.read(DHT11PIN);
 
  Serial.print("Read sensor: ");
  switch (chk)
  {
    case DHTLIB_OK: 
                Serial.println("OK"); 
                break;
    case DHTLIB_ERROR_CHECKSUM: 
                Serial.println("Checksum error"); 
                break;
    case DHTLIB_ERROR_TIMEOUT: 
                Serial.println("Time out error"); 
                break;
    default: 
                Serial.println("Unknown error"); 
                break;
  }
 
  Serial.print("Humidity (%): ");
  Serial.println((float)DHT11.humidity, 2);
  sensor["humi"] = DHT11.humidity;
   
  Serial.print("Temperature (oC): ");
  Serial.println((float)DHT11.temperature, 2);
  sensor["temp"] = DHT11.temperature;

  sensor.printTo(Serial);
  sensor.printTo(buffer, sizeof(buffer));
  client.publish(topic,buffer,true);
  
  delay(2000); 
 }

 void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    // If you do not want to use a username and password, change next line to
    // if (client.connect("ESP8266Client")) {
    if (client.connect("ESP8266Client", user, password)) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}