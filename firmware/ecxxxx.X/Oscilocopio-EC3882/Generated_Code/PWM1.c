/* ###################################################################
**     THIS COMPONENT MODULE IS GENERATED BY THE TOOL. DO NOT MODIFY IT.
**     Filename    : PWM1.c
**     Project     : Oscilocopio-EC3882
**     Processor   : MC9S08QE128CLK
**     Component   : PWM
**     Version     : Component 02.240, Driver 01.28, CPU db: 3.00.067
**     Compiler    : CodeWarrior HCS08 C Compiler
**     Date/Time   : 2019-10-16, 09:37, # CodeGen: 45
**     Abstract    :
**         This component implements a pulse-width modulation generator
**         that generates signal with variable duty and fixed cycle. 
**     Settings    :
**         Used output pin             : 
**             ----------------------------------------------------
**                Number (on package)  |    Name
**             ----------------------------------------------------
**                       47            |  PTA7_TPM2CH2_ADP9
**             ----------------------------------------------------
**
**         Timer name                  : TPM2 [16-bit]
**         Counter                     : TPM2CNT   [$0051]
**         Mode register               : TPM2SC    [$0050]
**         Run register                : TPM2SC    [$0050]
**         Prescaler                   : TPM2SC    [$0050]
**         Compare register            : TPM2C2V   [$005C]
**         Flip-flop register          : TPM2C2SC  [$005B]
**
**         User handling procedure     : not specified
**
**         Port name                   : PTA
**         Bit number (in port)        : 7
**         Bit mask of the port        : $0080
**         Port data register          : PTAD      [$0000]
**         Port control register       : PTADD     [$0001]
**
**         Initialization:
**              Output level           : low
**              Timer                  : Enabled
**              Event                  : Enabled
**         High speed mode
**             Prescaler               : divide-by-1
**             Clock                   : 7471104 Hz
**           Initial value of            period     pulse width
**             Xtal ticks              : 147        0
**             microseconds            : 4500       10
**             milliseconds            : 5          0
**             seconds (real)          : 0.004500004283 0.000010038677
**
**     Contents    :
**         Enable     - byte PWM1_Enable(void);
**         SetRatio16 - byte PWM1_SetRatio16(word Ratio);
**         SetDutyUS  - byte PWM1_SetDutyUS(word Time);
**         SetDutyMS  - byte PWM1_SetDutyMS(word Time);
**
**     Copyright : 1997 - 2014 Freescale Semiconductor, Inc. 
**     All Rights Reserved.
**     
**     Redistribution and use in source and binary forms, with or without modification,
**     are permitted provided that the following conditions are met:
**     
**     o Redistributions of source code must retain the above copyright notice, this list
**       of conditions and the following disclaimer.
**     
**     o Redistributions in binary form must reproduce the above copyright notice, this
**       list of conditions and the following disclaimer in the documentation and/or
**       other materials provided with the distribution.
**     
**     o Neither the name of Freescale Semiconductor, Inc. nor the names of its
**       contributors may be used to endorse or promote products derived from this
**       software without specific prior written permission.
**     
**     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
**     ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
**     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
**     DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
**     ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
**     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
**     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
**     ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
**     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
**     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**     
**     http: www.freescale.com
**     mail: support@freescale.com
** ###################################################################*/
/*!
** @file PWM1.c
** @version 01.28
** @brief
**         This component implements a pulse-width modulation generator
**         that generates signal with variable duty and fixed cycle. 
*/         
/*!
**  @addtogroup PWM1_module PWM1 module documentation
**  @{
*/         


/* MODULE PWM1. */

#include "PE_Error.h"
#include "PWM1.h"

#pragma MESSAGE DISABLE C5703          /* WARNING C5703: Parameter _ declared in function _ but not referenced */
#pragma MESSAGE DISABLE C2705          /* WARNING C2705: Possible loss of data */
#pragma MESSAGE DISABLE C5919          /* WARNING C5919: Conversion of floating to unsigned integral */

#pragma CODE_SEG PWM1_CODE

/*lint -save  -esym(960,18.4) Disable MISRA rule (18.4) checking. */
typedef union {
  uint16_t Value;
  struct {
    uint8_t Hi;
    uint8_t Lo;
  } BB;
} TRatioValue;
/*lint -restore  +esym(960,18.4) Enable MISRA rule (18.4) checking. */

static TRatioValue ActualRatio;        /* Ratio of L-level to H-level - 16-bit unsigned value */

/* Internal method prototypes */

/*
** ===================================================================
**     Method      :  SetRatio (component PWM)
**
**     Description :
**         The method stores duty value to compare register(s) and sets 
**         necessary bits or (in List mode) call SetReg method for duty 
**         value storing.
**         This method is internal. It is used by Processor Expert only.
** ===================================================================
*/
static void SetRatio(void);

/* End of Internal methods declarations */

/*
** ===================================================================
**     Method      :  SetRatio (component PWM)
**
**     Description :
**         The method stores duty value to compare register(s) and sets 
**         necessary bits or (in List mode) call SetReg method for duty 
**         value storing.
**         This method is internal. It is used by Processor Expert only.
** ===================================================================
*/
static void SetRatio(void)
{
  if (ActualRatio.Value == 0xFFFFU) {  /* Duty = 100%? */
    TPM2C2V = 0xFFFFU;                 /* Store new value to the compare reg. */
  } else {
    TRatioValue Tmp1, Tmp2;
    uint16_t Result;
    Result = (uint16_t)((uint16_t)ActualRatio.BB.Hi * 0x83U); /* HI * HI */
    Tmp1.Value = (uint16_t)((uint16_t)ActualRatio.BB.Hi * 0x54U); /* HI * LO */
    Result += Tmp1.BB.Hi;
    Tmp2.Value = (uint16_t)((uint16_t)ActualRatio.BB.Lo * 0x83U); /* LO * HI */
    Result += Tmp2.BB.Hi;
    if ((Tmp2.BB.Lo += Tmp1.BB.Lo) < Tmp1.BB.Lo) {
      ++Result;                        /* carry to result */
    }
    Tmp1.Value = (uint16_t)((uint16_t)ActualRatio.BB.Lo * 0x54U); /* LO * LO */
    if ((Tmp1.BB.Hi += Tmp2.BB.Lo) < Tmp2.BB.Lo) {
      ++Result;                        /* carry to result */
    }
    if (Tmp1.BB.Hi >= 0x80U) {
      ++Result;                        /* round */
    }
    TPM2C2V = Result;
  }
}

/*
** ===================================================================
**     Method      :  PWM1_Enable (component PWM)
**     Description :
**         This method enables the component - it starts the signal
**         generation. Events may be generated (<DisableEvent>
**         /<EnableEvent>).
**     Parameters  : None
**     Returns     :
**         ---             - Error code, possible codes:
**                           ERR_OK - OK
**                           ERR_SPEED - This device does not work in
**                           the active speed mode
** ===================================================================
*/
byte PWM1_Enable(void)
{
  /* TPM2SC: TOF=0,TOIE=0,CPWMS=0,CLKSB=0,CLKSA=1,PS2=0,PS1=0,PS0=0 */
  setReg8(TPM2SC, 0x08U);              /* Run the counter (set CLKSB:CLKSA) */ 
  return ERR_OK;                       /* OK */
}

/*
** ===================================================================
**     Method      :  PWM1_SetRatio16 (component PWM)
**     Description :
**         This method sets a new duty-cycle ratio. Ratio is expressed
**         as a 16-bit unsigned integer number. 0 - FFFF value is
**         proportional to ratio 0 - 100%. The method is available
**         only if it is not selected list of predefined values in
**         <Starting pulse width> property. 
**         Note: Calculated duty depends on the timer possibilities and
**         on the selected period.
**     Parameters  :
**         NAME            - DESCRIPTION
**         Ratio           - Ratio to set. 0 - 65535 value is
**                           proportional to ratio 0 - 100%
**     Returns     :
**         ---             - Error code, possible codes:
**                           ERR_OK - OK
**                           ERR_SPEED - This device does not work in
**                           the active speed mode
** ===================================================================
*/
byte PWM1_SetRatio16(word Ratio)
{
  ActualRatio.Value = Ratio;           /* Store new value of the ratio */
  SetRatio();                          /* Calculate and set up new appropriate values of the compare and modulo registers */
  return ERR_OK;                       /* OK */
}

/*
** ===================================================================
**     Method      :  PWM1_SetDutyUS (component PWM)
**     Description :
**         This method sets the new duty value of the output signal.
**         The duty is expressed in microseconds as a 16-bit
**         unsigned integer number.
**     Parameters  :
**         NAME            - DESCRIPTION
**         Time            - Duty to set [in microseconds]
**                      (0 to 4500 us in high speed mode)
**     Returns     :
**         ---             - Error code, possible codes:
**                           ERR_OK - OK
**                           ERR_SPEED - This device does not work in
**                           the active speed mode
**                           ERR_MATH - Overflow during evaluation
**                           ERR_RANGE - Parameter out of range
** ===================================================================
*/
byte PWM1_SetDutyUS(word Time)
{
  dlong rtval;                         /* Result of two 32-bit numbers multiplication */
  if (Time > 0x1194U) {                /* Is the given value out of range? */
    return ERR_RANGE;                  /* If yes then error */
  }
  PE_Timer_LngMul((dword)Time, 0x0E904445UL, &rtval); /* Multiply given value and High speed CPU mode coefficient */
  if (PE_Timer_LngHi3(rtval[0], rtval[1], &ActualRatio.Value)) { /* Is the result greater or equal than 65536 ? */
    ActualRatio.Value = 0xFFFFU;       /* If yes then use maximal possible value */
  }
  SetRatio();                          /* Calculate and set up new appropriate values of the compare and modulo registers */
  return ERR_OK;                       /* OK */
}

/*
** ===================================================================
**     Method      :  PWM1_SetDutyMS (component PWM)
**     Description :
**         This method sets the new duty value of the output signal.
**         The duty is expressed in milliseconds as a 16-bit
**         unsigned integer number.
**     Parameters  :
**         NAME            - DESCRIPTION
**         Time            - Duty to set [in milliseconds]
**                      (0 to 5 ms in high speed mode)
**     Returns     :
**         ---             - Error code, possible codes:
**                           ERR_OK - OK
**                           ERR_SPEED - This device does not work in
**                           the active speed mode
**                           ERR_MATH - Overflow during evaluation
**                           ERR_RANGE - Parameter out of range
** ===================================================================
*/
byte PWM1_SetDutyMS(word Time)
{
  dlong rtval;                         /* Result of two 32-bit numbers multiplication */
  if (Time > 0x05U) {                  /* Is the given value out of range? */
    return ERR_RANGE;                  /* If yes then error */
  }
  PE_Timer_LngMul((dword)Time, 0x38E38AACUL, &rtval); /* Multiply given value and High speed CPU mode coefficient */
  if (PE_Timer_LngHi2(rtval[0], rtval[1], &ActualRatio.Value)) { /* Is the result greater or equal than 65536 ? */
    ActualRatio.Value = 0xFFFFU;       /* If yes then use maximal possible value */
  }
  SetRatio();                          /* Calculate and set up new appropriate values of the compare and modulo registers */
  return ERR_OK;                       /* OK */
}

/*
** ===================================================================
**     Method      :  PWM1_Init (component PWM)
**
**     Description :
**         Initializes the associated peripheral(s) and the components 
**         internal variables. The method is called automatically as a 
**         part of the application initialization code.
**         This method is internal. It is used by Processor Expert only.
** ===================================================================
*/
void PWM1_Init(void)
{
  /* TPM2SC: TOF=0,TOIE=0,CPWMS=0,CLKSB=0,CLKSA=0,PS2=0,PS1=0,PS0=0 */
  setReg8(TPM2SC, 0x00U);              /* Disable device */ 
  /* TPM2C2SC: CH2F=0,CH2IE=0,MS2B=1,MS2A=1,ELS2B=1,ELS2A=1,??=0,??=0 */
  setReg8(TPM2C2SC, 0x3CU);            /* Set up PWM mode with output signal level low */ 
  ActualRatio.Value = 0x93U;           /* Store initial value of the ratio */
  /* TPM2MOD: BIT15=1,BIT14=0,BIT13=0,BIT12=0,BIT11=0,BIT10=0,BIT9=1,BIT8=1,BIT7=0,BIT6=1,BIT5=0,BIT4=1,BIT3=0,BIT2=0,BIT1=1,BIT0=1 */
  setReg16(TPM2MOD, 0x8353U);          /* Set modulo register */ 
  SetRatio();                          /* Calculate and set up new values of the compare according to the selected speed CPU mode */
  /* TPM2SC: TOF=0,TOIE=0,CPWMS=0,CLKSB=0,CLKSA=1,PS2=0,PS1=0,PS0=0 */
  setReg8(TPM2SC, 0x08U);              /* Run the counter (set CLKSB:CLKSA) */ 
}

/* END PWM1. */

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
