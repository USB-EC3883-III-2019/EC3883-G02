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
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/* User includes (#include below this line is not maintained by Processor Expert) */

unsigned char a=1,b=0;
unsigned int p=0;
char posicion=0;
char cuadrante=1;    ////cuadrante al cual se quiere mover
char cuadrante_a=1;  //variable de control para verificar que se va a cambiar a un cuadrante nuevo
int control=0;
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
			  if(control%10==0){ 
			  Bit1_NegVal();
			  }
			  control++;
			  if(control>100){
				  control=0;
			  }
		  }
	}
			Byte1_PutVal(secuencia[posicion%8]);			  
   
}

void main(void)
{
  /* Write your local variable definition here */
unsigned int ptr;
char ready=0,init=0;

	/*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
   
   for(;;) {

	if((p==1) & (init<62)){ // espera inicial para inicar el programa
	p=0;
	init++;
	}
	if(init==62){
		ready=1;
	}

	   if((p==1)&(ready==1)){
		p=0;
		cuadrante=a;
		mover_cuadrante();  // la variable cuadrante y posicion son globales, bastan con actualizarlas en cualquier instancia del programa par que el motor se desplaze hasta esa posicion
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
