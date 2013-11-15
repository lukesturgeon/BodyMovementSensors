
Table table;
int[] nervous_data;
int[] graph_data;
int time_now, time_prev;
int index;
color c1, c2;
int min_value;
int max_value;

void setup() {
  size(1280, 720);
  background(0);
  noFill();
  strokeWeight(2);

  // setup defaults
  c1 = color(10, 10, 10);
  c2 = color(255, 255, 255);
  time_prev = 0;
  index = 0;
  min_value = 20;
  max_value = 200;

  // get the table from the CSV file using BodyMovementSensor data
  table = loadTable("20131113-1127.csv", "header");
  println(table.getRowCount() + " total rows in table");

  // create a blank array the same length as the table rows
  nervous_data = new int[table.getRowCount()];
  graph_data = new int[width];

  // get just the nervous values from the dataset
  for (int i = 0; i < table.getRowCount(); i++) {
    nervous_data[i] = table.getInt(i, "nervous");
  }
}

void draw() {
  // create a timer so the reveal of the data
  // is at the same speed it was recorded 10fps!!!
  // regardless of this sketch's frameRate
  time_now = millis();
  if (time_now - time_prev > 128) {

    // clear the background
    background(0);

    // draw the values across the screen
    for (int i = 0; i < graph_data.length-1; i++) {
      float inter = map(i, 0, graph_data.length-1, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, map(graph_data[i], min_value, max_value, height/2, 0), i+1, map(graph_data[i+1], min_value, max_value, height/2, 0));
    }

    // shift all the data across by 1 position
    for ( int i = 1; i < graph_data.length; i++ ) {
      graph_data[i-1] = graph_data[i];
    }

    // update the graph content
    if (index < nervous_data.length) {
      // add new value to the end of the graph data
      graph_data[graph_data.length-1] = nervous_data[index];
      // increase the table index to start at the next data value
      index += 1;
    } else {
      // add a blank value to the end of the graph data
      graph_data[graph_data.length-1] = 0;
    }

    // reset the timer
    time_prev = time_now;
  }
}

