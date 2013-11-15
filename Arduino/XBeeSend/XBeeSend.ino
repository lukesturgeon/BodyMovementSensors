/**
 * XBee Serial broadcasting sketch for testing
 * 
 * By: Luke Sturgeon
 * Email: hello@lukesturgeon.co.uk
 * Date: 15 November 2013
 * License: Public domain
 * 
 * This sketch broadcasts an incrementing number every second.
 */

int counter = 0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.println(counter);
  counter += 1;

  delay(1000);
}

