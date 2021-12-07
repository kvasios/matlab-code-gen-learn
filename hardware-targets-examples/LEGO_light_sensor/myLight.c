/*Copyright 2013 The MathWorks, Inc.*/

#define S_FUNCTION_NAME  myLight
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"

        /* Function: mdlInitializeSizes ================= */
static void mdlInitializeSizes(SimStruct *S)
{

    if (!ssSetNumInputPorts(S, 1)) return; /*One Input*/
    ssSetInputPortWidth(S, 0, 1);          /*of Dimension 1*/
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S,0)) return; /*Zero Outports*/
}

/* Function: mdlInitializeSampleTimes ================== */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}


/* Function: mdlOutputs ================================ */
static void mdlOutputs(SimStruct *S, int_T tid)
{
}

/* Function: mdlTerminate ============================== */
static void mdlTerminate(SimStruct *S)
{
}




#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif


