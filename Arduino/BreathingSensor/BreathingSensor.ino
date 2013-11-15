/**
 * Breathing sensor
 * 
 * By: Luke Sturgeon
 * Email: hello@lukesturgeon.co.uk
 * Date: 15 November 2013
 * License: Public domain
 * 
 * This sketch broadcasts any analog values (0-1023) that would
 * be received through the pressure sensor that is tightly pressed 
 * against the chest.
 */

void setup()
{ 
  Serial.begin(9600);
}

void loop()
{
  int a = analogRead(A5);
  // Serial.println(a);

  if ( Serial.available() > 0 ) 
  {
    byte inbyte = Serial.read();
    if(inbyte == 'a'){
      Serial.print("B,");
      Serial.println(a);
    } 
  }

}








