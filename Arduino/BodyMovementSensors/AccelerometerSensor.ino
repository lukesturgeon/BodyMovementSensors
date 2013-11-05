void spiSetup() {
  // enable the Serial Select pins
  pinMode(ACCELEROMETER_A, OUTPUT);
  pinMode(ACCELEROMETER_B, OUTPUT);

  // wake up the SPI bus
  SPI.begin();
  SPI.setBitOrder(MSBFIRST);
  SPI.setDataMode(SPI_MODE0);
  SPI.setClockDivider(SPI_CLOCK_DIV16); // SPI clock 1000Hz
}

void accelerometerSetup(int _serialSelectPin) {
  // Set up the accelerometer
  // write to Control register 1: address 20h
  byte addressByte = 0x20;
  /* Bits:
   PM2 PM1 PM0 DR1 DR0 Zen Yen Xen
   PM2PM1PM0: Power mode (001 = Normal Mode)
   DR1DR0: Data rate (00=50Hz, 01=100Hz, 10=400Hz, 11=1000Hz)
   Zen, Yen, Xen: Z enable, Y enable, X enable
   */
  byte ctrlRegByte = 0x37; // 001 11 111 : normal mode, 1000Hz, xyz enabled

  // Send the data for Control Register 1
  digitalWrite(_serialSelectPin, LOW);
  delay(1);
  SPI.transfer(addressByte);
  SPI.transfer(ctrlRegByte);
  delay(1);
  digitalWrite(_serialSelectPin, HIGH);

  delay(100);

  // write to Control Register 2: address 21h
  addressByte = 0x21;
  // This register configures high pass filter
  ctrlRegByte = 0x00; // High pass filter off

  // Send the data for Control Register 2
  digitalWrite(_serialSelectPin, LOW);
  delay(1);
  SPI.transfer(addressByte);
  SPI.transfer(ctrlRegByte);
  delay(1);
  digitalWrite(_serialSelectPin, HIGH);

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
  digitalWrite(_serialSelectPin, LOW);
  delay(1);
  SPI.transfer(addressByte);
  SPI.transfer(ctrlRegByte);
  delay(1);
  digitalWrite(_serialSelectPin, HIGH);
}

void accelerometerRead(int _serialSelectPin, int *_xAcc, int *_yAcc, int *_zAcc) {
  byte xAddressByteL = 0x28; // Low Byte of X value (the first data register)
  byte readBit = B10000000; // bit 0 (MSB) HIGH means read register
  byte incrementBit = B01000000; // bit 1 HIGH means keep incrementing registers
  // this allows us to keep reading the data registers by pushing an empty byte
  byte dataByte = xAddressByteL | readBit | incrementBit;
  byte b0 = 0x0; // an empty byte, to increment to subsequent registers

  digitalWrite(_serialSelectPin, LOW); // SS must be LOW to communicate
  delay(1);
  SPI.transfer(dataByte); // request a read, starting at X low byte
  byte xL = SPI.transfer(b0); // get the low byte of X data
  byte xH = SPI.transfer(b0); // get the high byte of X data
  byte yL = SPI.transfer(b0); // get the low byte of Y data
  byte yH = SPI.transfer(b0); // get the high byte of Y data
  byte zL = SPI.transfer(b0); // get the low byte of Z data
  byte zH = SPI.transfer(b0); // get the high byte of Z data
  delay(1);
  digitalWrite(_serialSelectPin, HIGH);

  // shift the high byte left 8 bits and merge the high and low
  *_xAcc = (xL | (xH << 8));
  *_yAcc = (yL | (yH << 8));
  *_zAcc = (zL | (zH << 8));


  /*int xVal = (xL | (xH << 8));
   int yVal = (yL | (yH << 8));
   int zVal = (zL | (zH << 8));
   
   // scale the values into G's
   *_xAcc = xVal * SCALE;
   *_yAcc = yVal * SCALE;
   *_zAcc = zVal * SCALE;*/


}

