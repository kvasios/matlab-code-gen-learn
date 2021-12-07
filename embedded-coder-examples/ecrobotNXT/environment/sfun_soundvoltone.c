/*
 * sfun_bt_tx.c: simulation stub for sound tone
 *
 *   Copyright 2010 The MathWorks, Inc.
 */


#define S_FUNCTION_NAME  sfun_soundvoltone
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
#define NUM_PARAMS                 (3)
#define SAMPLE_TIME_PRM(S)         (ssGetSFcnParam(S,0))
#define BLOCK_MODE_PRM(S)          (ssGetSFcnParam(S,1))
#define BD_MODE_PRM(S)             (ssGetSFcnParam(S,2))

/*==================================================*
 * Macros to access the S-function parameter values *
 *==================================================*/
#define SAMPLE_TIME                ((real_T) mxGetPr(SAMPLE_TIME_PRM(S))[0])
#define BLOCK_MODE                ((uint8_T) mxGetPr(BLOCK_MODE_PRM(S))[0])
#define BD_MODE                   ((uint8_T) mxGetPr(BD_MODE_PRM(S))[0])

#define INTERFACE_BLOCK  0
#define SET_BLOCK        1

#define NUM_OF_BD_MODES  2  /* Master/Slave */
#define NUM_DATA 3

/*==================================================*
 * Macros to access the S-function parameter values *
 *==================================================*/
uint32_T buf[NUM_OF_BD_MODES][NUM_DATA];

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
        if (!ssSetNumInputPorts(S, 0)) return;

        if (!ssSetNumOutputPorts(S, NUM_DATA)) return;
        ssSetOutputPortWidth(S, 0, 1);
        ssSetOutputPortDataType(S, 0, SS_UINT32);
        ssSetOutputPortWidth(S, 1, 1);
        ssSetOutputPortDataType(S, 1, SS_UINT32);
        ssSetOutputPortWidth(S, 2, 1);
        ssSetOutputPortDataType(S, 2, SS_UINT32);
    }
    else if (BLOCK_MODE == SET_BLOCK)
    {
        if (!ssSetNumInputPorts(S, NUM_DATA)) return;
        ssSetInputPortWidth(S, 0, 1);
        ssSetInputPortDataType(S, 0, SS_UINT32);
        ssSetInputPortRequiredContiguous(S, 0, true); 
        ssSetInputPortDirectFeedThrough(S, 0, 1);
        ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
        ssSetInputPortWidth(S, 1, 1);
        ssSetInputPortDataType(S, 1, SS_UINT32);
        ssSetInputPortRequiredContiguous(S, 1, true); 
        ssSetInputPortDirectFeedThrough(S, 1, 1);
        ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
        ssSetInputPortWidth(S, 2, 1);
        ssSetInputPortDataType(S, 2, SS_UINT32);
        ssSetInputPortRequiredContiguous(S, 2, true); 
        ssSetInputPortDirectFeedThrough(S, 2, 1);
        ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);

        if (!ssSetNumOutputPorts(S, 0)) return;
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
    
    memset(buf,0,sizeof(buf));
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
  uint32_T *freq, *dur, *vol;
  int_T num_inports = ssGetNumInputPorts(S);
  int_T num_outports = ssGetNumOutputPorts(S);
  
  /* block is used as signal send */
  if (num_inports == NUM_DATA && num_outports == 0) 
  {
      freq = (uint32_T *)ssGetInputPortSignal(S, 0);
      dur = (uint32_T *)ssGetInputPortSignal(S, 1);
      vol = (uint32_T *)ssGetInputPortSignal(S, 2);
      buf[BD_MODE][0] = *freq;
      buf[BD_MODE][1] = *dur;
      buf[BD_MODE][2] = *vol;
  }
  /* block is used as interface */
  else if (num_inports == 0 && num_outports == NUM_DATA)
  {
      freq = (uint32_T *)ssGetOutputPortSignal(S, 0);
      dur = (uint32_T *)ssGetOutputPortSignal(S, 1);
      vol = (uint32_T *)ssGetOutputPortSignal(S, 2);
      *freq = buf[BD_MODE][0];
      *dur = buf[BD_MODE][1];
      *vol = buf[BD_MODE][2];
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
  const uint8_T bd_mode = BD_MODE;

  if (!ssWriteRTWParamSettings(S, 3,
       SSWRITE_VALUE_DTYPE_NUM, "sample_time", &sample_time, DTINFO(SS_INT8,COMPLEX_NO),
       SSWRITE_VALUE_DTYPE_NUM, "block_mode", &block_mode, DTINFO(SS_UINT8,COMPLEX_NO),
       SSWRITE_VALUE_DTYPE_NUM, "bd_mode", &bd_mode, DTINFO(SS_UINT8,COMPLEX_NO)))
  {
    ssSetErrorStatus(S, "Bluetooth Tx:ParamError");
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
