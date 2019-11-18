import processing.serial.*;
Serial puerto;
String portName = Serial.list()[0];  //para determinar en que puerto estamos
int U1,U2,H1,H2; // estos son desde el mas signficativo del mayor hasta el menos significativo del menor
int[] info = new int[32];
int[] trama = new int[4]; 
char[] mask = new char[4];
int estado = 0; 
String input=""; 
char[] a = new char [16]; // vector informacion a transmitir por las torres
char modo;
int linea=200;           // variable para controlar posicion vertical del cursor al imprimir en pantalla

int muestras = 20;//para guardar muestreo

int posicion = 1;
int[] sonar = new int [muestras];
int[] lidar = new int [muestras];
int p = 0;
boolean f1, f2, f3, f4, ACTIVO;
int i = 0;

int[] U1V = new int[muestras];
int[] U2V = new int[muestras];
int[] H1V = new int[muestras];
int[] H2V = new int[muestras];


float[] y = new float[muestras];
int time=1;
float var_sonar=0,var_lidar=0;
float dfsonar = 0; //variable para la distancia del sonar
float[] dsonar = new float[muestras];
float dflidar = 0;  
float[] dlidar = new float[muestras];
float dffus = 0;
float[] dfus = new float[muestras];
float maxsonar, minsonar;
float maxlidar, minlidar;

int principal=0; //variable de conteo
int tempps=-1;
int temppl=-1;
int temppf=-1;
float aux=0; //variable auxiliar

String valores;
boolean comprobacion=false;
byte[] b = new byte [4]; // vector de prueba para enviar info al micro con trama oficial

void setup() { 
  size(800, 500);
  printArray(Serial.list());
  puerto = new Serial(this, Serial.list()[2], 115200); // en el servidor el puerto es el COM3 ubicado en el [2]
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
  //if(puerto.available() > 0){
   puerto.write(trama[0]);
   puerto.write(trama[1]);
   puerto.write(trama[2]);
   puerto.write(trama[3]);
   //puerto.write(135);
   //puerto.write(13);
   //puerto.write(2);
   //puerto.write(38);
  //}
  background(255); 
  
  if(estado==2 | estado==3){
  text ("Monitor serial IN     : " + binary(U1V[0],8) + " " + binary(U2V[0],8) + " " + binary(H1V[0],8) + " " +binary(H2V[0],8),150,25);
  text ("Monitor serial OUT : " + binary(b[0],8) + " " + binary(b[1],8) + " " + binary(b[2],8) + " " +binary(b[3],8),150,50);
  text ("Sonar : \t\t" + dfsonar,150,75);
  text ("Lidar : \t\t" + dflidar,150,100);
  text ("Fusion: \t\t" + dffus,150,125);
  text ("V_sonar: \t\t" + var_sonar,150,150);
  text ("V_lidar: \t\t" + var_lidar,150,175);
  text ("Estado : " + estado,150,200); 
  }
  
  switch (estado) {
  case 0:              // INICIO
    fill(0); 
    text ("Seleccione Modo, [S] Esclavo / [M] Maestro \n"+input, 150, 200); 
    break;

  case 1:             // MAESTRO
    fill(0); 
    text ("MODO MAESTRO \n", 150, 250); 
    fill(255, 2, 2); 
    text ("Ingrese info \n"+input, 150, 300);
    fill(0); 
    break;

  case 2:            // ENVIAR INFO AL MICRO Y CONFIRMAR RECEPCION
    fill(0); 
    text ("TRANSMITIENDO: " + input, 150, 300);
    for(int ci=0;ci<32;ci++){
      info[ci]=input.charAt(ci); // en este vector de 16 bytes se graba todo el mensaje de 16 digitos dependiendo de como se vaya a recibir el mensaje se dedeber reducir el array info para que sean menos bytes
  }
  
  //trama[0]=(info[0]-48)<<7;
  
 for(int ci=0;ci<32;ci++){
    if(ci == 0){
       trama[0] = (info[ci]-48); 
      }
      else if(0 < ci || ci < 8){
       trama[0] = trama[0] << 1 | (info[ci]-48); 
      }
      else if(ci == 8){
       trama[1] = (info[ci]-48); 
      }
      else if(8 < ci || ci < 16){
       trama[1] = (trama[1] << 1) | (info[ci]-48); 
      }
      else if(ci == 16){
       trama[2] = info[ci]; 
      }
      else if(16 < ci || ci < 24){
       trama[2] = (trama[2] << 1) | (info[ci]-48); 
      }
      else if(ci == 24){
       trama[3] = (info[ci]-48); 
      }
      else if(24 < ci || ci < 32){
       trama[3] = (trama[3] << 1) | (info[ci]-48); 
      }
        //print("trama 0 ");
        //println(trama[0]);
        //print("trama 1 ");
        //println(trama[1]);
        //print("trama 2 ");
        //println(trama[2]);
        //print("trama 3 ");
        //println(trama[3]);
  
  }
    //aqui se debe entramar la info en los primeros 4 espacios del vaector char o en un nuevo vector
    //y se deben enviar los 4 bytes
   
        
    delay(100); //<>//
    fill(255, 2, 2); 
    break;

  case 3: //esperar que llegue al cuadrante
  
  estado = 0;
    
  // if (llega al cuadrante) { estadi=40;} // esto se confirma por que el micro esta enviando informacion constante con su posicion
 
  break;
  
  case 40:  // CENTRAR
    
    // revisar si hay objeto
    // if(NO se detecta objeto) {incrementar variable posicion}
    // if(se detecta objeto) { M=0; estado=41 }
    
  break;
  
  case 41:

    // revisar si hay objeto
    // if(se detecta objeto) { incrementar variable de posicion, incrementar M}
    // if(NO se detecta objeto) { estado=42 }

  break;

  case 42:

    // decrementar variable de posicion M/2 veces (con esto se centrara en el objeto
    // estado = 5
  
  break;
  
  case 5:  // ACTIVAR COMUNICACION IR
     
    // hacer que el byte correspondiente tenga la info correspondiente de encender la transmision IR
    // if( se recibe info de que se encendio la transmision IR ) { estado = 6 }
        
  break;
    
  case 6:  // ESPERA EN ESTE ESTADO HASTA RECIBIR EL MENSAJE POR IR
           //Hacer un barrido de 3 pasos al rededor de la posicion de centrado que se obtubo para que se este enviando por IR en todo ese radio.
    
  break;
  
  case 7:  // AL RECIBIR MENSAJE LO MUESTRA EN PANTALLA Y ESPERA ENTER PARA REINICIAR EL PROGRAMA DEBE ESTAR MOSTRANDO EL MENSAJE CADA VEZ QUE SE CUMPLA EL LOOP HASTA QUE SE PRESIONE ENTER
    
  break;

  case 8:      // 
    fill(0); 
    text ("MODO ESCLAVO \n", 150, 300); 
    fill(255, 2, 2); 
    text ("PRESIONE CUALQUIER TECLA PARA CONTINUAR \n", 150, 400);
    break;    
  }
}

void keyPressed() {

  if (key==ENTER||key==RETURN) {
    switch(estado) {
    case 1:        // SI ESTOY EN MASTER (1) PASO A (2)
      estado=2;
      break;

    case 2:        // SI ESTOY EN MASTER (1) PASO A (2)
      estado=7;
      break;


    case 7:       // SE RECIBIO EL MENSAJE Y SE PUEDE PRESIONAR ENTER PARA REINICIAR EL PROGRAMA  
      estado=0;
      input="";
      break;
      
    }
  } else {

    switch(estado) {
    case 0:
      p=0;
      modo = key;
      if ( modo=='m' | modo=='M') {
        estado=1;
      } else {
        if (modo=='s' | modo=='S') {
          estado=3;
        }
      }
      break;

    case 1:
      input = input + (key-48); // guarda cada letra que se va tipeando en un string para imprimirlo despues
  }
  }
}

void serialEvent (Serial puerto) {

  char inBuffer;
  if(puerto.available()>0){
  inBuffer = puerto.readChar();
  if(i<muestras){
    
  if(p==0 && ((inBuffer & 128) == 0)){
    U1V[i] = inBuffer;
    p++;
  }
  
  else if(p==1){
    U2V[i] = inBuffer;
    p++;
  }
  
  else if(p==2){
    H1V[i] = inBuffer;
    p++;
  }
  
  else if(p==3){
    H2V[i] = inBuffer;
    p=0;
    i++;
  }
  
  }
  else{
    i=0;
    if(p==0 && ((inBuffer & 128) == 0)){
    U1V[i] = inBuffer;
    p++;
  }
  
  else if(p==1){
    U2V[i] = inBuffer;
    p++;
  }
  
  else if(p==2){
    H1V[i] = inBuffer;
    p++;
  }
  
  else if(p==3){
    H2V[i] = inBuffer;
    p=0;
    i++;
  }
  
  }

  }
  arreglar();
}


void arreglar(){  // desenmascarar la trama
  dflidar=0;
  dfsonar=0;
  for(int i=0;i<muestras;i++){ 
    int temp1 = U1V[i] & 126;
    posicion = temp1 >> 1;
    
    if(posicion==0){
      posicion=1;
    }
    
    if(posicion==63){
      posicion=62;
    }
    
    int temp2 = U1V[i] & 1; // nos quedamos con el ultimo byte, porque es parte del sonar
    int temp3 = temp2 << 9;    
    //temp3 es el primer bit del sonar
    int temp4 = U2V[i] & 127; // quitamos el primer bit del byte 2, y son los siguientes 7 bits del sonar
    int temp5 = temp4 << 2;    
    int temp6 = H1V[i] & 96; // 96 es 01100000, es para quedarnos con los 2 ultimos bits que quedan del sonar
    int temp7 = temp6 >> 5;    
    sonar[i] = (temp3 | temp5 | temp7); // hacemos un OR entre los tres bytes del sonar
   
    dsonar[i] = 0.517*sonar[i]+2.34; //CURVA SONAR 2
    
    if(dsonar[i]<10){dfsonar=10;}        // restringir a valores entre 10 y 300 cm
    if(dsonar[i]>400){dfsonar=300;}
    
    dfsonar+=dsonar[i];
    int temp8 = H1V[i] & 31;
    int temp9 = (temp8 << 7) & 3968; //3968 es 111110000000, es para quitar posible ruido
    int temp10 = H2V[i] & 127; // quitamos el primer bit del byte 4, y son los ultimos 7 bits del lidar
    lidar[i] = temp9 | temp10;
    
    dlidar[i] = 73.5*exp(-0.0011*lidar[i]); //DATOS SHARP
    
    if(dlidar[i]<10){dflidar=10;}
    if(dlidar[i]>400){dflidar=300;}
    
    dflidar+=dlidar[i];
  }
  dflidar/=muestras;
  dfsonar/=muestras;
  
  for(int i=0;i<muestras;i++){          // en este for se quitan los valores que esten por fuera del error permitido
    float error=0.15;                   // error en porcentaje permitido dividido entre 100
    if((dsonar[i]>dfsonar*(1+error))|(dsonar[i]<dfsonar*(1-error))){
      dsonar[i]=dfsonar;                // ahora el vector dsonar esta filtrado
    }
    if((dlidar[i]>dflidar*(1+error))|(dlidar[i]<dflidar*(1-error))){
      dlidar[i]=dflidar;                // ahora el vector dlidar está filtrado
    }
  }
  
  // Ahora que esta el vector filtrado calculamos la varianza y se debe volver a calcular el promedio
  
  var_sonar=0;
  var_lidar=0;
  dflidar=0;
  dfsonar=0; // varianza y promedio de los dos sensores
  dffus=0;
  
  for(int i=0;i<muestras;i++){ //calculo de promedio
    dfsonar+=dsonar[i];
    dflidar+=dlidar[i];
  }
  
  dflidar/=muestras;  //nuevos promedios listos
  dfsonar/=muestras;
  
  for(int i=0;i<muestras;i++){ //calculo de sumatoria para varianza
    var_sonar+=pow(dsonar[i]-dfsonar,2);
    var_lidar+=pow(dlidar[i]-dflidar,2);
  }
  var_sonar/=(muestras-1);    // varianzas calculadas
  var_lidar/=(muestras-1);
  
  // ahora le aplicamos la fusion al vector
  for(int i=0;i<muestras;i++){
    dfus[i]=( pow(var_sonar,-2) + pow(var_lidar,-2) ) * ( ( pow(var_sonar,-2) * dsonar[i] ) + ( pow(var_lidar,-2) * dlidar[i] ) );
    dffus+=dfus[i];
}
    dffus/=muestras; // promedio de la fusion
}
