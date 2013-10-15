import processing.serial.*;

Serial myPort;

int[] breathingValue;

void setup()
{
  size(800, 400);
  background(0);

  noFill();
  stroke(255);

  breathingValue = new int[width];
  myPort = new Serial(this, Serial.list()[9], 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  background(0);

  // draw the graphs
  beginShape();
  for ( int i = 0; i < breathingValue.length-1; i++ ) {    
    vertex( i, (height/2) - (breathingValue[i] * 0.59) );
  }
  endShape();

  // send an 'a' for more bytes
  myPort.write('a');
}

void serialEvent(Serial _port)
{
  /*int inByte = myPort.read();
   println(inByte);*/
  String myString = _port.readStringUntil('\n');
  if ( myString != null ) {
    float[] a = float(splitTokens(myString, ","));

    // move the values down 1
    for ( int i = 1; i < breathingValue.length; i++ ) {
      breathingValue[i-1] = breathingValue[i];
    }

    // add new value to the end
    breathingValue[breathingValue.length-1] = int(a[1]);
  }
}

