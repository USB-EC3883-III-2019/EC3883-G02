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
#include "EInt1.h"
#include "Byte1.h"
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
 *  32	PTD5	SONAR			ELNT1		I		INTERRUPCION PARA DETECTAR CAMBIO EN EL PIN ECHO DEL ULTRASONIDO
 *  34	PTD6	TRIGGER			BIT3		O		PIN PARA ACTIVAR LA RAFAGA ACUSTICA DE MEDICION
 *  14	PTA0	LIDAR						I		SENSOR SHARP
 *  16	PTA1	POTENCIOMETRO				I		TENTATIVO CONECTAR POTENCIOMETRO PARA OBTENER POSICION
 */

char p=0;
char h=0;
char k=0;

// Función para acomodar los datos según el protocolo

void mask1(char maskblock[4],char sonar[],char lidar[],char posicion) // OPERATIVO Y PROBADO
{
	   /* Las variables son:
	    * maskblock hace referencia a los 4 bytes completos que envía el demoQE, sería la trama según el protocolo
	    * sonar cuenta con 2 bytes del sonar
	    * lidar son los 2 bytes del canal 2
	    */
	
		/* funcionamiento:
		 * Se enviara una trama teniendo en cuenta la cabezera de la trama 
		 * los la trama de prueba sera 00000001 10000011 10000111 10001111
		 */
		char temp;
		
		maskblock[0]= posicion; 		// posicion garantizando la cabecera 00

		temp    	= sonar[1] & 0b00000001	;	
		maskblock[1]= (temp << 6 );					// desplaza el bit hasta la posicion en la que inicia
		maskblock[1]= maskblock[1] | (sonar[0] >> 2) | 0b10000000;	// 

		maskblock[2]= (sonar[0] & 0b00000011) << 5 ;
		
		temp=lidar[0] >> 7;
		
		maskblock[2]= maskblock[2] | (((lidar[1] & 0b00001111)<<1)|temp) ;
		maskblock[2]= maskblock[2] | 0b10000000;

		maskblock[3]= lidar[1] | 0b10000000;

}

void mover(char posicion)
{
	char secuencia[8]={0b00110101,0b00110001,0b00111001,0b00111000,0b00111010,0b00110010,0b00110110,0b00110100};
	Byte1_PutVal(secuencia[posicion]);
}

void main(void)
{
  /* Write your local variable definition here */
 char sonar[2],lidar[2],maskblock[4],posicion,control=0; // Variables descritas anteriormente
 unsigned int ptr; // Apuntador que se requiere para la función de enviar los bloques
 char dig,dig2; // Canales digitales
 char i=0;
  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
 
   for(;;) {
	   
   
	  if(p) {
		  sonar[1]=0b00000001;
		  sonar[0]=0b11000111;
		  lidar[1]=0b00001111;
		  lidar[0]=0b00001111;
	   
	   Bit4_NegVal();  // PTD4 PIN 30, utilizado pra grafica una onda cuadrada de 1kHz que representa la frecuencia de muestreo
	   p=0; // Cada vez que se activa la interrupción el valor de p cambia a 1, esta parte es para devolverlo a 0
/*	   AD1_MeasureChan(TRUE,0); // Lee lo que se encuentra en el canal 1
	   AD1_GetChanValue(0, &sonar); // Se asigna lo que se leyó a la variable sonar
	   AD1_MeasureChan(TRUE,1); // Lee lo que se encuentra en el canal 2
	   AD1_GetChanValue(1, &lidar); // Se asigna lo que se leyó a la variable lidar
	   dig=Bit1_GetVal(); // Asignamos el valor de un bit a la variable del canal digital 1
	   dig2=Bit2_GetVal(); 	// Asignamos el valor de un bit a la variable del canal digital 2
*/
	   if(posicion>128)
	   {
		   control=0;
		   posicion=128;
	   }
	   
	   if(posicion<1)
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
	   mask1(maskblock,sonar,lidar,posicion);	// Llamamos al procedimiento mask1	    
	   AS1_SendBlock(maskblock,4,&ptr); // Devolvemos el valor de maskblock (la trama)
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
