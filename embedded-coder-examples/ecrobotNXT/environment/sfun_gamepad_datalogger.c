/*
 * sfun_gamepad_datalogger.c: simulation stub for NXT GamePad Data Logger
 *
 *   Copyright 2010 The MathWorks, Inc.
 */


#define S_FUNCTION_NAME  sfun_gamepad_datalogger
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
#define NUM_PARAMS                 (1)
#define MODE_PRM(S)                (ssGetSFcnParam(S,0))

/*==================================================*
 * Macros to access the S-function parameter values *
 *==================================================*/
#define MODE                       ((uint8_T) mxGetPr(MODE_PRM(S))[0])

#define NORMAL_MODE           1
#define CONFIGURABLE_MODE     2

/*==================================================*
 * Macros to access the S-function parameter values *
 *==================================================*/

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
    
    if (MODE == NORMAL_MODE)
    {
        if (!ssSetNumInputPorts(S, 2)) return;
        ssSetInputPortWidth(S, 0, 1);
        ssSetInputPortDataType(S, 0, SS_INT8);
        ssSetInputPortRequiredContiguous(S, 0, true); 
        ssSetInputPortDirectFeedThrough(S, 0, 1);
        ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);

        ssSetInputPortWidth(S, 1, 1);
        ssSetInputPortDataType(S, 1, SS_INT8);
        ssSetInputPortRequiredContiguous(S, 1, true); 
        ssSetInputPortDirectFeedThrough(S, 1, 1);
        ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
    }
    else if (MODE == CONFIGURABLE_MODE)
    {
        int i;
        
        if (!ssSetNumInputPorts(S, 6)) return;
        ssSetInputPortWidth(S, 0, 1);
        ssSetInputPortDataType(S, 0, SS_INT8);
        ssSetInputPortRequiredContiguous(S, 0, true); 
        ssSetInputPortDirectFeedThrough(S, 0, 1);
        ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);

        ssSetInputPortWidth(S, 1, 1);
        ssSetInputPortDataType(S, 1, SS_INT8);
        ssSetInputPortRequiredContiguous(S, 1, true); 
        ssSetInputPortDirectFeedThrough(S, 1, 1);
        ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);

        for (i=2; i<6; i++)
        {
            ssSetInputPortWidth(S, i, 1);
            ssSetInputPortDataType(S, i, SS_INT16);
            ssSetInputPortRequiredContiguous(S, i, true); 
            ssSetInputPortDirectFeedThrough(S, i, 1);
            ssSetInputPortOptimOpts(S, i, SS_REUSABLE_AND_LOCAL);
        }
    }

    if (!ssSetNumOutputPorts(S, 0)) return;
    
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_CAN_BE_CALLED_CONDITIONALLY);
    ssSetSFcnParamTunable(S, 0, 0);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* no outputs */
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
  const uint8_T mode = MODE;

  if (!ssWriteRTWParamSettings(S, 1,
       SSWRITE_VALUE_DTYPE_NUM, "mode", &mode, DTINFO(SS_UINT8,COMPLEX_NO)))
  {
    ssSetErrorStatus(S, "NXT GamePad Data Logger:ParamError");
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
