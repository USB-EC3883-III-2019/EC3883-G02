import processing.serial.*; // imports library for serial communication


String noObject;
float pixsDistance;
float iAngle = 1;
PFont orcFont;
float tempgraf=0;
float tempgraf2=0;
int k=0;

//variables del puerto
Serial puerto;
//descomentar
String portName = Serial.list()[0];  //para determinar en que puerto estamos
int U1,U2,H1,H2; // estos son desde el mas signficativo del mayor hasta el menos significativo del menor


int muestras = 10;//para guardar muestreo

int posicion;
int[] sonar = new int [muestras];
int[] lidar = new int [muestras];
int p = 0; //<>//
boolean f1, f2, f3, f4, ACTIVO;
int i = 0;


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
float dffus = 0;
float[] dfus = new float[muestras];
float maxsonar, minsonar;
float maxlidar, minlidar;

int principal=0; //variable de conteo

float aux=0; //variable auxiliar

String valores;
boolean comprobacion=false;


void setup() {

 size (930, 700); // ***CHANGE THIS TO YOUR SCREEN RESOLUTION***
 smooth();
 //descomentar
 puerto = new Serial(this, portName, 115200); //establecemos que la información en nuestro puerto se guardara en la variable puerto, y cuales serian los baudios
  printArray(Serial.list());
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
  noStroke();
  //fill(20,50);
  fill(20,15);
  
  rect(0, 0, width, height);

  fill(98,245,31); // green color
  // calls the functions for drawing the radar
  
  drawRadar();
  drawLine();
  drawText();
  
  if(f1){
    textSize(15);
    fill(98,245,60);
    text("ON",327,625);
    filtrar();
    drawSonar();
  }
  else if(f2){
    textSize(15);
    fill(98,245,60);
    text("ON",407,625);
    filtrar();
    drawLidar();
  }
  else if(f3){
    textSize(15);
    fill(98,245,60);
    text("ON",487,625);
    filtrar();
    drawFusion();
  }
  
}


void botnuevo(int x, int y, int ancho, int alto, String texto){//Funcion que crea botones rectangulares
  stroke(0);                                                         // Recibe coordenadas de punto superior izquierdo, ancho y alto, y el texto que recibe
  fill(230);
  rect(x,y,ancho, alto);
  fill(0);
  textSize(15);
  text(texto,x+10,y+20);
}

boolean boton (int xizq, int yizq, int ancho, int alto) { //Funcion que determina si se presiona sobre uno de los botones rectangulares
  if ((mouseX>=xizq) && (mouseX<=xizq+ancho) && (mouseY>=yizq) && (mouseY<=yizq+alto))
    {return true;
  }
  else {
  return false;
  }
}

void filtrar(){ // esta funcion se debe llamar siempre y solo filtrara cuando el flag f4 este activo
    
    if (f4){ 
     textSize(15);
     fill(98,245,60);
     text("ON",567,625);
     //println("Filtro : ACTIVO " + k);
     if(f1){
      if(k<muestras){
        tempgraf += dsonar[k];  
        k++;
      }
      else{
        dfsonar = tempgraf / muestras;
        //println(dfsonar);        
        k=0;
        tempgraf=0;
      }
     }
     else if(f2){
       if(k<muestras){
        tempgraf += dlidar[k];  
        k++;
      }
      else{
        dflidar = tempgraf / muestras;
        //println(dfgraf);        
        k=0;
        tempgraf=0;
      }
     }
     else if(f3){ //cuando la fusion esta activa, se sacan ambos promedios
      if(k<muestras){
        tempgraf += dsonar[k];  
        tempgraf2 += dlidar[k]; 
        k++;
      }
      else{
        dfsonar = tempgraf / muestras;
        dflidar = tempgraf2 / muestras;      
        k=0;
        tempgraf=0;
        tempgraf2=0;
      }
     }
    }
    else {
      //println("Filtro : NO ACTIVO");
      if(f1){
        dfsonar = dsonar[0];
      }
      else if(f2){
        dflidar = dlidar[0];
      }
      
    }
  }
  

  void mousePressed (){// Este evento se dispara si se presiona el mouse
  
  if (boton(310, 580, 60, 25)) { //Define las condiciones para la cual se activa cierto boton, estas son las coordenadas del boton filtrar
    if (!f1){                     // de aqui en adelante si el filtro estaba activo se desactiva y viceversa
      f1 = true; 
    }else {
      f1 = false;    
    }  
  }
  
  if (boton(390, 580, 60, 25)) { //Define las condiciones para la cual se activa cierto boton, estas son las coordenadas del boton filtrar
    if (!f2){                     // de aqui en adelante si el filtro estaba activo se desactiva y viceversa
      f2 = true;                  
    }else {
      f2 = false;                
    }  
  }
  
  if (boton(470, 580, 60, 25)) { //Define las condiciones para la cual se activa cierto boton, estas son las coordenadas del boton filtrar
    if (!f3){                     // de aqui en adelante si el filtro estaba activo se desactiva y viceversa
      f3 = true;                  
    }else {
      f3 = false;                
    }  
  }
  
  if (boton(550, 580, 60, 25)) { //Define las condiciones para la cual se activa cierto boton, estas son las coordenadas del boton filtrar
    if (!f4){                     // de aqui en adelante si el filtro estaba activo se desactiva y viceversa
      f4 = true;                  
    }else {
      f4 = false;                
    }  
  }
}

//descomentar
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


void arreglar(){  // desenmascarar la trama
  for(int i=0;i<muestras;i++){ 
    //int temp1 = U1V[i] & 126;   // en esta linea se quita el primer y el ultimo bit del byte 1, ya que 126 es 01111110
    int temp1 = U1V[i] & 126;
    posicion = temp1 >> 1;
    print("Posicion ");
    println(posicion);
    iAngle = map(posicion, 0, 63, 0, 220);
    int temp2 = U1V[i] & 1; // nos quedamos con el ultimo byte, porque es parte del sonar
    int temp3 = temp2 << 9;    
    //temp3 es el primer bit del sonar
    int temp4 = U2V[i] & 127; // quitamos el primer bit del byte 2, y son los siguientes 7 bits del sonar
    int temp5 = temp4 << 2;    
    int temp6 = H1V[i] & 96; // 96 es 01100000, es para quedarnos con los 2 ultimos bits que quedan del sonar
    int temp7 = temp6 >> 5;    
    sonar[i] = (temp3 | temp5 | temp7); // hacemos un OR entre los tres bytes del sonar
    
   // dsonar[i] = 0.136*sonar[i]+0.632; //CURVA SONAR
   
    dsonar[i] = 0.568*sonar[i]-1.69; //CURVA SONAR 2
    
    //print("Sonar ");
    //println(dsonar[i]);
    //int temp8 = H1V[i] & 31; // 31 es 00011111, es para quedaros con los ultimos 5 bits para el lidar
    int temp8 = H1V[i] & 31;
    int temp9 = (temp8 << 7) & 3968; //3968 es 111110000000, es para quitar posible ruido
    int temp10 = H2V[i] & 127; // quitamos el primer bit del byte 4, y son los ultimos 7 bits del lidar
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
  
  
  botnuevo(310, 580, 60, 25, "Sonar");
  botnuevo(390, 580, 60, 25, "Lidar");
  botnuevo(470, 580, 60, 25, "Fusión");
  botnuevo(550, 580, 60, 25, "Filtro"); //AQUI VA EL NUEVO BOTON, EL DE FILTRO
  
}

void drawLine() {
  
  pushMatrix();
  strokeWeight(6);
  stroke(30,250,60);
  translate(width/2,height-height*0.35); // moves the starting coordinats to new location
  line(0,0,(height-height*0.35)*cos(radians(iAngle) - radians(30)),-(height-height*0.35)*sin(radians(iAngle) - radians(30))); // draws the line according to the angle
  popMatrix();
 
}

void drawLidar(){
  pushMatrix();
  translate(width/2,height-height*0.35); // moves the starting coordinats to new location
  strokeWeight(6);
  stroke(255,10,10); // red color
  pixsDistance = map(dflidar, 0, 70, 0, width/2);
  if(dflidar<80){
  // draws the object according to the angle and the distance
    line(pixsDistance*cos(radians(iAngle) - radians(30)),-pixsDistance*sin(radians(iAngle) - radians(30)),(pixsDistance+10)*cos(radians(iAngle) - radians(30)),-(pixsDistance+10)*sin(radians(iAngle) - radians(30))); 
}
  popMatrix();
}

void drawSonar(){
  pushMatrix();
  translate(width/2,height-height*0.35); // moves the starting coordinats to new location
  strokeWeight(6);
  stroke(255,10,10); // red color
  pixsDistance = map(dfsonar, 0, 70, 0, width/2);
  
  //print("Sonar ");
  //println(dfsonar);
  
  if(dfsonar<80){
  // draws the object according to the angle and the distance
    line(pixsDistance*cos(radians(iAngle) - radians(30)),-pixsDistance*sin(radians(iAngle) - radians(30)),(pixsDistance+10)*cos(radians(iAngle) - radians(30)),-(pixsDistance+10)*sin(radians(iAngle) - radians(30))); 
}
  popMatrix();
}

void drawFusion(){
  maxsonar = max(dsonar);
  minsonar = min(dsonar);
  maxlidar = max(dlidar);
  minlidar = min(dlidar);
  if((maxlidar-minlidar) >= (maxsonar-minsonar)){
    pushMatrix();
    translate(width/2,height-height*0.35); // moves the starting coordinats to new location
    strokeWeight(6);
    stroke(255,10,10); // red color
    pixsDistance = map(dfsonar, 0, 70, 0, width/2);
    
    if(dfsonar<80){
    // draws the object according to the angle and the distance
      line(pixsDistance*cos(radians(iAngle) - radians(30)),-pixsDistance*sin(radians(iAngle) - radians(30)),(pixsDistance+10)*cos(radians(iAngle) - radians(30)),-(pixsDistance+10)*sin(radians(iAngle) - radians(30))); 
    }
    popMatrix();
  }
  
  else{
    pushMatrix();
    translate(width/2,height-height*0.35); // moves the starting coordinats to new location
    strokeWeight(6);
    stroke(255,10,10); // red color
    pixsDistance = map(dflidar, 0, 90, 0, width/2);
    
    if(dflidar<80){
    // draws the object according to the angle and the distance
      line(pixsDistance*cos(radians(iAngle) - radians(30)),-pixsDistance*sin(radians(iAngle) - radians(30)),(pixsDistance+10)*cos(radians(iAngle) - radians(30)),-(pixsDistance+10)*sin(radians(iAngle) - radians(30))); 
    }
    popMatrix();  
  }
  
}


void drawText() { // draws the texts on the screen

  pushMatrix();
  if(dfsonar>85) {
  noObject = "Out of Range";
  }
  else {
  noObject = "In Range";
  }
  
  textSize(15);
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
  resetMatrix();
  translate((width-width*0.152),(height-height*0.02));
  text("90cm",0,0);
  resetMatrix();
  translate((width-width*0.2),(height-height*0.05));
  text("80cm",0,0);
  resetMatrix();
  translate((width-width*0.24),(height-height*0.08));
  text("70cm",0,0);
  resetMatrix();
  translate((width-width*0.28),(height-height*0.115));
  text("60cm",0,0);
  resetMatrix();
  translate((width-width*0.32),(height-height*0.15));
  text("50cm",0,0);
  resetMatrix();
  translate((width-width*0.37),(height-height*0.183));
  text("40cm",0,0);
  resetMatrix();
  translate((width-width*0.42),(height-height*0.22));
  text("30cm",0,0);
  resetMatrix();
  translate((width-width*0.47),(height-height*0.26));
  text("20cm",0,0);
  resetMatrix();
  translate((width-width*0.52),(height-height*0.3));
  text("10cm",0,0);
  //resetMatrix();
  //translate((width-width*0.5),(height-height*0.305));
  //text("0",0,0);
  resetMatrix();
  popMatrix();
}
