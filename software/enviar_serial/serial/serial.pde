// Example by Tom Igoe

import processing.serial.*;

// The serial port:
Serial myPort;

void setup()
{
// List all the available serial ports:
printArray(Serial.list());

// Open the port you are using at the rate you want:
myPort = new Serial(this, Serial.list()[1], 115200);
}
// Send a capital "A" out the serial port

void draw()
{
myPort.write(65);
}
