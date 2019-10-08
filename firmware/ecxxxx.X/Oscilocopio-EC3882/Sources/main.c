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
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/* User includes (#include below this line is not maintained by Processor Expert) */

/*	INFO GENERAL
 * 
 * 	PIN NOMBRE	DESCRIPCION 	I/O		NOTAS
 * 	-----------------------------------------------------------------------
 *  1	VDD	   	+3V				O		SALIDA DE VOLTAGE POSITIVO DEMOQE	
 *  3	VSS	   	0				O		TIERRA DEL DEMOQE 
 *  13	PTC0	MOTOR 1			O		BOBINA MOTOR
 *  15	PTC1	MOTOR 2			O		BOBINA MOTOR
 *  33	PTC2	MOTOR 3			O		BOBINA MOTOR
 *  35	PTC3	MOTOR 4			O		BOBINA MOTOR
 *  30	PTD4	ZERO IZQ		I		SENSOR PARA DETECTAR MAXIMO IZQUIERDA
 *  34	PTD6	ZERO DER		I		SENSOR PARA DETECTAR MAXIMO DERECHA
 *  36	PTD7	FILTRO			I		BOTON PARA ACTIVAR O DESACTIVAR FILTRO
 *  32	PTD5	SONAR			I		INTERRUPCION PARA DETECTAR CAMBIO EN EL PIN ECHO DEL ULTRASONIDO
 *  14	PTA0	LIDAR			I		SENSOR SHARP
 *  16	PTA1	POTENCIOMETRO	I		TENTATIVO CONECTAR POTENCIOMETRO PARA OBTENER POSICION
 */

char p=0;
char h=0;
char k=0;

// Funci�n para acomodar los datos seg�n el protocolo

void mask1(char maskblock[4],char block1[],char block2[],char dig,char dig2)
{
	   /* Las variables son:
	    * maskblock hace referencia a los 4 bytes completos que env�a el demoQE, ser�a la trama seg�n el protocolo
	    * block1 cuenta con 2 bytes del canal 1
	    * block2 son los 2 bytes del canal 2
	    */
	
		/* funcionamiento:
		 * Se enviara una trama teniendo en cuenta la cabezera de la trama 
		 * los la trama de prueba sera 00000001 10000011 10000111 10001111
		 */
	
		maskblock[0]= 0b00000001; // prueba de comunicacion
		maskblock[1]= 0b10000011;
		maskblock[2]= 0b10000111;
		maskblock[3]= 0b00001111;		
}

void main(void)
{
  /* Write your local variable definition here */
char block1[2],block2[2],maskblock[4]; // Variables descritas anteriormente
unsigned int ptr; // Apuntador que se requiere para la funci�n de enviar los bloques
char dig,dig2; // Canales digitales

  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
 
   for(;;) {
	   
	  if(p) {
	   Bit4_NegVal();  // PTD4 PIN 30, utilizado pra grafica una onda cuadrada de 1kHz que representa la frecuencia de muestreo
	   p=0; // Cada vez que se activa la interrupci�n el valor de p cambia a 1, esta parte es para devolverlo a 0
	   AD1_MeasureChan(TRUE,0); // Lee lo que se encuentra en el canal 1
	   AD1_GetChanValue(0, &block1); // Se asigna lo que se ley� a la variable block1
	   AD1_MeasureChan(TRUE,1); // Lee lo que se encuentra en el canal 2
	   AD1_GetChanValue(1, &block2); // Se asigna lo que se ley� a la variable block2
	   dig=Bit1_GetVal(); // Asignamos el valor de un bit a la variable del canal digital 1
	   dig2=Bit2_GetVal(); // Asignamos el valor de un bit a la variable del canal digital 2
	   mask1(maskblock,block1,block2,dig,dig2);	// Llamamos al procedimiento mask1	
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
