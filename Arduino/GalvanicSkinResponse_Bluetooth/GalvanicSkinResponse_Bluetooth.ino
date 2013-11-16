/**
 * Bluetooth Serial passthrough sketch for GSR sensor
 * 
 * By: Luke Sturgeon
 * Email: hello@lukesturgeon.co.uk
 * Date: 15 November 2013
 * License: Public domain
 * 
 * This sketch creates a wireless emotional response sensor using
 * the Grove-GSR sensor from Seeed and BlueSMiRF Silver from Sparkfun
 * to monitor and broadcast Galvanic Skin Response values in real-time.
 * 
 * http://www.seeedstudio.com/wiki/Grove_-_GSR_Sensor
 * https://www.sparkfun.com/products/10269
 */

#include <SoftwareSerial.h>

#define SENSOR_PIN A0 // Input pin for the GSR sensor
#define BLUETOOTH_RX 9  // RX-I pin of bluetooth module
#define BLUETOOTH_TX 10  // TX-O pin of bluetooth module

// create a SoftwareSerial connection (this replaces typical USB Serial)
SoftwareSerial bluetooth(BLUETOOTH_TX, BLUETOOTH_RX);

// Store the current sensor value
int sensor_value = 0;

void setup() {  
  // The Bluetooth Mate defaults to 115200bps
  bluetooth.begin(115200);

  // Print three times individually to enter command mode
  bluetooth.print("$");  
  bluetooth.print("$");
  bluetooth.print("$");

  // Short delay, wait for the Mate to send back CMD
  delay(100);

  // 115200 can be too fast at times for SoftwareSerial to relay the data reliably
  // Temporarily Change the baudrate to 9600, no parity
  bluetooth.println("U,9600,N");

  // Restart bluetooth serial at 9600
  bluetooth.begin(9600);
  
  // Tell the world we are ready
  bluetooth.println("READY");
}

void loop() {
  // get the GSR value from the finger sensors
  sensor_value = analogRead(SENSOR_PIN);

  // If the bluetooth connection received any characters
  if(bluetooth.available()) {
    // Send any characters the bluetooth prints to the serial monitor
    char in_byte = bluetooth.read();
    if (in_byte == 'a') {
      // Broadcast the sensor data
      bluetooth.println(sensor_value);
    } 
  }

  // delay in between reads for stability
  delay(1);
}




















