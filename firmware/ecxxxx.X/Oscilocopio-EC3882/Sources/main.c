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
#include "AD1.h"
#include "AS1.h"
#include "TI1.h"
#include "Bit1.h"
#include "Bit2.h"
#include "Bit3.h"
#include "TI2.h"
#include "Bit4.h"
#include "Byte1.h"
#include "PWM1.h"
#include "Cap1.h"
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

char p=-1;
char h=0;
char k=0;
unsigned int time;

// Funci�n para acomodar los datos seg�n el protocolo


void mask2(char maskblock2[4],char sonar[])
{ 
 maskblock2[0]=sonar[1];
 maskblock2[1]=0;//sonar[0];
 maskblock2[2]=0;//sonar[1];
 maskblock2[3]=0;//sonar[0];
}

void mask1(char maskblock[4],unsigned int sonar2,char lidar[],char posicion) // OPERATIVO Y PROBADO
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
}		
		
void mover(char posicion)
{		
	char secuencia[8]={0b00110100,0b00110110,0b00110010,0b00111010,0b00111000,0b00111001,0b00110001,0b00110101};
	Byte1_PutVal(secuencia[posicion]);
}

void main(void)
{
  /* Write your local variable definition here */
 char lidar[2],maskblock[4],sonar[2],posicion=31,control=0,inblock[4]; // Variables descritas anteriormente
 unsigned int ptr; // Apuntador que se requiere para la funci�n de enviar los bloques
 unsigned int t2;
 char i=0;
 unsigned char a;
 /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
 
   for(;;) {
   
	  if(p){ 
		   if(h>9)
		   {
		   h=0;
		   if(posicion>=63)
		   {
			   control=0;
			   posicion=63;
		   }
		   
		   if(posicion<=1)
		   {
			   control=1;
			   posicion=1;
		   }
		   
		   switch(control)
		   {
		   case 0:
			   posicion--;
			   break;
		   case 1:
			   posicion++;
			   break;	   
		   }
		   mover(posicion%8);	   
		   }
		  
	   Bit4_NegVal();  // PTD4 PIN 30, utilizado pra grafica una onda cuadrada de 1kHz que representa la frecuencia de muestreo
	   p=0; // Cada vez que se activa la interrupci�n el valor de p cambia a 1, esta parte es para devolverlo a 0
	   
	   AD1_MeasureChan(TRUE,1); // Lee el lidar conectado al canal 1
	   AD1_GetChanValue(1, &lidar); // se asigna el valor leido a la variable lidar
	   
	   t2=time/58;
	   mask1(maskblock,t2,lidar,posicion);	// Llamamos al procedimiento mask1	      // para una prueba estamos metiendo el tiempo en posicion
	   AS1_SendBlock(maskblock,4,&ptr); // Devolvemos el valor de maskblock (la trama)
   	   //AS1_RecvBlock(inblock,4,&ptr);		// recibe dato por serial
	   //AS1_RecvChar(*a);
   	   h++;
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
