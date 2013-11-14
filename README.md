Body-movement-sensor-tests
==========================

Series of initial tests to get body data through Arduino into Processing. Including XBee, Bluetooth and serial communication between Arduino and Processing and pushed out to Spacebrew.cc

## Arduino
Includes all Arduino code to read sensor data and publish over a Serial connection. 
Most communication requires the Processing sketch to send a byte in order to receive
the next set of data. This avoids the Serial buffer being filled with masses of data.

## Datasheets
All the data sheets for electronic components used in the various BodyMovementSensor circuits.

## Fritzing
A simple diagram of each circuit so we can remember how to re-build the circuits.

## Hardware
Illustrator templates for laser-cutter elements. Such as small elements to fasten conductive rubber bands to velcro straps to be attached to any part of the body and measure extension and motion.

## Processing
A set of Processing sketches to read in sensor data and plot on a line graph. 
