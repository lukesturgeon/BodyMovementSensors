import controlP5.*;
import processing.serial.*;

// state constants
final static int READY      = 0;
final static int CONNECTED  = 1;
final static int RECORDING  = 2;

final static String MOTION_A = "motion_a";
final static String MOTION_B = "motion_b";
final static String CARDIO = "cardiovascular_system";
final static String GSR = "nervous_system";
final static String PULSE = "pulmonary_system";
final static String STRETCH_A = "expansion_a";
final static String STRETCH_B = "expansion_b";

Serial myPort;
ControlP5 cp5;
Table table;

// store data from Arduino
SensorDataList xValA;
SensorDataList yValA;
SensorDataList zValA;
SensorDataList xValB;
SensorDataList yValB;
SensorDataList zValB;

SensorDataList cardioData;
SensorDataList gsrData;
SensorDataList pulseData;
SensorDataList stretchAData;
SensorDataList stretchBData;

// UI 
Range accelerometer1Range;
Range accelerometer2Range;
Range cardioRange;
Range gsrRange;
Range pulseRange;
Range stretchARange;
Range stretchBRange;
color dataColor;
color gridColor;
int previewResolution;

int state = READY;

void setup() {
  size(1024, 768);
  background(0);
  textSize(11);

  previewResolution = width - 300;

  table = new Table();
  table.addColumn("id");
  table.addColumn(MOTION_A + "_x");
  table.addColumn(MOTION_A + "_y");
  table.addColumn(MOTION_A + "_z");
  table.addColumn(MOTION_B + "_x");
  table.addColumn(MOTION_B + "_y");
  table.addColumn(MOTION_B + "_z");
  table.addColumn(CARDIO);
  table.addColumn(GSR);
  table.addColumn(PULSE);
  table.addColumn(STRETCH_A);
  table.addColumn(STRETCH_B);

  setupControlP5();

  xValA = new SensorDataList(previewResolution, 512);
  yValA = new SensorDataList(previewResolution, 512);
  zValA = new SensorDataList(previewResolution, 512);

  xValB = new SensorDataList(previewResolution, 512);
  yValB = new SensorDataList(previewResolution, 512);
  zValB = new SensorDataList(previewResolution, 512);

  cardioData = new SensorDataList(previewResolution, 0);
  pulseData = new SensorDataList(previewResolution, 0);
  gsrData = new SensorDataList(previewResolution, 0);
  stretchAData = new SensorDataList(previewResolution, 0);
  stretchBData = new SensorDataList(previewResolution, 0);

  dataColor = color(255, 0, 0);
  gridColor = color(55);

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[8], 9600);

  stroke(255);
  noFill();
}

void draw() {
  background(30);
  noFill();

  pushMatrix();
  // nudge to the left
  translate(width - previewResolution, 0);

  drawAccelerometerA();

  pushMatrix();
  translate(0, 100);
  drawAccelerometerB();

  pushMatrix();
  translate(0, 100);
  drawCardio();

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

  popMatrix();

  // draw the divide lines?
  stroke(gridColor);
  for (int i = 1; i < 8; i++) {
    line(0, i * 100, width, i * 100);
  }

  // draw the debugging data
  text(MOTION_A + "\nmin: " + min(xValA.getMin(), yValA.getMin(), zValA.getMin()) + " / max: " + max(xValA.getMax(), yValA.getMax(), zValA.getMax()), 30, 30);
  text(MOTION_B + "\nmin: " + min(xValB.getMin(), yValB.getMin(), zValB.getMin()) + " / max: " + max(xValB.getMax(), yValB.getMax(), zValB.getMax()), 30, 130);
  text(CARDIO + "\nmin: " + cardioData.getMin() + " / max: " + cardioData.getMax(), 30, 230);
  text(GSR + "\nmin: " + gsrData.getMin() + " / max: " + gsrData.getMax(), 30, 330);
  text(PULSE + "\nmin: " + pulseData.getMin() + " / max: " + pulseData.getMax(), 30, 430);
  text(STRETCH_A + "\nmin: " + stretchAData.getMin() + " / max: " + stretchAData.getMax(), 30, 530);
  text(STRETCH_B + "\nmin: " + stretchBData.getMin() + " / max: " + stretchBData.getMax(), 30, 630);
  text("SAVE SETTINGS = 'S' / LOAD SETTINGS = 'L' / RESET = 'R'", 30, 738);

  // GET MORE DATA?
  if (state == CONNECTED) {
    // send an 'a' for more bytes
    myPort.write('a');
  }
}

void keyPressed() {
  // default properties load/save key combinations are 
  // alt+shift+l to load properties
  // alt+shift+s to save properties
  if (key == 'S') {
    cp5.saveProperties(("body.properties"));
  } else if (key == 'L') {
    cp5.loadProperties(("body.properties"));
  } else if (key == 'R') {
    xValA.reset();
    yValA.reset();
    zValA.reset();
    xValB.reset();
    yValB.reset();
    zValB.reset();
    cardioData.reset();
    gsrData.reset();
    pulseData.reset();
    stretchAData.reset();
    stretchBData.reset();
  }
}

void serialEvent( Serial _port ) {
  String myString = _port.readStringUntil('\n');
  if (myString != null) {
    myString = trim(myString);
    if ( state == READY && myString.equals("OK") ) {
      state = CONNECTED;
      dataColor = color(0, 255, 0);
    } else if (state == CONNECTED) {
      // preview the data
      int[] acc = int(splitTokens(myString, ","));
      if (acc.length == 11) {

        // save temp RAW data
        xValA.add(acc[0]);
        yValA.add(acc[1]);
        zValA.add(acc[2]);

        xValB.add(acc[3]);
        yValB.add(acc[4]);
        zValB.add(acc[5]);

        cardioData.add(acc[6]);
        stretchAData.add(acc[7]);
        stretchBData.add(acc[8]);
        gsrData.add(acc[9]);
        pulseData.add(acc[10]);


        // record RAW data?
        if (state == RECORDING) {
          TableRow newRow = table.addRow();
          newRow.setInt("id", table.lastRowIndex());
          newRow.setInt(MOTION_A + "_x", acc[0]);
          newRow.setInt(MOTION_A + "_y", acc[1]);
          newRow.setInt(MOTION_A + "_z", acc[2]);
          newRow.setInt(MOTION_B + "_x", acc[3]);
          newRow.setInt(MOTION_B + "_y", acc[4]);
          newRow.setInt(MOTION_B + "_z", acc[5]);
          newRow.setInt(CARDIO, acc[6]);
          newRow.setInt(GSR, acc[7]);
          newRow.setInt(PULSE, acc[8]);
          newRow.setInt(STRETCH_A, acc[9]);
          newRow.setInt(STRETCH_B, acc[11]);
        }
      }
    }
  }
}

void drawAccelerometerA () {
  float high = accelerometer1Range.getHighValue();
  float low = accelerometer1Range.getLowValue();

  // draw the graphs
  stroke(dataColor);
  beginShape();
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(xValA.get(i), low, high, 0, 100) );
  }
  endShape();
  stroke(dataColor, 155);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(yValA.get(i), low, high, 0, 100) );
  }
  endShape();
  stroke(dataColor, 55);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(zValA.get(i), low, high, 0, 100) );
  }
  endShape();
}

void drawAccelerometerB () {
  float high = accelerometer2Range.getHighValue();
  float low = accelerometer2Range.getLowValue();

  // draw the graphs
  stroke(dataColor);
  beginShape();
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(xValB.get(i), low, high, 0, 100) );
  }
  endShape();
  stroke(dataColor, 155);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(yValB.get(i), low, high, 0, 100) );
  }
  endShape();
  stroke(dataColor, 55);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(zValB.get(i), low, high, 0, 100) );
  }
  endShape();
}


void drawCardio () {
  float high = cardioRange.getHighValue();
  float low = cardioRange.getLowValue();

  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(cardioData.get(i), low, high, 50, 0) );
  }
  endShape();
}

void drawGSR () {
  float high = gsrRange.getHighValue();
  float low = gsrRange.getLowValue();

  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(gsrData.get(i), low, high, 50, 0) );
  }
  endShape();
}

void drawPulse () {
  float high = pulseRange.getHighValue();
  float low = pulseRange.getLowValue();

  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(pulseData.get(i), low, high, 50, 0) );
  }
  endShape();
}

void drawStretchA () {
  float high = stretchARange.getHighValue();
  float low = stretchARange.getLowValue();

  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(stretchAData.get(i), low, high, 50, 0) );
  }
  endShape();
}

void drawStretchB () {
  float high = stretchBRange.getHighValue();
  float low = stretchBRange.getLowValue();

  stroke(dataColor);
  beginShape(); 
  for ( int i = 0; i < previewResolution-1; i++ ) {
    vertex(i, map(stretchBData.get(i), low, high, 50, 0) );
  }
  endShape();
}

void setupControlP5() {
  int _w = 140;
  int _h = 14;

  cp5 = new ControlP5(this);
  accelerometer1Range = cp5.addRange(MOTION_A)
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(30, 60)
        .setSize(_w, _h)
          .setHandleSize(20)
            .setRange(0, 1023)
              .setRangeValues(0, 1023)
                // after the initialization we turn broadcast back on again
                .setBroadcast(true);

  accelerometer2Range = cp5.addRange(MOTION_B)
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(30, 160)
        .setSize(_w, _h)
          .setHandleSize(20)
            .setRange(0, 1023)
              .setRangeValues(0, 1023)
                // after the initialization we turn broadcast back on again
                .setBroadcast(true);

  cardioRange = cp5.addRange(CARDIO)
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(30, 260)
        .setSize(_w, _h)
          .setHandleSize(20)
            .setRange(0, 1023)
              .setRangeValues(0, 1023)
                // after the initialization we turn broadcast back on again
                .setBroadcast(true);

  gsrRange = cp5.addRange(GSR)
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(30, 360)
        .setSize(_w, _h)
          .setHandleSize(20)
            .setRange(0, 1023)
              .setRangeValues(0, 1023)
                // after the initialization we turn broadcast back on again
                .setBroadcast(true);


  pulseRange = cp5.addRange(PULSE)
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(30, 460)
        .setSize(_w, _h)
          .setHandleSize(20)
            .setRange(0, 1023)
              .setRangeValues(0, 1023)
                // after the initialization we turn broadcast back on again
                .setBroadcast(true);

  stretchARange = cp5.addRange(STRETCH_A)
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(30, 560)
        .setSize(_w, _h)
          .setHandleSize(20)
            .setRange(0, 1023)
              .setRangeValues(0, 1023)
                // after the initialization we turn broadcast back on again
                .setBroadcast(true);

  stretchBRange = cp5.addRange(STRETCH_B)
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(30, 660)
        .setSize(_w, _h)
          .setHandleSize(20)
            .setRange(0, 1023)
              .setRangeValues(0, 1023)
                // after the initialization we turn broadcast back on again
                .setBroadcast(true);
}
