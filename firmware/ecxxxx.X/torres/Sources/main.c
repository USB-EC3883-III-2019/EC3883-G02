/* ###################################################################
**     Filename    : main.c
**     Project     : oscilocopio
**     Processor   : MC9S08QE128CLK
**     Version     : Driver 01.12
**     Compiler    : CodeWarrior HCS08 C Compiler
**     Date/Time   : 2019-02-25, 10:53, # CodeGen: 0
**     Abstract    :
**         Main module.
**         This module contains user's application code.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file main.c
** @version 01.12
** @brief
**         Main module.
**         This module contains user's application code.
*/         
/*!
**  @addtogroup main_module main module documentation
**  @{
*/         
/* MODULE main */


/* Including needed modules to compile this module/procedure */
#include "Cpu.h"
#include "Events.h"
#include "AS1.h"
#include "Byte1.h"
#include "Bit1.h"
#include "TI1.h"
#include "PWM1.h"
#include "Cap1.h"
#include "AD1.h"
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/* User includes (#include below this line is not maintained by Processor Expert) */
/*	INFO GENERAL
 * 
 * 	PIN NOMBRE	DESCRIPCION 	VARIABLE	I/O		NOTAS
 * 	-----------------------------------------------------------------------
 *  1	VDD	   	+3V							O		SALIDA DE VOLTAGE POSITIVO DEMOQE	
 *  3	VSS	   	0							O		TIERRA DEL DEMOQE 
 *  13	PTC0	MOTOR 1 (VERDE)				O		BOBINA MOTOR
 *  15	PTC1	MOTOR 2	(ROJO)				O		BOBINA MOTOR
 *  33	PTC2	MOTOR 3	(GRIS1)				O		BOBINA MOTOR
 *  35	PTC3	MOTOR 4	(GRIS2)				O		BOBINA MOTOR
 *  27	PTD2	ZERO IZQ					I		SENSOR PARA DETECTAR MAXIMO IZQUIERDA
 *  			ZERO DER					I		SENSOR PARA DETECTAR MAXIMO DERECHA
 *  31	PTD3	FILTRO						I		BOTON PARA ACTIVAR O DESACTIVAR FILTRO
 *  23	PTB5	SONAR			Cap1		I		COMPONENTE DE CAPTURA PARA DETECTAR CAMBIO EN EL PIN ECHO DEL ULTRASONIDO
 *  24	PTA7	TRIGGER			PWM1		O		PIN PARA ACTIVAR LA RAFAGA ACUSTICA DE MEDICION, SE HACE MEDIANTE UNA ONDA CUADRADA QUE SE GENERA CADA 15ms
 *  14	PTA0	LIDAR						I		SENSOR SHARP
 *  16	PTA1	POTENCIOMETRO				I		TENTATIVO CONECTAR POTENCIOMETRO PARA OBTENER POSICION
 */

unsigned char a=1,b=0;
unsigned int p=0;
char posicion=0;	// posicion del motor, esta variable es global dado que se utiliza en varias funciones y requiere estar actualizada en todo momento
char cuadrante=1;    ////cuadrante al cual se quiere mover
char cuadrante_a=1;  //variable de control para verificar que se va a cambiar a un cuadrante nuevo
int control=0;
unsigned int time;   // variable para guardar el tiempo del sonar
char lidar[2];

//funcion mueve el motor hasta el inicio (grado menor) del cuadrante enviado
//retorna 0 si no ha llegado la posicion
//retorna 1 si lleg� a la posicion


void mover_cuadrante()
{	
	char pasos=63; 	// pasos totales de barrido de la torre
	char div=5;		// cantidad de cuadrantes
	char secuencia[8]={0b00110100,0b00110110,0b00110010,0b00111010,0b00111000,0b00111001,0b00110001,0b00110101};
	char objetivo=(pasos/div)*(cuadrante-1);
	
	if((cuadrante_a!=cuadrante)&(cuadrante>=1 & cuadrante<=6)){
	   if(posicion>objetivo)
		   {
			   posicion--;
		   }
		   
		   if(posicion<objetivo)
		   {
			   posicion++;
		   }
		   if(posicion==objetivo){
			  cuadrante_a=cuadrante;
			/*  if(control%10==0){ 
			  Bit1_NegVal();
			  }
			  control++;
			  if(control>50){
				  control=0;
			  }*/
		  }
	}
			Byte1_PutVal(secuencia[posicion%8]);			     
}

void paso(){ // esta funcion se ampliara mas adelante para que el motor de determinados pasos. Argumentos : [pasos,direccion]
	char secuencia[8]={0b00110100,0b00110110,0b00110010,0b00111010,0b00111000,0b00111001,0b00110001,0b00110101};
	Byte1_PutVal(secuencia[posicion%8]);			  	
}

void leer_lidar(){
		AD1_MeasureChan(TRUE,1); // Lee el lidar conectado al canal 1
		AD1_GetChanValue(1, &lidar); // se asigna el valor leido a la variable lidar
	}


unsigned int leer_sonar(){
	unsigned int t2;
	t2=time/58;
	return t2;
}

void solindar(char fusion[],unsigned int tsonar, char lidar[]){
	
}

void enviar(char maskblock[4],unsigned int sonar2,char lidar[],char posicion) // OPERATIVO Y PROBADO
{
	   /* Las variables son:
	    * maskblock hace referencia a los 4 bytes completos que env�a el demoQE, ser�a la trama seg�n el protocolo
	    * sonar cuenta con 2 bytes del sonar
	    * lidar son los 2 bytes del canal 2
	    */
		
		/* funcionamiento:
		 * Se enviara una trama teniendo en cuenta la cabezera de la trama 
		 * los la trama de prueba sera 00000001 10000011 10000111 10001111
		 */
		unsigned int ptr;
		unsigned int ptr2;
		char temp2[2];
			
		posicion=posicion & 0b00111111;
		temp2[0]=sonar2;
		temp2[1]=(temp2[1]>>5) | (temp2[0]<< 3);
		temp2[0]=(temp2[0] & 0b01111111) >> 5;
		maskblock[0]= (posicion<<1) ;//& 0b01111110; 		// posicion garantizando la cabecera 00	
		maskblock[0]= maskblock[0] | ((temp2[0] & 0b00000011) >> 1);
		maskblock[1]= (temp2[0] & 0b00000001) << 6;					// desplaza el bit hasta la posicion en la que inicia
		maskblock[1]= maskblock[1] | (temp2[1] >> 2);	// 
		maskblock[1]= maskblock[1] | 0b10000000;		
		maskblock[2]= (temp2[1] & 0b00000011) << 5 ;		
		lidar[0]	= lidar[0] & 0b00001111;
		maskblock[2]= maskblock[2] | (lidar[0]<< 1);
		maskblock[2]= maskblock[2] | (lidar[1] >> 7);
		maskblock[2]= maskblock[2] | 0b10000000;
		maskblock[3]= lidar[1] & 0b01111111;
		maskblock[3]= maskblock[3] | 0b10000000;
		AS1_SendBlock(maskblock,4,&ptr); // enviamos el entramado (hay que adaptarlo al nuevo poryecto)		   	   

}		

void main(void)
{
  /* Write your local variable definition here */
char ready=0,init=0; // un retardo antes de iniciar el programa que depende una comparacion con la variable init y el tiempo que se desea
unsigned int t2;	// variable para tiempo del sonar
char maskblock[4]; // vector entramado que se enviara al processing

/*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
   
   for(;;) {

	if((p==1) & (init<10)){ // espera inicial para inicar el programa
	p=0;
	init++;
	}
	if(init==10){
		ready=1;
	}

	   if((p==1)&(ready==1)){ //programa principal
		p=0;
		cuadrante=a;		// aqui se esta asignando el cuadrante objetivo por teclado desde processing se debe cambiar a recibir la trama
		mover_cuadrante();  // la variable cuadrante y posicion son globales, bastan con actualizarlas en cualquier instancia del programa par que el motor se desplaze hasta esa posicion
		leer_lidar();		
		t2=leer_sonar();	// grabar en t2 el valor la interrupcion que causo el ultrasonido
		enviar(maskblock,t2,lidar,posicion);	// Llamamos al procedimiento mask1 y envia por serial// para una prueba estamos metiendo el tiempo en posicion
		
	   }
	}	   

   /*** Don't write any code pass this line, or it will be deleted during code generation. ***/
  /*** RTOS startup code. Macro PEX_RTOS_START is defined by the RTOS component. DON'T MODIFY THIS CODE!!! ***/
  #ifdef PEX_RTOS_START
    PEX_RTOS_START();                  /* Startup of the selected RTOS. Macro is defined by the RTOS component. */
  #endif
  /*** End of RTOS startup code.  ***/
  /*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
  for(;;){}
  /*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/

/* END main */
/*!
** @}
*/
/*
** ###################################################################
**
**     This file was created by Processor Expert 10.3 [05.09]
**     for the Freescale HCS08 series of microcontrollers.
**
** ###################################################################
*/
