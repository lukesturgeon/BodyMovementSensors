void setup() {
  Serial.begin(9600);
}

void loop() {
  int a = analogRead(A0);
  Serial.println(a);
  
  // wait and listen for an 'a' from Processing
  // before sending the next data
  if (Serial.available() > 0) {
    byte inByte = Serial.read();
    if (inByte == 'a') {
      Serial.write(a);
    }
  }
}
