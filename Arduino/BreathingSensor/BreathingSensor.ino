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





