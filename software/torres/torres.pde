import processing.serial.*;
Serial puerto;
String portName = Serial.list()[0];  //para determinar en que puerto estamos
int U1,U2,H1,H2; // estos son desde el mas signficativo del mayor hasta el menos significativo del menor

int estado = 0; 
String input=""; 
int[] a = new int [10]; // vector informacion a transmitir por las torres
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

void setup() { 
  size(800, 800);
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

  background(255); 
  
  if(estado==2 | estado==3){
  text ("Monitor serial : " + binary(U1V[0],4) + " " + binary(U2V[0],4) + " " + binary(H1V[0],4) + " " +binary(H2V[0],4),150,25);
  text ("Sonar : " + dfsonar,150,50);
  text ("Lidar : " + dflidar,150,75);
  text ("Fusion: " + dffus,150,100);
  text ("V_sonar: " + var_sonar,150,125);
  text ("V_lidar: " + var_lidar,150,150);
  }
  
  switch (estado) {
  case 0:
    fill(0); 
    text ("Seleccione Modo, [S] Esclavo / [M] Maestro \n"+input, 150, 200); 
    break;

  case 1:     // recibir info a transmitir
    fill(0); 
    text ("MODO MAESTRO \n", 150, 250); 
    fill(255, 2, 2); 
    text ("Ingrese info \n"+input, 150, 300);
    fill(0); 
    break;

  case 2:      // transmitir por serial hacia el micro
    fill(0); 
    text ("TRANSMITIENDO: " + input, 150, 300); 
    puerto.write(a[0]);
    delay(200);
    fill(255, 2, 2); 
    
    break;

  case 3:      // activar modo esclavo
    fill(0); 
    text ("MODO ESCLAVO \n"+input, 150, 300); 
    fill(255, 2, 2); 
    text ("PRESIONE CUALQUIER TECLA PARA CONTINUAR \n", 150, 400); 
    break;
  }
}

void keyPressed() {

  if (key==ENTER||key==RETURN) {
    switch(estado) {
    case 1:
      estado=2;
      break;

    case 2:    
      estado=0;
      input="";
      break;
      
    case 3:
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
      a[p]=key-48;              // guarda cada letra presionada en una posicion del vector y la convierte a numero 
      p++;          // incrementa la posicion del vector en la que se guardara el valor de la tecla pulsada
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
