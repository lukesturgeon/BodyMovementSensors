Body-movement-sensor-tests
==========================

Series of initial tests to get body data through Arduino into Processing

# Arduino
Includes all Arduino code to read sensor data and publish over a Serial connection. 
Most communication requires the Processing sketch to send a byte in order to receive
the next set of data. This avoids the Serial buffer being filled with masses of data.

# Fritzing
A simple diagram of each circuit so we can remember how to re-build the circuits.

# Processing
A set of Processing sketches to read in sensor data and plot on a line graph.
