import processing.serial.*;

Serial myPort;

float[] xVal;
float[] yVal;
float[] zVal;

void setup() {
  size(900, 600);
  background(0);

  xVal = new float[width];
  yVal = new float[width];
  zVal = new float[width];

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[8], 9600);

  textAlign(CENTER, CENTER);
  stroke(255);
  noFill();
}

void draw() {
  background(0);

  // draw the graphs
  beginShape();
  for ( int i = 0; i < xVal.length-1; i++ ) {
    vertex(i, 100 + (100 * xVal[i]) );
  }
  endShape();


  beginShape(); 
  for ( int i = 0; i < yVal.length-1; i++ ) {
    vertex(i, 300 + (100 * yVal[i]) );
  }
  endShape();

  beginShape(); 
  for ( int i = 0; i < zVal.length-1; i++ ) {
    vertex(i, 500 + (100 * zVal[i]) );
  }
  endShape();

  /*text("x:" + xVal.get( xVal.size()-1 ) + "\n" 
   + "y:" + yVal.get( yVal.size()-1 ) + "\n"
   + "z:" + zVal.get( zVal.size()-1 ) + "\n", 
   0, 0, width, height);*/
   text("x", 10, 85);
   text("y", 10, 285);
   text("z", 10, 485);

  // send an 'a' for more bytes
  myPort.write('a');
}

void serialEvent( Serial _port ) {
  String myString = _port.readStringUntil('\n');
  if (myString != null) {
    float[] acc = float(splitTokens(myString, ","));

    for ( int i = 1; i < xVal.length; i++ ) {
      xVal[i-1] = xVal[i];
      yVal[i-1] = yVal[i];
      zVal[i-1] = zVal[i];
    }

    // add new data to the end
    xVal[xVal.length-1] = acc[0];
    yVal[yVal.length-1] = acc[1];
    zVal[zVal.length-1] = acc[2]-1;
  }
}

