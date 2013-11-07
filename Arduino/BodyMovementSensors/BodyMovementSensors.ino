#include <SPI.h>
#include <stdlib.h>
#include <stdio.h>

#define SCK 13 // Serial Clock -> SPC on LIS331
#define MISO 12 // MasterInSlaveOut -> SDO
#define MOSI 11 // MasterOutSlaveIn -> SDI
#define FLASH_BUTTON 8 // Pushbutton
#define ACCELEROMETER_B 4 // Serial Select -> CS on LIS331
#define ACCELEROMETER_A 2 // Serial Select -> CS on LIS331

#define STRETCH_SENSOR_A A0 // Pin for a stretch sensor
#define STRETCH_SENSOR_B A2 // Pin for a stretch sensor
#define FORCE_SENSOR A1 // Pin for force sensor around chest
#define GSR_SENSOR A3 // Pin for the galvanic skin response
#define PULSE_SENSOR A4 // Pin for the pulse sensor

const int numReadings = 20;
int index = 0;

// smooth the readings from the accelerometer
int values1X[numReadings];
int values1Y[numReadings];
int values1Z[numReadings];
int values2X[numReadings];
int values2Y[numReadings];
int values2Z[numReadings];

int total1X = 0;
int total1Y = 0;
int total1Z = 0;
int total2X = 0;
int total2Y = 0;
int total2Z = 0;

int average1X = 0;
int average1Y = 0;
int average1Z = 0;
int average2X = 0;
int average2Y = 0;
int average2Z = 0;

// global body movement values
int xAccA, yAccA, zAccA;
int xAccB, yAccB, zAccB;

int breathingForce;
int stretchForceA;
int stretchForceB;
int gsrValue;
int pulseValue;
int flashButtonValue;

void setup() {
  Serial.begin(9600);

  // initialize all the readings to 0
  for (int i = 0; i < numReadings; i++) {
    values1X[i] = 0;
    values1Y[i] = 0; 
    values1Z[i] = 0; 
    values2X[i] = 0; 
    values2Y[i] = 0; 
    values2Z[i] = 0; 
  }

  // Configure SPI
  spiSetup();

  // Configure accelerometer
  accelerometerSetup(ACCELEROMETER_A);
  accelerometerSetup(ACCELEROMETER_B);

  // Tell the world we are ready
  Serial.println("OK");
}


void loop() 
{
  // subtract the last reading:
  total1X = total1X - values1X[index];
  total1Y = total1Y - values1Y[index];
  total1Z = total1Z - values1Z[index];
  total2X = total2X - values2X[index];
  total2Y = total2Y - values2Y[index];
  total2Z = total2Z - values2Z[index];

  // Read the accelerometer data and put the values into global variables
  // the global variables are referenced using Pointers so we can
  // reuse the same function and logic and reduce the code required
  accelerometerRead(ACCELEROMETER_A, &xAccA, &yAccA, &zAccA);
  accelerometerRead(ACCELEROMETER_B, &xAccB, &yAccB, &zAccB);

  // read from the sensor
  values1X[index] = xAccA;
  values1Y[index] = yAccA;
  values1Z[index] = zAccA;
  values2X[index] = xAccB;
  values2Y[index] = yAccB;
  values2Z[index] = zAccB;

  // add the readings to the totals
  total1X = total1X + values1X[index];
  total1Y = total1Y + values1Y[index];
  total1Z = total1Z + values1Z[index];
  total2X = total2X + values2X[index];
  total2Y = total2Y + values2Y[index];
  total2Z = total2Z + values2Z[index];

  // advance to the next position in the array:  
  index = index + 1;

  // if we're at the end of the array...
  if (index >= numReadings) {
    // ...wrap around to the beginning: 
    index = 0;
  }

  // calculate the average:
  average1X = total1X / numReadings;
  average1Y = total1Y / numReadings;
  average1Z = total1Z / numReadings;
  average2X = total2X / numReadings;
  average2Y = total2Y / numReadings;
  average2Z = total2Z / numReadings;

  // Read the force sensor value for breathing
  breathingForce = analogRead(FORCE_SENSOR);

  // read the stretch sensor values for movement
  stretchForceA = analogRead(STRETCH_SENSOR_A);
  stretchForceB = analogRead(STRETCH_SENSOR_B);

  // read the galvanic skin response values
  gsrValue = analogRead(GSR_SENSOR);

  // Read the pulse sensor
  pulseValue = analogRead(PULSE_SENSOR);

  // Read the flash pushbutton
  flashButtonValue = digitalRead(FLASH_BUTTON);
  if (flashButtonValue == HIGH) {
    // set all the values to their maximum
    average1X = average1Y = average1Z = 5500;
    average2X = average2Y = average2Z = 5500;
    breathingForce = 1023;
    stretchForceA = stretchForceB = 1023;
    gsrValue = 1023;
    pulseValue = 1023;
  }
  
  delay(1); // delay in between reads for stability
}

void serialEvent() 
{
  // print out ALL sensor values
  byte inbyte = Serial.read();
  if(inbyte == 'a')
  {
    sendData();
  } 
}

void sendData() 
{
  // ACCELEROMETER A [x, y, z]
  // mapped the values from the sensor min/max = 5500 to 0-1023
  Serial.print(map(average1X, -5500, 5500, 0, 1023));
  Serial.print(",");
  Serial.print(map(average1Y, -5500, 5500, 0, 1023));
  Serial.print(",");
  Serial.print(map(average1Z, -5500, 5500, 0, 1023));
  Serial.print(",");
  // ACCELEROMETER B [x, y, z]
  Serial.print(map(average2X, -5500, 5500, 0, 1023));
  Serial.print(",");
  Serial.print(map(average2Y, -5500, 5500, 0, 1023));
  Serial.print(",");
  Serial.print(map(average2Z, -5500, 5500, 0, 1023));
  // BREATHING [n]
  Serial.print(",");
  Serial.print(breathingForce, 1);
  // STRETCH [a, b]
  Serial.print(",");
  Serial.print(stretchForceA, 1);
  Serial.print(",");
  Serial.print(stretchForceB, 1);
  // GALVANIC SKIN RESPONSE
  Serial.print(",");
  Serial.print(gsrValue, 1);
  // PULSE
  Serial.print(",");  
  Serial.println(pulseValue, 1);
}


