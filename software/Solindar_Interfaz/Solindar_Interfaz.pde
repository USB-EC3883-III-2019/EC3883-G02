import processing.serial.*; // imports library for serial communication
//import java.awt.event.KeyEvent; // imports library for reading the data from the serial port
//import java.io.IOException;
import interfascia.*;

GUIController c;
IFButton sn, ld, fs, fl, refresh;
IFLabel l;

// defubes variables
String angle="";
String distance="";
String data="";
String noObject;
float pixsDistance;
float iAngle = 1;
int iDistance;
int index1=0;
int index2=0;
PFont orcFont;

//variables del puerto
Serial puerto;
String portName = Serial.list()[0];  //para determinar en que puerto estamos
int U1,U2,H1,H2; // estos son desde el mas signficativo del mayor hasta el menos significativo del menor
//float i=0; // solo una variable para ir imprimiendo y saber por que numero de lecutra va
//int iAngle2 = 0; //valor pasado


int muestras = 2;//para guardar muestreo

int posicion;
//int sonar;
int[] sonar = new int [muestras];
//int lidar;
int[] lidar = new int [muestras];
int motor = 1;
int p = 0;
int f1=0, f2=0, f3=0, f4=0;
int i = 0; //<>//


int[] cha1V = new int[muestras]; //vectores para los canales
int[] cha2V = new int[muestras];
int[] chd1V = new int[muestras];
int[] chd2V = new int[muestras];

int[] U1V = new int[muestras];
int[] U2V = new int[muestras];
int[] H1V = new int[muestras];
int[] H2V = new int[muestras];


float[] y = new float[muestras];
int time=1;

float dfsonar = 0; //variable para la distancia del sonar
float[] dsonar = new float[muestras];
float dflidar = 0;
float[] dlidar = new float[muestras];

int principal=0; //variable de conteo

float aux=0; //variable auxiliar

String valores;
boolean comprobacion=false;


void setup() {

 size (930, 700); // ***CHANGE THIS TO YOUR SCREEN RESOLUTION***
 smooth();
 puerto = new Serial(this, portName, 115200); //establecemos que la información en nuestro puerto se guardara en la variable puerto, y cuales serian los baudios
  
  c = new GUIController (this);
  
  sn = new IFButton ("Sonar", 310, 580, 60, 17);
  ld = new IFButton ("Lidar", 390, 580, 60, 17);
  fs = new IFButton ("Fusión", 470, 580, 60, 17);
  fl = new IFButton ("Filtro", 550, 580, 60, 17);

  sn.addActionListener(this);
  ld.addActionListener(this);
  fs.addActionListener(this);
  fl.addActionListener(this);

  c.add (sn);
  c.add (ld);
  c.add (fs);
  c.add (fl);
  
  puerto.buffer(1);  
  for(int pk=0;pk<muestras;pk++)
  {
      U1V[pk]=0;
      U2V[pk]=0;
      H1V[pk]=0;
      H2V[pk]=0; 
  } 
 
 }
 
void draw() {
  

  fill(98,245,31);
  // simulating motion blur and slow fade of the moving line
  //noStroke();
  //fill(20,50);
  fill(20,15);
  
  rect(0, 0, width, height);

  fill(98,245,31); // green color
  // calls the functions for drawing the radar
  drawRadar();
  drawLine();
  drawObject();
  drawText();
  //translate(width/2,height-height*0.35); // moves the starting coordinats to new location
  //line(0,0,10,10);
  
}

void serialEvent (Serial puerto) {

  char inBuffer;
  inBuffer = puerto.readChar();
  
  if(i<muestras){
    
    
    
  if(p==0 && ((inBuffer & 128) == 0)){
    U1V[i] = inBuffer;
    p++;
    //print("U1 = ");
    //println(binary(U1V[i]));
  }
  
  else if(p==1){
    U2V[i] = inBuffer;
    p++;
    //print("U2 = ");
    //println(binary(U2V[i]));
  }
  
  else if(p==2){
    H1V[i] = inBuffer;
    p++;
    //print("H1 = ");
    //println(binary(H1V[i]));
  }
  
  else if(p==3){
    H2V[i] = inBuffer;
    p=0;
    //print("H2 = ");
    //println(binary(H2V[i]));
    i++;
  }
  
  }
  else{
    i=0;
    if(p==0 && ((inBuffer & 128) == 0)){
    U1V[i] = inBuffer;
    p++;
    //print("U1 = ");
    //println(binary(U1V[i]));
  }
  
  else if(p==1){
    U2V[i] = inBuffer;
    p++;
    //print("U2 = ");
    //println(binary(U2V[i]));
  }
  
  else if(p==2){
    H1V[i] = inBuffer;
    p++;
    //print("H1 = ");
    //println(binary(H1V[i]));
  }
  
  else if(p==3){
    H2V[i] = inBuffer;
    p=0;
    //print("H2 = ");
    //println(binary(H2V[i]));
    i++;
  }
  
  }
  
  arreglar();
}

//esta parte es para asigar que hara cada boton
void actionPerformed (GUIEvent e){
  if (e.getSource() == sn){
    if(f1 == 0){
      background(50, 155, 50);
      f1 = 1;
    }
    else if(f1 == 1){
      background(100, 155, 100);
      f1 = 0;
    }
  } 
  
  else if (e.getSource() == ld){
    if(f2 == 0){
      background(100, 100, 130);
      f2 = 1;
    }
    else if(f2 == 1){
      background(100, 155, 100);
      f2 = 0;
    }
    
  }
  
  else if (e.getSource() == fs){
    if(f3 == 0){
      background(100, 200, 130);
      f3 = 1;
      for (i=0;i<muestras; i++){
      dfsonar = dfsonar + dsonar[i];
      }
      dfsonar = dfsonar / muestras;
    }
    else if(f3 == 1){
      background(255, 255, 255);
      f3 = 0;
      dfsonar = dsonar[0];
    }
    
  } 
  
  else if (e.getSource() == fl){
    if(f4 == 0){
      background(100, 250, 100);
      f4 = 1;
    }
    else if(f4 == 1){
      background(100, 155, 100);
      f4 = 0;
    }
    
  }
}


void arreglar(){  // desenmascarar la trama
  for(int i=0;i<muestras;i++){ 
    //int temp1 = U1V[i] & 126;   // en esta linea se quita el primer y el ultimo bit del byte 1, ya que 126 es 01111110
    int temp1 = U1V[i] & 126;
    posicion = temp1 >> 1;
    //print("Posicion ");
    //println(posicion);
    iAngle = map(posicion, 0, 63, 0, 220);
    //int temp2 = U1V[i] & 1; // nos quedamos con el ultimo byte, porque es parte del sonar
    int temp2 = U1V[i] & 1;
    int temp3 = temp2 << 9;    
    //temp3 es el primer bit del sonar
    //int temp4 = U2V[i] & 127; // quitamos el primer bit del byte 2, y son los siguientes 7 bits del sonar
    int temp4 = U2V[i] & 127;
    int temp5 = temp4 << 2;    
    //int temp6 = H1V[i] & 96; // 96 es 01100000, es para quedarnos con los 2 ultimos bits que quedan del sonar
    int temp6 = H1V[i] & 96;
    int temp7 = temp6 >> 5;    
    sonar[i] = (temp3 | temp5 | temp7); // hacemos un OR entre los tres bytes del sonar
    
   // dsonar[i] = 0.136*sonar[i]+0.632; //CURVA SONAR
   
    dsonar[i] = 0.568*sonar[i]-1.69; //CURVA SONAR 2
    
    print("Sonar ");
    println(dsonar[i]);
    //int temp8 = H1V[i] & 31; // 31 es 00011111, es para quedaros con los ultimos 5 bits para el lidar
    int temp8 = H1V[i] & 31;
    int temp9 = (temp8 << 7) & 3968; //3968 es 111110000000, es para quitar posible ruido
    //int temp10 = H2V[i] & 127; // quitamos el primer bit del byte 4, y son los ultimos 7 bits del lidar
    int temp10 = H2V[i] & 127;
    lidar[i] = temp9 | temp10;
    
    dlidar[i] = 158*exp(-0.00201*lidar[i]); //DATOS SHARP
    //dlidar[i] = 161*exp(-0.00206*lidar[i]);    
    
    
    
    //print("Lidar ");
    //println(dlidar[i]);

    
  }
}



void drawRadar() {
  pushMatrix();
  translate(width/2,height-height*0.35); // moves the starting coordinats to new location
  noFill();
  strokeWeight(1);
  stroke(98,245,31);
  // draws the arc lines
  arc(0,0,(width-width*0.0625),(width-width*0.0625),5*PI/6,13*PI/6);
  arc(0,0,(width-width*0.167),(width-width*0.167),5*PI/6,13*PI/6);
  arc(0,0,(width-width*0.27),(width-width*0.27),5*PI/6,13*PI/6);
  arc(0,0,(width-width*0.374),(width-width*0.374),5*PI/6,13*PI/6);
  arc(0,0,(width-width*0.479),(width-width*0.479),5*PI/6,13*PI/6);
  arc(0,0,(width-width*0.583),(width-width*0.583),5*PI/6,13*PI/6);
  arc(0,0,(width-width*0.687),(width-width*0.687),5*PI/6,13*PI/6);
  arc(0,0,(width-width*0.791),(width-width*0.791),5*PI/6,13*PI/6);
  arc(0,0,(width-width*0.895),(width-width*0.895),5*PI/6,13*PI/6);
  // draws the angle lines
  line(-width/2,0,width/2,0);
  line(0,0,(-width/2)*cos(radians(-30)),(-width/2)*sin(radians(-30)));
  line(0,0,(-width/2)*cos(radians(30)),(-width/2)*sin(radians(30)));
  line(0,0,(-width/2)*cos(radians(60)),(-width/2)*sin(radians(60)));
  line(0,0,(-width/2)*cos(radians(90)),(-width/2)*sin(radians(90)));
  line(0,0,(-width/2)*cos(radians(120)),(-width/2)*sin(radians(120)));
  line(0,0,(-width/2)*cos(radians(150)),(-width/2)*sin(radians(150)));
  line(0,0,(-width/2)*cos(radians(210)),(-width/2)*sin(radians(210)));
  line((-width/2)*cos(radians(30)),0,width/2,0);
  popMatrix();
  stroke(10);
}

void drawLine() {

  //iAngle = map(motor, 0, 63, 0, 240);
  // if(motor == aux + 1 || motor == aux + 2 ){
  //  //println("primera cond");
  //  if(motor < 63){
  //    aux = motor;
  //    motor = motor + 1;
  //    //println("segunda cond");
  //  } 
  //  else if (motor == 63){
  //    aux = motor;
  //   motor = motor - 2;
  //   //println("tercera cond");
  //  }
  //}
  //if(motor == aux - 2 || motor == aux - 1){
  //  //println("cuarta cond");
  //  if(motor > 0){
  //    //println("quinta cond");
  //    aux = motor;
  //    motor = motor - 1;;
  //  } 
  //  else if (motor == 0){
  //    aux = motor;
  //    motor = motor + 2;
  //    //println("sexta cond");
  //  }
  //}
  pushMatrix();
  strokeWeight(6);
  stroke(30,250,60);
  translate(width/2,height-height*0.35); // moves the starting coordinats to new location
  line(0,0,(height-height*0.35)*cos(radians(iAngle) - radians(30)),-(height-height*0.35)*sin(radians(iAngle) - radians(30))); // draws the line according to the angle
  popMatrix();
 
}

void drawObject() {
  pushMatrix();
  translate(width/2,height-height*0.35); // moves the starting coordinats to new location
  strokeWeight(6);
  stroke(255,10,10); // red color
  //pixsDistance = map(dfsonar, 0, 70, 0, width/2);
  pixsDistance = map(dsonar[0], 0, 70, 0, width/2);
  //print("pixsDistance = ");
  //println(pixsDistance);
  // limiting the range to 40 cms
  //print("Sonar ");
  //println(dfsonar);
  if(dfsonar<80){
  // draws the object according to the angle and the distance
  //line(pixsDistance*cos(radians(iAngle) - radians(30)),-pixsDistance*sin(radians(iAngle) - radians(30)),(width-width*0.505)*cos(radians(iAngle) - radians(30)),-(width-width*0.505)*sin(radians(iAngle) - radians(30)));
  line(pixsDistance*cos(radians(iAngle) - radians(30)),-pixsDistance*sin(radians(iAngle) - radians(30)),(pixsDistance+10)*cos(radians(iAngle) - radians(30)),-(pixsDistance+10)*sin(radians(iAngle) - radians(30))); 
}
  popMatrix();
}

void drawText() { // draws the texts on the screen

  pushMatrix();
  if(dfsonar>80) {
  noObject = "Out of Range";
  }
  else {
  noObject = "In Range";
  }
  
  textSize(18);
  fill(98,245,60);
  translate((width-width*0.07),(height-height*0.08));
  rotate(radians(118));
  text("0°",0,0);
  resetMatrix();
  translate((width-width*0.02),(height-height*0.4));
  rotate(radians(90));
  text("30°",0,0);
  resetMatrix();
  translate((width-width*0.105),(height-height*0.71));
  rotate(-radians(-59));
  text("60°",0,0);
  resetMatrix();
  translate((width-width*0.3),(height-height*0.93));
  rotate(-radians(-27));
  text("90°",0,0);
  resetMatrix();
  translate((width-width*0.55),(height-height*0.98));
  rotate(radians(0));
  text("120°",0,0);
  resetMatrix();
  translate((width-width*0.73),(height-height*0.909));
  rotate(radians(-29));
  text("150°",0,0);
  resetMatrix();
  translate((width-width*0.91),(height-height*0.68));
  rotate(radians(-58));
  text("180°",0,0);
  resetMatrix();
  translate((width-width*0.98),(height-height*0.36));
  rotate(radians(-90));
  text("210°",0,0);
  resetMatrix();
  translate((width-width*0.93),(height-height*0.06));
  rotate(radians(-118));
  text("240°",0,0);
  popMatrix();
}
