
void setup()
{
  Serial.begin(9600);
}

void loop()
{
  // Wait for a handshake
  byte incomingByte;
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    if(incomingByte=='A')
    {
      int a = analogRead(A5);
      Serial.println(a);
    }
  }
}
