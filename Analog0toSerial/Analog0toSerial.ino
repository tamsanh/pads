
void setup()
{
  Serial.begin(38400);
  digitalWrite(A0,HIGH);
}

void loop()
{
  // Wait for a handshake
  byte incomingByte;
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    int a = analogRead(A0);
    Serial.println(a);
    delay(10);
  }
}
