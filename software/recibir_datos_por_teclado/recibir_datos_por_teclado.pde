import processing.serial.*;
Serial puerto;
String portName = Serial.list()[0];  //para determinar en que puerto estamos

int estado = 0; 
String input=""; 
int[] a = new int [10]; // vector informacion a transmitir por las torres
char modo;
int i=0;
int linea=200;           // variable para controlar posicion vertical del cursor al imprimir en pantalla

void setup() { 
  size(800, 800);
  printArray(Serial.list());
  puerto = new Serial(this, Serial.list()[2], 115200);
}



void draw() { 

  background(255); 

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
      i=0;
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
      a[i]=key-48;              // guarda cada letra presionada en una posicion del vector y la convierte a numero
      i++;          // incrementa la posicion del vector en la que se guardara el valor de la tecla pulsada
    }
  }
}
