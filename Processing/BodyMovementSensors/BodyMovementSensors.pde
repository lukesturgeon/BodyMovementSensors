import processing.serial.*;

Serial myPort;

// store data from Arduino
float[] xValA;
float[] yValA;
float[] zValA;
float[] xValB;
float[] yValB;
float[] zValB;
float[] breathingValue;
float[] stretchAValue;
float[] stretchBValue;
float[] gsrValue;
float[] pulseValue;

// UI 
color dataColor;
color gridColor;

boolean connection;

void setup() {
  size(900, 800);
  background(0);

  xValA = new float[width];
  yValA = new float[width];
  zValA = new float[width];

  xValB = new float[width];
  yValB = new float[width];
  zValB = new float[width];

  breathingValue = new float[width];
  stretchAValue = new float[width];
  stretchBValue = new float[width];
  gsrValue = new float[width];
  pulseValue = new float[width];

  dataColor = color(255, 0, 255);
  gridColor = color(75);

  connection = false;

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[8], 9600);

  stroke(255);
  noFill();
}

void draw() {
  background(0);
  noFill();

  drawAccelerometerA();

  pushMatrix();

  translate(0, 100);
  drawAccelerometerB();

  pushMatrix();
  translate(0, 100);
  drawBreathing();

  pushMatrix();
  translate(0, 100);
  drawGSR();  

  pushMatrix();
  translate(0, 100);
  drawPulse();  

  pushMatrix();
  translate(0, 100);
  drawStretchA();

  pushMatrix();
  translate(0, 100);
  drawStretchB();
  popMatrix();

  popMatrix();

  popMatrix();

  popMatrix();

  popMatrix();

  popMatrix();


  // GET MORE DATA?
  if (connection == true) {
    fill(0, 255, 0);
    // send an 'a' for more bytes
    myPort.write('a');
  } else {
    fill(255, 0, 0);
  }
}

void serialEvent( Serial _port ) {
  String myString = _port.readStringUntil('\n');

  //  println("received: " + myString);

  if (myString != null) {
    myString = trim(myString);

    if ( myString.equals("OK") ) {
      connection = true;
    } else if (connection == true) {

      println(myString);

      float[] acc = float(splitTokens(myString, ","));
      if (acc.length == 11) {

        // shift down all the existing values by 1
        for ( int i = 1; i < xValA.length; i++ ) {
          xValA[i-1] = xValA[i];
          yValA[i-1] = yValA[i];
          zValA[i-1] = zValA[i];
          xValB[i-1] = xValB[i];
          yValB[i-1] = yValB[i];
          zValB[i-1] = zValB[i];
          breathingValue[i-1] = breathingValue[i];
          stretchAValue[i-1] = stretchAValue[i];
          stretchBValue[i-1] = stretchBValue[i];
          gsrValue[i-1] = gsrValue[i];
          pulseValue[i-1] = pulseValue[i];
        }

        // add new data to the end
        xValA[xValA.length-1] = map(acc[0], 0, 1023, -1, 1);
        yValA[yValA.length-1] = map(acc[1], 0, 1023, -1, 1);
        zValA[zValA.length-1] = map(acc[2], 0, 1023, -1, 1);
        xValB[xValB.length-1] = map(acc[3], 0, 1023, -1, 1);
        yValB[yValB.length-1] = map(acc[4], 0, 1023, -1, 1);
        zValB[zValB.length-1] = map(acc[5], 0, 1023, -1, 1);
        breathingValue[breathingValue.length-1] = acc[6];
        stretchAValue[stretchAValue.length-1] = acc[7];
        stretchBValue[stretchBValue.length-1] = acc[8];
        gsrValue[gsrValue.length-1] = acc[9];
        pulseValue[pulseValue.length-1] = acc[10];
      }
    }
  }
}

void drawAccelerometerA () {
  // draw the graphs
  stroke(255, 0, 0);
  beginShape();
  for ( int i = 0; i < xValA.length-1; i++ ) {
    vertex(i, 50 + (50 * xValA[i]) );
  }
  endShape();

  stroke(0, 255, 0);
  beginShape(); 
  for ( int i = 0; i < yValA.length-1; i++ ) {
    vertex(i, 50 + (50 * yValA[i]) );
  }
  endShape();

  stroke(0, 0, 255);
  beginShape(); 
  for ( int i = 0; i < zValA.length-1; i++ ) {
    vertex(i, 50 + (50 * zValA[i]) );
  }
  endShape();

  stroke(gridColor);
  line(0, 100, width, 100);
  text("Accelerometer A", 0, 50);
}

void drawAccelerometerB () {
  // draw the graphs
  stroke(255, 0, 0);
  beginShape();
  for ( int i = 0; i < xValB.length-1; i++ ) {
    vertex(i, 50 + (50 * xValB[i]) );
  }
  endShape();

  stroke(0, 255, 0);
  beginShape(); 
  for ( int i = 0; i < yValB.length-1; i++ ) {
    vertex(i, 50 + (50 * yValB[i]) );
  }
  endShape();

  stroke(0, 0, 255);
  beginShape(); 
  for ( int i = 0; i < zValB.length-1; i++ ) {
    vertex(i, 50 + (50 * zValB[i]) );
  }
  endShape();

  stroke(gridColor);
  line(0, 100, width, 100);
  text("Accelerometer B", 0, 50);
}


void drawBreathing () {
  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < breathingValue.length-1; i++ ) {
    vertex(i, map(breathingValue[i], 0, 1023, 50, 0) );
  }
  endShape();
  stroke(gridColor);
  line(0, 100, width, 100);
  text("Breathing", 0, 50);
}

void drawGSR () {
  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < gsrValue.length-1; i++ ) {
    vertex(i, map(gsrValue[i], 0, 1023, 50, 0) );
  }
  endShape();
  stroke(gridColor);
  line(0, 100, width, 100);
  text("Galvanic Skin Response", 0, 50);
}

void drawPulse () {
  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < pulseValue.length-1; i++ ) {
    vertex(i, map(pulseValue[i], 0, 1023, 50, 0) );
  }
  endShape();
  stroke(gridColor);
  line(0, 100, width, 100);
  text("Pulse", 0, 50);
}

void drawStretchA () {
  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < stretchAValue.length-1; i++ ) {
    vertex(i, map(stretchAValue[i], 0, 1023, 50, 0) );
  }
  endShape();
  stroke(gridColor);
  line(0, 100, width, 100);
  text("Stretch A", 0, 50);
}

void drawStretchB () {
  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < stretchBValue.length-1; i++ ) {
    vertex(i, map(stretchBValue[i], 0, 1023, 50, 0) );
  }
  endShape();
  stroke(gridColor);
  line(0, 100, width, 100);
  text("Stretch A", 0, 50);
}

