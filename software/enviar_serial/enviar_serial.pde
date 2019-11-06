
// Example by Tom Igoe

import processing.serial.*;

Serial puerto;
String portName = Serial.list()[0];  //para determinar en que puerto estamos
int U1, U2, H1, H2; // estos son desde el mas signficativo del mayor hasta el menos significativo del menor

int muestras = 100;//para guardar muestreo
int p = 0;
int[] U1V = new int[muestras];
int[] U2V = new int[muestras];
int[] H1V = new int[muestras];
int[] H2V = new int[muestras];

void setup() {
  puerto = new Serial(this, portName, 115200); //establecemos que la información en nuestro puerto se guardara en la variable puerto, y cuales serian los baudios
  printArray(Serial.list());
  puerto.buffer(1);  
  for (int pk=0; pk<muestras; pk++)
  {
    U1V[pk]=0;
    U2V[pk]=0;
    H1V[pk]=0;
    H2V[pk]=0;
  }
}

int i=0;
int b=0;

void draw()
{
  int a=9;
  puerto.write(a);
  byte[] inBuffer= new byte[4];
  while (puerto.available()>0) {
    inBuffer=puerto.readBytes();
    puerto.readBytes(inBuffer);
    if (inBuffer!=null) {
     int[] A = new int[4];
 
      println(A);
    }
  }
}
