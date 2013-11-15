/**
 * Conductive Rubber sensor test
 * 
 * By: Luke Sturgeon
 * Email: hello@lukesturgeon.co.uk
 * Date: 15 November 2013
 * License: Public domain
 * 
 * This sketch broadcasts any analog values (0-1023) that would
 * be received through the conductive rubber circuit.
 */

void setup() {
  Serial.begin(9600);
}

void loop() {
  int a = analogRead(A4);
  //  Serial.println(a);

  // wait and listen for an 'a' from Processing
  // before sending the next data
  if (Serial.available() > 0) {
    byte inByte = Serial.read();
    if (inByte == 'a') {
      Serial.write(a);
    }
  }
}

