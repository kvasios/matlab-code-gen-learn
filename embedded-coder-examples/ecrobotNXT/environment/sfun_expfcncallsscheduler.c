/*
 * sfun_expfcncallsscheduler.c: Scheduler for Exported Fuction Call Subsystems
 *
 *   Copyright 2010 The MathWorks, Inc.
 */

#define S_FUNCTION_NAME  sfun_expfcncallsscheduler
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NUMBER_OF_FCNS        (ssGetSFcnParam(S,0))
#define NUMBER_OF_TRIGS       (ssGetSFcnParam(S,1))
#define TIMING_TABLE          (ssGetSFcnParam(S,2))
#define SAMPLE_TIME           (ssGetSFcnParam(S,3))

#define TRIGGER (-1)
#define INIT    (0)

/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{
    real_T *numFCNS = mxGetPr(NUMBER_OF_FCNS);
    int_T numTIMINGS = (int_T)mxGetNumberOfElements(TIMING_TABLE);
    int_T i;

    if ((int_T)*numFCNS != numTIMINGS) {
        ssSetErrorStatus(S,"### Parameter mismatch occurred.");
        return;
    }
    
    for(i = 0; i<numTIMINGS; i++) {
        if ((int_T)(mxGetPr(TIMING_TABLE)[i])<-1) {
            ssSetErrorStatus(S,"### Function execution timing is not set correctly.");
            return;
        }
    }
    
}

static void mdlInitializeSizes(SimStruct *S)
{
    real_T *numFCNS = mxGetPr(NUMBER_OF_FCNS);
    real_T *numTRIGS = mxGetPr(NUMBER_OF_TRIGS);
    int_T i;
    
    ssSetNumSFcnParams(S, 4);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    if (*numTRIGS == 0) { /* No external trigger */
        if (!ssSetNumInputPorts(S, 0)) return;
    }
    else {        
        if (!ssSetNumInputPorts(S, 1)) return;
        ssSetInputPortWidth(S, 0, *numTRIGS);
        ssSetInputPortDataType(S, 0, SS_DOUBLE); /* external trigger should be double */
        ssSetInputPortRequiredContiguous(S, 0, true); 
        ssSetInputPortDirectFeedThrough(S, 0, 1);
    }

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, *numFCNS);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, *numTRIGS);
    ssSetNumIWork(S, 1);
    ssSetNumPWork(S, 0);
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    int_T i;

    ssSetSampleTime(S, 0, *mxGetPr(SAMPLE_TIME));
    ssSetOffsetTime(S, 0, 0.0);
    
    for(i = 0; i < ssGetOutputPortWidth(S,0); i++) {
        ssSetCallSystemOutput(S,i);
    }

}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
static void mdlStart(SimStruct *S)
{
    int_T *execCnt = ssGetIWork(S);

    *execCnt = 0;

    if (ssGetNumRWork(S) > 0){
        int_T i;
        real_T *TRIG_Work = ssGetRWork(S);
        for (i=0; i<ssGetNumRWork(S); i++) {
            TRIG_Work[i] = 0;
        }
    }
        
}
#endif /*  MDL_START */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T *execCnt = ssGetIWork(S);
    int_T numTIMINGS = (int_T)mxGetNumberOfElements(TIMING_TABLE);
    int_T i;
    
    if (ssGetNumInputPorts(S) == 0) { /* No external trigger */
        for(i=0; i<numTIMINGS; i++) {
            if (*execCnt == 0) { /* at the first simulation step */
                ssCallSystemWithTid(S,i,tid);
            }
            else {
                if ((int_T)(mxGetPr(TIMING_TABLE)[i]) > 0) {
                    if (*execCnt % (int_T)(mxGetPr(TIMING_TABLE)[i]) == 0) {
                        ssCallSystemWithTid(S,i,tid);
                    }
                }
            }
        }
    }
    else { /* in case of including external trigger source */
        const real_T *trigger = ssGetInputPortSignal(S,0);
        real_T *TRIG_Work = ssGetRWork(S);
        int_T j = 0;
        
        for(i=0; i<numTIMINGS; i++) {
            if (*execCnt == 0) { /* at the first simulation step */
                if ((int_T)(mxGetPr(TIMING_TABLE)[i]) >= 0) {
                    ssCallSystemWithTid(S,i,tid);
                }
                else if ((int_T)(mxGetPr(TIMING_TABLE)[i]) == TRIGGER) {
                    if(trigger[j] > 0 && TRIG_Work[j] <= 0) { /* detect rising edge */
                        ssCallSystemWithTid(S,i,tid);
                    }
                    TRIG_Work[j] = trigger[j];
                    j++;
                }
            }
            else {
                if ((int_T)(mxGetPr(TIMING_TABLE)[i]) > 0) {
                    if (*execCnt % (int_T)(mxGetPr(TIMING_TABLE)[i]) == 0) {
                        ssCallSystemWithTid(S,i,tid);
                    }
                }
                else if ((int_T)(mxGetPr(TIMING_TABLE)[i]) == TRIGGER) {
                    if(trigger[j] > 0 && TRIG_Work[j] <= 0) { /* detect rising edge */
                        ssCallSystemWithTid(S,i,tid);
                    }
                    TRIG_Work[j] = trigger[j];
                    j++;
                }
            }
        }
    }
    
    (*execCnt)++;
}

static void mdlTerminate(SimStruct *S) {}


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
