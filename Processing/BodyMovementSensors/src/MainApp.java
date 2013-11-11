import processing.core.*;
import processing.data.*;
import processing.serial.*;
import controlP5.*;

public class MainApp extends PApplet {
	// state constants
	final static int READY      = 0;
	final static int CONNECTED  = 1;
	final static int RECORDING  = 2;

	final static String MOTION_A = "locomotion_a";
	final static String MOTION_B = "locomotion_b";
	final static String CARDIO = "cardiovascular";
	final static String GSR = "nervous";
	final static String PULSE = "pulmonary";
	final static String STRETCH_A = "expansion_a";
	final static String STRETCH_B = "expansion_b";
	
	Serial myPort;
	ControlP5 cp5;
	Table table;
	
	// store data from Arduino
	SensorDataList motion_data_a_x;
	SensorDataList motion_data_a_y;
	SensorDataList motion_data_a_z;
	SensorDataList motion_data_b_x;
	SensorDataList motion_data_b_y;
	SensorDataList motion_data_b_z;
	SensorDataList cardio_data;
	SensorDataList gsr_data;
	SensorDataList pulse_data;
	SensorDataList stretch_data_a;
	SensorDataList stretch_data_b;
	
	// UI 
	Range accelerometer1Range;
	Range accelerometer2Range;
	Range cardioRange;
	Range gsrRange;
	Range pulseRange;
	Range stretchARange;
	Range stretchBRange;
	int dataColor;
	int gridColor;
	int previewResolution;

	int state = READY;
	
	public void setup() {
		  size(1280, 720);
		  frameRate(10);
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

		  motion_data_a_x = new SensorDataList(this, previewResolution, 512);
		  motion_data_a_y = new SensorDataList(this, previewResolution, 512);
		  motion_data_a_z = new SensorDataList(this, previewResolution, 512);

		  motion_data_b_x = new SensorDataList(this, previewResolution, 512);
		  motion_data_b_y = new SensorDataList(this, previewResolution, 512);
		  motion_data_b_z = new SensorDataList(this, previewResolution, 512);

		  cardio_data = new SensorDataList(this, previewResolution, 0);
		  pulse_data = new SensorDataList(this, previewResolution, 0);
		  gsr_data = new SensorDataList(this, previewResolution, 0);
		  stretch_data_a = new SensorDataList(this, previewResolution, 0);
		  stretch_data_b = new SensorDataList(this, previewResolution, 0);

		  dataColor = color(255, 0, 0);
		  gridColor = color(55);
		  
		  println(Serial.list()[9]);
		  myPort = new Serial(this, Serial.list()[9], 9600);
		  myPort.bufferUntil('\n');

		  stroke(255);
		  noFill();
		}

		public void draw() {
		  background(0);
		  noFill();
		  
		  // draw the divide lines first (underneath data lines)
		  stroke(gridColor);
		  for (int i = 1; i < 8; i++) {
		    line(0, i * 100, width, i * 100);
		  }

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

		  // draw the debugging data
		  text(MOTION_A + "\nmin: " + min(motion_data_a_x.getMin(), motion_data_a_y.getMin(), motion_data_a_z.getMin()) + " / max: " + max(motion_data_a_x.getMax(), motion_data_a_y.getMax(), motion_data_a_z.getMax()), 30, 30);
		  text(MOTION_B + "\nmin: " + min(motion_data_b_x.getMin(), motion_data_b_y.getMin(), motion_data_b_z.getMin()) + " / max: " + max(motion_data_b_x.getMax(), motion_data_b_y.getMax(), motion_data_b_z.getMax()), 30, 130);
		  text(CARDIO + "\nmin: " + cardio_data.getMin() + " / max: " + cardio_data.getMax(), 30, 230);
		  text(GSR + "\nmin: " + gsr_data.getMin() + " / max: " + gsr_data.getMax(), 30, 330);
		  text(PULSE + "\nmin: " + pulse_data.getMin() + " / max: " + pulse_data.getMax(), 30, 430);
		  text(STRETCH_A + "\nmin: " + stretch_data_a.getMin() + " / max: " + stretch_data_a.getMax(), 30, 530);
		  text(STRETCH_B + "\nmin: " + stretch_data_b.getMin() + " / max: " + stretch_data_b.getMax(), 30, 630);
		  text("SAVE SETTINGS = 'S' / LOAD SETTINGS = 'L' / RESET = 'R' / BEGIN RECORDING = 'B' / END RECORDING = 'E'", 30, height-5);

		  // GET MORE DATA?
		  if (state == CONNECTED || state == RECORDING) {
		    // send an 'a' for more bytes
		    myPort.write('a');
		  }
		}

		public void keyPressed() 
		{
		  if (key == 'S') 
		  {
		    cp5.saveProperties(("default_props"));
		  } 
		  else if (key == 'L') 
		  {
		    cp5.loadProperties(("default_props"));
		  }
		  else if (key == 'B' && state == CONNECTED)
		  {
		    state = RECORDING;
		    println("begin recording");
		  }
		  else if (key == 'E' && state == RECORDING)
		  {
		    state = CONNECTED;
		    saveTable(table, "data/new.csv");
		    println("end recording, " + table.getRowCount() + " rows");
		  }
		  else if (key == 'R') 
		  {
		    motion_data_a_x.reset();
		    motion_data_a_y.reset();
		    motion_data_a_z.reset();
		    motion_data_b_x.reset();
		    motion_data_b_y.reset();
		    motion_data_b_z.reset();
		    cardio_data.reset();
		    gsr_data.reset();
		    pulse_data.reset();
		    stretch_data_a.reset();
		    stretch_data_b.reset();
		  }
		}

		public void serialEvent( Serial _port ) 
		{
			String myString = _port.readString();
		  if (myString != null) 
		  {
		    myString = trim(myString);
		    if ( state == READY && myString.equals("OK") ) 
		    {
		      state = CONNECTED;
		      dataColor = color(0, 255, 0);
		    } 
		    else if (state == CONNECTED || state == RECORDING) {
		      // preview the data
		      String[] acc = splitTokens(myString, ",");
		      
		      if (acc.length == 11) 
		      {
		        // save temp RAW data
		        motion_data_a_x.add(Integer.parseInt(acc[0]));
		        motion_data_a_y.add(Integer.parseInt(acc[1]));
		        motion_data_a_z.add(Integer.parseInt(acc[2]));
		        motion_data_b_x.add(Integer.parseInt(acc[3]));
		        motion_data_b_y.add(Integer.parseInt(acc[4]));
		        motion_data_b_z.add(Integer.parseInt(acc[5]));
		        cardio_data.add(Integer.parseInt(acc[6]));
		        stretch_data_a.add(Integer.parseInt(acc[7]));
		        stretch_data_b.add(Integer.parseInt(acc[8]));
		        gsr_data.add(Integer.parseInt(acc[9]));
		        pulse_data.add(Integer.parseInt(acc[10]));

		        // record RAW data?
		        if (state == RECORDING) 
		        {
		          TableRow new_row = table.addRow();
		          new_row.setInt("id", table.lastRowIndex());
		          new_row.setInt(MOTION_A + "_x", Integer.parseInt(acc[0]));
		          new_row.setInt(MOTION_A + "_y", Integer.parseInt(acc[1]));
		          new_row.setInt(MOTION_A + "_z", Integer.parseInt(acc[2]));
		          new_row.setInt(MOTION_B + "_x", Integer.parseInt(acc[3]));
		          new_row.setInt(MOTION_B + "_y", Integer.parseInt(acc[4]));
		          new_row.setInt(MOTION_B + "_z", Integer.parseInt(acc[5]));
		          new_row.setInt(CARDIO, Integer.parseInt(acc[6]));
		          new_row.setInt(GSR, Integer.parseInt(acc[7]));
		          new_row.setInt(PULSE, Integer.parseInt(acc[8]));
		          new_row.setInt(STRETCH_A, Integer.parseInt(acc[9]));
		          new_row.setInt(STRETCH_B, Integer.parseInt(acc[10]));
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
		    vertex(i, constrain( map(motion_data_a_x.get(i), low, high, 0, 100), 0, 100) );
		  }
		  endShape();
		  stroke(dataColor, 155);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(motion_data_a_y.get(i), low, high, 0, 100), 0, 100) );
		  }
		  endShape();
		  stroke(dataColor, 55);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(motion_data_a_z.get(i), low, high, 0, 100), 0, 100) );
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
		    vertex(i, constrain( map(motion_data_b_x.get(i), low, high, 0, 100), 0, 100) );
		  }
		  endShape();
		  stroke(dataColor, 155);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(motion_data_b_y.get(i), low, high, 0, 100), 0, 100) );
		  }
		  endShape();
		  stroke(dataColor, 55);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(motion_data_b_z.get(i), low, high, 0, 100), 0, 100) );
		  }
		  endShape();
		}


		void drawCardio () {
		  float high = cardioRange.getHighValue();
		  float low = cardioRange.getLowValue();

		  stroke(dataColor);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(cardio_data.get(i), low, high, 50, 0), 0, 50) );
		  }
		  endShape();
		}

		void drawGSR () {
		  float high = gsrRange.getHighValue();
		  float low = gsrRange.getLowValue();

		  stroke(dataColor);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(gsr_data.get(i), low, high, 50, 0), 0, 50) );
		  }
		  endShape();
		}

		void drawPulse () {
		  float high = pulseRange.getHighValue();
		  float low = pulseRange.getLowValue();

		  stroke(dataColor);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(pulse_data.get(i), low, high, 50, 0), 0, 50) );
		  }
		  endShape();
		}

		void drawStretchA () {
		  float high = stretchARange.getHighValue();
		  float low = stretchARange.getLowValue();

		  stroke(dataColor);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(stretch_data_a.get(i), low, high, 50, 0), 0, 100) );
		  }
		  endShape();
		}

		void drawStretchB () {
		  float high = stretchBRange.getHighValue();
		  float low = stretchBRange.getLowValue();

		  stroke(dataColor);
		  beginShape(); 
		  for ( int i = 0; i < previewResolution-1; i++ ) {
		    vertex(i, constrain( map(stretch_data_b.get(i), low, high, 50, 0), 0, 100) );
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
}
