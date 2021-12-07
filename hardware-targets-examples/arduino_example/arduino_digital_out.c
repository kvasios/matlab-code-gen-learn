/*Copyright 2013 The MathWorks, Inc.*/

#define S_FUNCTION_NAME  arduino_digital_out
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/*================*
 * Build checking *
 *================*/


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 1);
	ssSetSFcnParamTunable(S, 0, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }
    
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S,0)) return;

    ssSetNumSampleTimes(S, 1);
 }


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}

#define MDL_START
void mdlStart(SimStruct *S){
/*Do nothing in simulation*/
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
/*Do nothing in simulation*/
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
}

#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
/* Function: mdlRTW =========================================================
 * Abstract:
 *    Writes S-function parameter setting in <model>.rtw
 */
static void mdlRTW(SimStruct *S)
{
    /*The parameter needs to be written to the .rtw file*/
	int_T pinNum = (int_T)mxGetPr(ssGetSFcnParam(S,0))[0];
	if (!ssWriteRTWParamSettings(S, 1, 
			SSWRITE_VALUE_DTYPE_NUM, "pinNum", &pinNum,DTINFO(SS_INT8, COMPLEX_NO))) {
		return;
	}
}

#endif /* mdlRTW */

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
