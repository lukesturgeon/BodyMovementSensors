/**
 * X3-axis Accelerometer sketch for testing
 * 
 * By: Luke Sturgeon
 * Email: hello@lukesturgeon.co.uk
 * Date: 15 November 2013
 * License: Public domain
 * 
 * Sparkfun Electronics Triple Axis Accelerometer Breakout - LIS331
 * 
 * Wiring:
 * UNO    LIS331
 * 
 * 3.3V   VCC
 * GND    GND
 * 10     CS 
 * 11     SDA/SDI
 * 12     SA0/SDO
 * 13     SCL/SPC
 */


#include <SPI.h>
#include <stdlib.h>
#include <stdio.h>

#define SS 3 // Serial Select -> CS on LIS331
#define MOSI 11 // MasterOutSlaveIn -> SDI
#define MISO 12 // MasterInSlaveOut -> SDO
#define SCK 13 // Serial Clock -> SPC on LIS331

#define SCALE 0.0007324; // approximate scale factor for full range (+/-24g)
// scale factor: +/-24g = 48G range. 2^16 bits. 48/65536 = 0.0007324

// global acceleration values
double xAcc, yAcc, zAcc;

void setup()
{
  Serial.begin(9600);

  // Configure SPI
  SPI_SETUP();

  // Configure accelerometer
  Accelerometer_Setup();
}


void loop()
{
  readVal(); // get acc values and put into global variables

  /*Serial.print(xAcc, 1);
   Serial.print(",");
   Serial.print(yAcc, 1);
   Serial.print(",");
   Serial.println(zAcc, 1);
   
   
   
   delay(10);*/

  if ( Serial.available() > 0 ) 
  {
    byte inbyte = Serial.read();
    if(inbyte == 'a'){
      Serial.print(xAcc, 1);
      Serial.print(",");
      Serial.print(yAcc, 1);
      Serial.print(",");
      Serial.println(zAcc, 1);
    } 
  }
}

// Read the accelerometer data and put values into global variables
void readVal()
{
  byte xAddressByteL = 0x28; // Low Byte of X value (the first data register)
  byte readBit = B10000000; // bit 0 (MSB) HIGH means read register
  byte incrementBit = B01000000; // bit 1 HIGH means keep incrementing registers
  // this allows us to keep reading the data registers by pushing an empty byte
  byte dataByte = xAddressByteL | readBit | incrementBit;
  byte b0 = 0x0; // an empty byte, to increment to subsequent registers

  digitalWrite(SS, LOW); // SS must be LOW to communicate
  delay(1);
  SPI.transfer(dataByte); // request a read, starting at X low byte
  byte xL = SPI.transfer(b0); // get the low byte of X data
  byte xH = SPI.transfer(b0); // get the high byte of X data
  byte yL = SPI.transfer(b0); // get the low byte of Y data
  byte yH = SPI.transfer(b0); // get the high byte of Y data
  byte zL = SPI.transfer(b0); // get the low byte of Z data
  byte zH = SPI.transfer(b0); // get the high byte of Z data
  delay(1);
  digitalWrite(SS, HIGH);

  // shift the high byte left 8 bits and merge the high and low
  int xVal = (xL | (xH << 8));
  int yVal = (yL | (yH << 8));
  int zVal = (zL | (zH << 8));

  // scale the values into G's
  xAcc = xVal * SCALE;
  yAcc = yVal * SCALE;
  zAcc = zVal * SCALE;

  //  xAcc = xVal / 1024;
  //  yAcc = yVal / 1024;
  //  zAcc = zVal / 1024;
}

void SPI_SETUP()
{
  pinMode(SS, OUTPUT);

  // wake up the SPI bus
  SPI.begin();

  // This device reads MSB first:
  SPI.setBitOrder(MSBFIRST);

  /*
  SPI.setDataMode()
   Mode    Clock Polarity (CPOL) Clock Phase (CPHA)
   SPI_MODE0    0    0
   SPI_MODE1    0    1
   SPI_MODE2    1    0
   SPI_MODE3    1    1
   */
  SPI.setDataMode(SPI_MODE0);

  /*
  SPI.setClockDivider()
   sets SPI clock to a fraction of the system clock
   Arduino UNO system clock = 16 MHz
   Mode SPI Clock
   SPI_CLOCK_DIV2 8 MHz
   SPI_CLOCK_DIV4 4 MHz
   SPI_CLOCK_DIV8 2 MHz
   SPI_CLOCK_DIV16 1 MHz
   SPI_CLOCK_DIV32 500 Hz
   SPI_CLOCK_DIV64 250 Hz
   SPI_CLOCK_DIV128 125 Hz
   */

  SPI.setClockDivider(SPI_CLOCK_DIV16); // SPI clock 1000Hz
}

void Accelerometer_Setup()
{
  // Set up the accelerometer
  // write to Control register 1: address 20h
  byte addressByte = 0x20;
  /* Bits:
   PM2 PM1 PM0 DR1 DR0 Zen Yen Xen
   PM2PM1PM0: Power mode (001 = Normal Mode)
   DR1DR0: Data rate (00=50Hz, 01=100Hz, 10=400Hz, 11=1000Hz)
   Zen, Yen, Xen: Z enable, Y enable, X enable
   */
  byte ctrlRegByte = 0x37; // 00111111 : normal mode, 1000Hz, xyz enabled

  // Send the data for Control Register 1
  digitalWrite(SS, LOW);
  delay(1);
  SPI.transfer(addressByte);
  SPI.transfer(ctrlRegByte);
  delay(1);
  digitalWrite(SS, HIGH);

  delay(100);

  // write to Control Register 2: address 21h
  addressByte = 0x21;
  // This register configures high pass filter
  ctrlRegByte = 0x00; // High pass filter off

  // Send the data for Control Register 2
  digitalWrite(SS, LOW);
  delay(1);
  SPI.transfer(addressByte);
  SPI.transfer(ctrlRegByte);
  delay(1);
  digitalWrite(SS, HIGH);

  delay(100);

  // Control Register 3 configures Interrupts
  // Since I'm not using Interrupts, I'll leave it alone

  // write to Control Register 4: address 23h
  addressByte = 0x23;
  /* Bits:
   BDU BLE FS1 FS0 STsign 0 ST SIM
   BDU: Block data update (0=continuous update)
   BLE: Big/little endian data (0=accel data LSB at LOW address)
   FS1FS0: Full-scale selection (00 = +/-6G, 01 = +/-12G, 11 = +/-24G)
   STsign: selft-test sign (default 0=plus)
   ST: self-test enable (default 0=disabled)
   SIM: SPI mode selection(default 0=4 wire interface, 1=3 wire interface)
   */
  ctrlRegByte = 0x30; // 00110000 : 24G (full scale)

  // Send the data for Control Register 4
  digitalWrite(SS, LOW);
  delay(1);
  SPI.transfer(addressByte);
  SPI.transfer(ctrlRegByte);
  delay(1);
  digitalWrite(SS, HIGH);
}



