#include <SPI.h>
#include <Ethernet.h>

// Enter the IP address of the server you're connecting to:
// These two lines likely need to be changed.
IPAddress server(192,168,1,2); 
static int id = 7;

static int port = 8000;
IPAddress ip(192,168,1,(100+id));

byte mac[] = {  
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

// Initialize the Ethernet client library
// with the IP address and port of the server 
EthernetClient client;

void setup() {
  // start the Ethernet connection:
  Ethernet.begin(mac, ip);
  // start the serial library:
  Serial.begin(9600);
  // give the Ethernet shield a second to initialize:
  delay(1000);
  Serial.println("connecting...");

  // if you get a connection, report back via serial:
  if (client.connect(server, port)) {
    Serial.println("connected");
    client.println(id);
  } 
  else {
    Serial.println("connection failed");
  }
}

void loop()
{
  
  //Send the sensor data to the server
    if (client.connected()) {
      int sen = analogRead(A0);
      client.println(String(sen));
      delay(10);
    }


  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
    // do nothing:
    while(true);
  }
}
