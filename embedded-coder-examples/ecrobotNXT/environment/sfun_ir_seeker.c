
/*
 * sfun_ir_seeker.c: simulation stub for HiTechnic IR Seeker
 *
 * written/modified by Nathan Bahr
 *   Copyright 2010 The MathWorks, Inc.
 */


#define S_FUNCTION_NAME  sfun_ir_seeker
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#ifndef MATLAB_MEX_FILE
/* Since we have a target file for this S-function, declare an error here
 * so that, if for some reason this file is being used (instead of the
 * target file) for code generation, we can trap this problem at compile
 * time.  */
#  error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif


/*=========================================================================*
 * Number of S-function Parameters and macros to access from the SimStruct *
 *=========================================================================*/
#define NUM_PARAMS                 (4)
#define SAMPLE_TIME_PRM(S)         (ssGetSFcnParam(S,0))
#define BLOCK_MODE_PRM(S)          (ssGetSFcnParam(S,1))
#define PORT_PRM(S)                (ssGetSFcnParam(S,2))
#define BD_MODE_PRM(S)             (ssGetSFcnParam(S,3))

/*==================================================*
 * Macros to access the S-function parameter values *
 *==================================================*/
#define SAMPLE_TIME                ((real_T) mxGetPr(SAMPLE_TIME_PRM(S))[0])
#define BLOCK_MODE                 ((uint8_T) mxGetPr(BLOCK_MODE_PRM(S))[0])
#define PORT                       ((uint8_T) mxGetPr(PORT_PRM(S))[0])
#define BD_MODE                    ((uint8_T) mxGetPr(BD_MODE_PRM(S))[0])

#define INTERFACE_BLOCK  0
#define GET_BLOCK        1

#define NUM_OF_BD_MODES  2  /* Master/Slave */
#define SIZE_DATA_PACKET 6

/*==================================================*
 * Macros to access the S-function parameter values *
 *==================================================*/
int16_T receiveBuf[NUM_OF_BD_MODES][4][SIZE_DATA_PACKET];
uint8_T port_config[NUM_OF_BD_MODES][2];

/*====================*
 * S-function methods *
 *====================*/


static void mdlCheckParameters(SimStruct *S)
{
}


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    /* See sfuntmpl_doc.c for more details on the macros below */

    ssSetNumSFcnParams(S, NUM_PARAMS);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S))
    {
      mdlCheckParameters(S);
      if (ssGetErrorStatus(S) != NULL)
        /* Return if number of expected != number of actual parameters */
        return;
    }
    else
      return;

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (BLOCK_MODE == INTERFACE_BLOCK)
    {
        if (!ssSetNumInputPorts(S, 1)) return;
        ssSetInputPortWidth(S, 0, SIZE_DATA_PACKET);
        ssSetInputPortDataType(S, 0, SS_INT8);
        ssSetInputPortRequiredContiguous(S, 0, true); 
        ssSetInputPortDirectFeedThrough(S, 0, 1);

        if (!ssSetNumOutputPorts(S, 0)) return;

        port_config[BD_MODE][0] = PORT;
    }
    else if (BLOCK_MODE == GET_BLOCK)
    {
        if (!ssSetNumInputPorts(S, 0)) return;

        if (!ssSetNumOutputPorts(S, 1)) return;
        ssSetOutputPortWidth(S, 0, SIZE_DATA_PACKET);
        ssSetOutputPortDataType(S, 0, SS_INT8);
//        ssSetOutputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
        port_config[BD_MODE][1] = PORT;
    }
    
    /* Check port configuration mismatch on Interface and Read blocks */ 
    if (port_config[BD_MODE][0] != 0 && port_config[BD_MODE][1] != 0)
    {
        if (port_config[BD_MODE][0] != port_config[BD_MODE][1])
        {
            ssSetErrorStatus(S, "Port configuration mismatch on Acceleration Sensor Interface/Read blocks or multiple uses.");
        }
    }
    
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_CAN_BE_CALLED_CONDITIONALLY);
    ssSetSFcnParamTunable(S, 0, 0);
    ssSetSFcnParamTunable(S, 1, 0);
    ssSetSFcnParamTunable(S, 2, 0);
    ssSetSFcnParamTunable(S, 3, 0);
    
    memset(port_config,0,sizeof(port_config));
    memset(receiveBuf,0,sizeof(receiveBuf));
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
  int16_T *u, *y;
  int_T num_inports = ssGetNumInputPorts(S);
  int_T num_outports = ssGetNumOutputPorts(S);
  int_T i;
  
  /* Block is used as interface */
  if (num_inports == 1 && num_outports == 0) 
  {
      u = (int16_T *)ssGetInputPortSignal(S, 0);
      for (i = 0; i < SIZE_DATA_PACKET; i++)
      {
          receiveBuf[BD_MODE][PORT][i] = u[i];
      }
          
  }
  /* Block is used as Signal Read */
  else if (num_inports == 0 && num_outports == 1)
  {
      y = (int16_T *)ssGetOutputPortSignal(S, 0);
      for (i = 0; i < SIZE_DATA_PACKET; i++)
      {
          y[i] = receiveBuf[BD_MODE][PORT][i];
      }
  }
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


#define MDL_RTW                        /* Change to #undef to remove function */
#if defined(MDL_RTW) && (defined(MATLAB_MEX_FILE) || defined(NRT))
/* Function: mdlRTW ============================================================
 * Abstract:
 *    This function is called when the Real-Time Workshop is generating the
 *    model.rtw file. In this routine, you can call the following functions
 *    which add fields to the model.rtw file.
 *
 *    Important! Since this s-function has this mdlRTW method, it is required
 *    to have a correcponding .tlc file so as to work with RTW. You will find
 *    the sfun_directlook.tlc in <matlabroot>/toolbox/simulink/blocks/tlc_c/.
 */
static void mdlRTW(SimStruct *S)
{
  const uint8_T sample_time = SAMPLE_TIME;
  const uint8_T block_mode = BLOCK_MODE;
  const uint8_T port = PORT;
  const uint8_T bd_mode = BD_MODE;

  if (!ssWriteRTWParamSettings(S, 4,
       SSWRITE_VALUE_DTYPE_NUM, "sample_time", &sample_time, DTINFO(SS_INT8,COMPLEX_NO),
       SSWRITE_VALUE_DTYPE_NUM, "block_mode", &block_mode, DTINFO(SS_UINT8,COMPLEX_NO),
       SSWRITE_VALUE_DTYPE_NUM, "port", &port, DTINFO(SS_UINT8,COMPLEX_NO),
       SSWRITE_VALUE_DTYPE_NUM, "bd_mode", &bd_mode, DTINFO(SS_UINT8,COMPLEX_NO)))
  {
    ssSetErrorStatus(S, "IR Seeker:ParamError");
     return;/* An error occurred which will be reported by Simulink */
  }

}
#endif /* MDL_RTW */


/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#include "simulink.c"      /* MEX-file interface mechanism */
