  
// Example by Tom Igoe

import processing.serial.*;
Serial myPort;
int i=0,j=0;

// The serial port:
void setup() {
// Open the port you are using at the rate you want:
printArray(Serial.list());
myPort = new Serial(this, Serial.list()[0], 115200);
}

void draw()
{

  
int[][] myArray = { {48,136,164,137}, 
                    {unbinary("00110000"),unbinary("10001000"),unbinary("10100100"),unbinary("100010001")}, 
                    {unbinary("00110010"),unbinary("10001000"),unbinary("10100100"),unbinary("10010111")}, 
                    {unbinary("00110100"),unbinary("10001000"),unbinary("10100100"),unbinary("10010001")}
                    {unbinary("00110110"),unbinary("10001000"),unbinary("10100100"),unbinary("100010001")}, 
                    {unbinary("00111000"),unbinary("10001000"),unbinary("10100100"),unbinary("10010111")}, 
                    {unbinary("00111010"),unbinary("10001000"),unbinary("10100111"),unbinary("10010001")}
                    {unbinary("00111100"),unbinary("10001000"),unbinary("10100100"),unbinary("100010001")}, 
                    {unbinary("00111110"),unbinary("10001000"),unbinary("10100100"),unbinary("10010111")}, 
                };   




myPort.write(myArray[i][0]);
myPort.write(myArray[i][1]);
myPort.write(myArray[i][2]);
myPort.write(myArray[i][3]);

i++;
if(i>3){
  i=0;
  delay(500);
}


}
