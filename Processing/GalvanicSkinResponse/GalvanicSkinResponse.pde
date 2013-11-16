import controlP5.*;
import processing.serial.*;

String TIME_COLUMN = "time";
String DATA_COLUMN = "nervous";

Table table;
Serial bluetooth;
ControlP5 cp5;
Range preview_range;
int[] preview_data;
int time_now, time_last;
int start_recording;
boolean recording;

void setup() {
  size(400, 200);
  strokeWeight(2);

  // Create variables
  preview_data = new int[width];
  time_now = 0;
  time_last = 0;
  recording = false;

  // Create a table to record the data
  table = new Table();
  table.addColumn(TIME_COLUMN, Table.LONG);
  table.addColumn(DATA_COLUMN, Table.INT);

  // Create the UI control using ControlP5
  cp5 = new ControlP5(this);
  preview_range = cp5.addRange("preview")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
      .setPosition(10, 10)
        .setSize(100, 14)
          .setColorCaptionLabel(color(0))
            .setHandleSize(10)
              .setRange(0, 1023)
                .setRangeValues(0, 1023)
                  // after the initialization we turn broadcast back on again
                  .setBroadcast(true);

  // Print out a list of all available Serial ports
  println(Serial.list());

  // Connect to the Arduino via the Bluetooth serial port
  bluetooth = new Serial(this, Serial.list()[8], 9600);
  bluetooth.bufferUntil('\n');
}

void draw() 
{
  // clear the display
  background(255);

  float high = preview_range.getHighValue();
  float low = preview_range.getLowValue();

  // draw the preview data in the form of a line graph
  noFill();
  stroke(255, 0, 255);
  beginShape();
  for ( int i = 0; i < preview_data.length; i++ ) {    
    vertex( i, map(preview_data[i], low, high, 0, height));
  }
  endShape();

  // draw text on screen to debug (show us the current highest and lowest values)
  noStroke();
  fill(0);
  text("MIN VALUE: " + min(preview_data) + " / MAX VALUE: " + max(preview_data), 10, height-40);
  text("STATUS: " + ((recording) ? "RECORDING" : "READY"), 10, height-24);
  text("BEGIN RECORDING = 'B' / END RECORDING = 'E'", 10, height-8);

  // create a timer to record the data at a comfortable speed 
  // regardless of this sketch's frameRate. Bluetooth sometimes 
  // has latency problems and is slow.
  time_now = millis();
  if (time_now - time_last > 100) {
    // Send a byte to ask the Arduino to send more data  
    bluetooth.write('a');

    // update the timer to start counting again
    time_last = time_now;
  }
}

void serialEvent( Serial _port) 
{
  // Get the number from the Arduino, I use String so the full
  // value is received and the number isn't misinterpreted by Processing
  // somethings bytes (ie. '\n') will come through as an int.
  String s = _port.readStringUntil('\n');

  // Make sure the string contains real numbers
  if ( s != null ) 
  {
    // Convert the string to an int datatype
    // Make sure you trim() the string otherwise you may get the wrong value
    int n = Integer.parseInt(trim(s));

    // move all the values in the preview array down by 1
    for ( int i = 1; i < preview_data.length; i++ ) 
    {
      preview_data[i-1] = preview_data[i];
    }

    // add the new value to the end of the preview array
    preview_data[preview_data.length-1] = n;

    // check and record the data to the table
    if (recording == true) 
    {
      TableRow row = table.addRow();
      row.setLong(TIME_COLUMN, millis() - start_recording);
      row.setInt(DATA_COLUMN, n);
    }
  }
}

void keyPressed() 
{
  if (key == 'B' && recording == false) 
  {
    // change the flag so we start recording data in serialEvent()
    // new data is added to the Table as a single row
    recording = true;
    // remember when we started recording, to offset the time values in the data
    start_recording = millis();
    println("start recording");
  } 
  else if (key == 'E' && recording == true)
  {
    // change the flag so we STOP recording data in the serialEvent()
    recording = false;

    // get the current time and format so they're all 2 digits (ie. '1' == '01')
    String d = nf(day(), 2);
    String m = nf(month(), 2);
    String y = nf(year(), 2);
    String hr = nf(hour(), 2);
    String min = nf(minute(), 2);

    // Create a unique filename using the dates and times above
    String filename = y + m + d + "-" + hr + min;

    // and we save all the rows in the Table
    saveTable(table, "data/" + filename + ".csv");

    // output the result so we now how much data has been saved
    println("end recording, " + table.getRowCount() + " rows");

    // clear the table so we can record data again without restarting the sketch
    table.clearRows();
  }
}

