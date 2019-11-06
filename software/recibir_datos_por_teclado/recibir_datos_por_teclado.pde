int estado = 0; 
String input=""; 

void setup() { 
  size(800, 800);
}
 
void draw() { 
 
 
  background(255); 
 
 
  switch (estado) {
  case 0:
    fill(0); 
    text ("Ingrese info para torres \n"+input, 133, 333); 
    break;
 
  case 1:
    fill(0); 
    text ("Ingrese info para torres \n"+input, 133, 333); 
    fill(255, 2, 2); 
    text ("Se recibió \n"+input, 133, 383); 
    break;

  case 2:
    fill(0); 
    text ("Ingrese info para torres \n"+input, 133, 333); 
    fill(255, 2, 2); 
    text ("Se recibió \n"+input, 133, 383); 
    fill(0); 
    text ("PRESIONE CUALQUIER TECLA PARA CONTINUAR \n", 133, 433); 
    break;
}
}
 
void keyPressed() {
 
  if (key==ENTER||key==RETURN) {
 
    estado++;
    if(estado>2)
    {
     background(255);      
     estado=0;
     input="";     
    }
  } else
  input = input + key;
}
