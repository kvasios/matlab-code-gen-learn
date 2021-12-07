/*
 * Copyright 1994-2006 The MathWorks, Inc.
 *
 * File: rt_main.c     $Revision: 22931 $
 *
 * Abstract:
 *  The real-time main program for targetting Tornado/VxWorks.
 *  
 *  The code works by attaching a semaphore to the Aux clock interrupt.
 *  Each clock tick, a semaphore is given that runs a task to execute and
 *  advance the model one time step.  That task may in turn start the 
 *  execution of several sub-tasks(in multitasking mode), each performing
 *  one sample rate in a multi-rate system.
 *  
 *  There are 2 modes that the model can be executed in, multitasking
 *  and singletasking, the default mode is singletasking.  If the model
 *  has only 1 state or has 2 states, 1 continuous and 1 discrete but
 *  they have equal rates, the model is forced to run in the 
 *  singletasking mode.  Otherwise the user can run the model in either
 *  mode by using the OPTS=-DMT macro in the make command field of the RTW 
 *  page dialog.  Depending on the model, one mode will be able to achieve
 *  higher sample rates than the other.
 *  In order to build the model for multitasking mode, Zero-Order Hold
 *  and Unit Delay blocks are needed between blocks with different sample
 *  rates.  They are required to ensure proper execution of the model.
 *  See the RTW User's Guide for more information.  
 *
 *  NOTES:
 *  A makefile is provided; it can be used to compile this code.  You
 *  should first edit it to reflect your host system and target system
 *  configurations.
 *   
 *  When using mat file logging or StethoScope, signals are sampled in 
 *  the base rate task asynchronously from slower rate tasks.  Therefore,
 *  when running the model in multitasking mode, signals sampled from slower
 *  rate blocks in the model may change at different base rate sample times
 *  from run to run of the model.  To remove this variation, run the model
 *  in singletasking mode.
 *
 *  When using external mode, parameter downloading is performed by a 
 *  background (lower priority) task which can get preempted by the model
 *  tasks(tBaseRate, tSingleRate, tRateN).  Thus, a given parameter update is
 *  not guaranteed to complete within one base rate sample time of the model.
 *
 *  Using the Tornado Browser or Shell while the model is running can cause
 *  a "rate to fast" error  because the tWdbTask has a priority of 3 which
 *  is higher than the tasks create for model execution.
 *   
 *  Defines automatically generated during build:
 *	RT              - Required. real-time.
 *      MODEL           - Required. model name.
 *	NUMST=#         - Required. Number of sample times.
 *	NCSTATES=#      - Required. Number of continuous states.
 *      TID01EQ=1 or 0  - Required. Only define to 1 if sample time task
 *                        id's 0 and 1 have equal rates.
 *
 *  Defines controlled from the RTW page make command dialog:
 *      MULTITASKING    - Optional. To enable multitasking mode.
 *                        Use the OPTS=-DMT macro in the dialog.
 *      EXT_MODE        - Optional. Simulink External Mode.
 *                        Use the EXT_MODE=1 macro in the dialog.
 *      VERBOSE         - Optional. To enable verbose external mode.
 *                        Use the OPTS=-DVERBOSE macro in the dialog.
 *      STETHOSCOPE     - Optional. Data collection/graphical monitoring.
 *                        Use the STETHOSCOPE=1 macro in the dialog.
 *      MAT_FILE        - Optional. MAT File Logging.
 *                        Use the MAT_FILE=1 macro in the dialog.
 *	SAVEFILE        - Optional. (non-quoted) name of .mat file to create. 
 *                        Use the OPTS="-DSAVEFILE=filename" macro.
 *                        Use if name is desired other than MODEL.mat for the
 *                        mat log file or device other than the current VxWorks
 *                        default device is desired.
 *
 *  Defines controlled from this file.
 *      STOPONOVERRUN   - Optional. Comment out below to ignore rate overruns.
*/

/*****************
 * Include files *
 *****************/
#define _GNU_SOURCE             /* See feature_test_macros(7) */
#include <sched.h>

/*ANSI C headers*/
#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>

#ifdef __QNX__
#include <sys/neutrino.h>
#endif

/*VxWorks headers*/
#ifdef __VXWORKS__
#include <vxWorks.h>
#include <taskLib.h>
#include <cpuset.h>
#endif 
/*
#include <sysLib.h>
#include <semLib.h>
#include <rebootLib.h>
#include <logLib.h>
*/

/* Posix headers */
#include <signal.h>
#include <errno.h>
#include <pthread.h>
#include <semaphore.h>

#ifdef __QNX__
#include <sys/neutrino.h>
#endif

/*Real-Time Workshop headers*/
#include "tmwtypes.h"  
#include "rtmodel.h"
#include "rt_sim.h"

/*Stethoscope header*/
#ifdef STETHOSCOPE
#include <string.h>
#include <ctype.h>
#include "rtw_capi.h"
typedef int boolean;
#include "scope/scope.h" 
#endif

/*External Mode header*/
#ifdef EXT_MODE
#include "ext_work.h"
#endif

/*MAT File header*/
#ifdef MAT_FILE
#include "rt_logging.h"
#endif

/*LTTNG header*/
#ifdef LTTNG
#include "lttng/tracef.h"
#endif

/*******************************************************************
 * Comment out the following define to cause program to print a    *
 * warning message, but continue executing when an overrun occurs. *
 *******************************************************************/
#define STOPONOVERRUN

#ifndef BASE_PRIORITY
#define BASE_PRIORITY		(30)
#endif

#ifndef RT
# error "must define RT"
#endif

#ifndef MODEL
# error "must define MODEL"
#endif

#ifndef NUMST
# error "must define number of sample times, NUMST"
#endif

#ifndef NCSTATES
# error "must define NCSTATES"
#endif

#define QUOTE1(name) #name
#define QUOTE(name) QUOTE1(name)    /* need to expand name    */

/*NOTE: The default location for the .mat file is the root directory of
 * the VxWorks default device which is typically the file system that 
 * VxWorks was booted from.*/

#ifndef SAVEFILE
# define MATFILE2(file) "/" #file ".mat"
# define MATFILE1(file) MATFILE2(file)
# define MATFILE MATFILE1(MODEL)
#else
# define MATFILE QUOTE(SAVEFILE)
#endif

#define RUN_FOREVER -1.0

#define EXPAND_CONCAT(name1,name2) name1 ## name2
#define CONCAT(name1,name2) EXPAND_CONCAT(name1,name2)
#define RT_MODEL            CONCAT(MODEL,_rtModel)

/**********************
 * External functions *
 **********************/

#ifndef RT_MALLOC
  extern void MdlInitializeSizes(void);
  extern void MdlInitializeSampleTimes(void);
  extern void MdlStart(void);
  extern void MdlOutputs(int_T tid);
  extern void MdlUpdate(int_T tid);
  extern void MdlTerminate(void);

#if defined MATLAB_VERSION_2010b || defined MATLAB_VERSION_2011a || defined MATLAB_VERSION_2011b || \
  defined MATLAB_VERSION_2009b || defined MATLAB_VERSION_2009a || defined MATLAB_VERSION_2014a

//#warning compiling for 2009a/b 2010b 2011b
  #if TID01EQ == 1
  #define FIRST_TID 1
  #else
  #define FIRST_TID 0
  #endif

  #define RT_MDL                      MODEL()
  #define INITIALIZE()
  #define INITIALIZE_SIZES(M)         MdlInitializeSizes()
  #define INITIALIZE_SAMPLE_TIMES(M)  MdlInitializeSampleTimes()
  #define START(M)                    MdlStart()
  #define OUTPUTS(M,tid)              MdlOutputs(tid)
  #define UPDATED(M,tid)              MdlUpdate(tid)
  #define TERMINATE(M)                MdlTerminate()
#else
//#warning compiling for >2011b
  
  #define FIRST_TID 0

// matlab 2012:
  #define INITIALIZE                  CONCAT(MODEL,_initialize)
  #define INITIALIZE_SIZES(M)         
  #define INITIALIZE_SAMPLE_TIMES(M) 
  #define START(M)                    
  #define RT_MDL                      CONCAT(MODEL,_M)
  #if ONESTEPFCN == 1
    #define OUTPUTS(M,tid)            CONCAT(MODEL,_step)(tid)
    #define UPDATED(M,tid)            CONCAT(MODEL,_step)(tid)
  #else
    #define OUTPUTS(M,tid)            CONCAT(MODEL,_output)(tid)
    #define UPDATED(M,tid)            CONCAT(MODEL,_update)(tid)
  #endif
  #define TERMINATE(M)                CONCAT(MODEL,_terminate)()
#endif

#else
  #define INITIALIZE_SIZES(M) \
          rtmiInitializeSizes(rtmGetRTWRTModelMethodsInfo(M));
  #define INITIALIZE_SAMPLE_TIMES(M) \
          rtmiInitializeSampleTimes(rtmGetRTWRTModelMethodsInfo(M));
  #define START(M) \
          rtmiStart(rtmGetRTWRTModelMethodsInfo(M));
  #define OUTPUTS(M,tid) \
          rtmiOutputs(rtmGetRTWRTModelMethodsInfo(M),tid);
  #define UPDATED(M,tid) \
          rtmiUpdate(rtmGetRTWRTModelMethodsInfo(M),tid);
  #define TERMINATE(M) \
          rtmiTerminate(rtmGetRTWRTModelMethodsInfo(M))

  const char *RT_MEMORY_ALLOCATION_ERROR = "memory allocation error"; 
#endif



#if NCSTATES > 0
  extern void rt_ODECreateIntegrationData(RTWSolverInfo *si);
  extern void rt_ODEUpdateContinuousStates(RTWSolverInfo *si);

# define rt_CreateIntegrationData(S) \
    rt_ODECreateIntegrationData(rtmGetRTWSolverInfo(S));
# define rt_UpdateContinuousStates(S) \
    rt_ODEUpdateContinuousStates(rtmGetRTWSolverInfo(S));
# else
# define rt_CreateIntegrationData(S)  \
      rtsiSetSolverName(rtmGetRTWSolverInfo(S),"FixedStepDiscrete");
# define rt_UpdateContinuousStates(S) \
      rtmSetT(S, rtsiGetSolverStopTime(rtmGetRTWSolverInfo(S)));
#endif

/***************
 * Global data *
 ***************/

static RT_MODEL *rtM;

sem_t startStopSem;
sem_t           upload_sem;

#ifdef EXT_MODE
#  define rtExtModeSingleTaskUpload(S)                          \
   {                                                            \
        int stIdx;                                              \
        rtExtModeUploadCheckTrigger(rtmGetNumSampleTimes(rtM)); \
        for (stIdx=0; stIdx<NUMST; stIdx++) {                   \
            if (rtmIsSampleHit(S, stIdx, 0 /*unused*/)) {       \
                rtExtModeUpload(stIdx,rtmGetTaskTime(S,stIdx)); \
            }                                                   \
        }                                                       \
   }
#else
#  define rtExtModeSingleTaskUpload(S) /* Do nothing */
#endif

/*******************
 * Local functions *
 *******************/

#ifdef STETHOSCOPE
/* Function: rtInstallRemoveSignals =========================================
 * Abstract:
 *  Setup for stethoscope usage
 */
static int_T rtInstallRemoveSignals(RT_MODEL *rtM, char_T *installStr,
				     int_T fullNames, int_T install)
{

  rtwCAPI_ModelMappingInfo *mmi;
  void                     **dataAddrMap;
  rtwCAPI_Signals          const *sig;
  rtwCAPI_DataTypeMap      const *dtMap;
  rtwCAPI_DimensionMap     const *dimMap;
  uint_T                   const *dimArray;
  uint_T                   dimArrayIdx;
  uint_T                   numDims;
  uint16_T                 dtIdx;
  uint_T                   signalAddrIdx;
  char_T                   const *signalName;
  uint16_T                 dimIndex;
  uint16_T                 portNumber;
  char_T                   const *blockName;
  char_T                   name[1024];
  char_T                   *tmpName;
  uint_T                   i, w, idx;
  int_T                    ret = -1;
  uint_T                   sigWidth;

  if (installStr == NULL) {
    return -1;
  }

  mmi = &(rtmGetDataMapInfo(rtM).mmi);

  if (mmi == NULL) {
      return -1;
  }

  dataAddrMap = rtwCAPI_GetDataAddressMap(mmi);
  sig         = rtwCAPI_GetSignals(mmi);
  dtMap       = rtwCAPI_GetDataTypeMap(mmi);
  dimMap      = rtwCAPI_GetDimensionMap(mmi);
  dimArray    = rtwCAPI_GetDimensionArray(mmi);

  if ((dataAddrMap == NULL) || (sig    == NULL) || (dtMap == NULL) ||
      (dimArray    == NULL) || (dimMap == NULL) ){
      return -1;
  }

  i = 0;
  while (rtwCAPI_GetSignalBlockPath(sig,i) != NULL)
  {
      dtIdx         = rtwCAPI_GetSignalDataTypeIdx(sig,i);
      signalAddrIdx = rtwCAPI_GetSignalAddrIdx(sig, i);
      signalName    = rtwCAPI_GetSignalName(sig, i);
      dimIndex      = rtwCAPI_GetSignalDimensionIdx(sig, i);
      portNumber    = rtwCAPI_GetSignalPortNumber(sig, i);
      blockName     = rtwCAPI_GetSignalBlockPath(sig,i);
      dimIndex      = rtwCAPI_GetSignalDimensionIdx(sig, i);
      numDims       = rtwCAPI_GetNumDims(dimMap, dimIndex); 
      dimArrayIdx   = rtwCAPI_GetDimArrayIndex(dimMap, dimIndex);

      if(!fullNames) {
          tmpName = strrchr(blockName, '/');
          if (tmpName != NULL) {
              blockName = &tmpName[1];
          }   
      }

      if ((*installStr) != '*')
          if (strcmp("[A-Z]*", installStr) == 0) {
              if (!isupper(*blockName)) {
                  continue;
              }
          } else {
              if (strncmp(blockName, installStr, strlen(installStr)) != 0) {
                  continue;
              }
          }

      sigWidth = 1;
      for(idx=0; idx < numDims; idx++) {
          sigWidth *= dimArray[dimArrayIdx + idx];
      }
      
      for (w = 0; w < sigWidth; w++) {
          sprintf(name, "%s_%d_%s_%d", blockName, portNumber, signalName, w);
          if (install) { /*install*/
              if (!ScopeInstallSignal(name,
                                      "units", 
                                      dataAddrMap[signalAddrIdx] + 
                                      w * dtMap[dtIdx].dataSize,
                                      dtMap[dtIdx].cDataName,
                                      0)) {
                  fprintf(stderr,"rtInstallRemoveSignals: ScopeInstallSignal "
                          "possible error: over 256 signals.\n");
                  return -1;
              } else {
                  ret =0;
              }
          } else { /*remove*/
              if (!ScopeRemoveSignal(name, 0)) {
                  fprintf(stderr,"rtInstallRemoveSignals: ScopeRemoveSignal\n"
                          "%s not found.\n",name);
              } else {
                  ret =0;
              }
          }
      }

      i++;
  } /* while (rtwCAPI_GetSignalBlockPath(sig,i) != NULL)*/

  return ret;
}
#endif	/* STETHOSCOPE */

#ifndef NO_TIMER

#define GET_SECONDS(sec)       ((int)sec)
#define GET_NANOSECONDS(sec)   (((int)(sec*1000000000))%1000000000)
#define TIMER_SIGNAL           34

sem_t timer_sync_sem;
timer_t timer_id;
struct itimerspec value;
struct sigaction act;
struct sigevent se;

void timer_handler(int signum) {
    switch (signum) {
        case TIMER_SIGNAL:
            sem_post(&timer_sync_sem);
            break;
        default:
            printf("unknown signal %d\n", signum);
            break;
    }
}


#ifdef EXTERNAL_TIMER
#define EXTERNAL_TIMER_CREATE   CONCAT(EXTERNAL_TIMER_PREFIX, create)
#define EXTERNAL_TIMER_DESTROY  CONCAT(EXTERNAL_TIMER_PREFIX, destroy)
extern int EXTERNAL_TIMER_CREATE(sem_t *timer_sync_sem);
extern int EXTERNAL_TIMER_DESTROY();
#else /* !EXTERNAL_TIMER */

/* Function: rtTimerCreate =====================================================
 * Abstract:
 *  This routine creates all necessary object for a posix timer 
 *
 * Returns: 
 *	Success of timer creation 
 *
 */
static int_T rtTimerCreate() {
    int ret = 0;

    /* set up sync semaphore */
    sem_init(&timer_sync_sem, 1, 0);

    /* set up signal handler for timer signal */
    sigfillset(&act.sa_mask); 
    act.sa_flags = 0;
    act.sa_handler = timer_handler;
    sigaction(TIMER_SIGNAL, &act, NULL);

    /* set up timer to send out signal */
    se.sigev_notify = SIGEV_SIGNAL;
    se.sigev_signo = TIMER_SIGNAL;
    se.sigev_value.sival_int = 0;

    if (timer_create(CLOCK_REALTIME, &se, &timer_id) == -1) {        
        perror("timer_create");
        ret = -1;
    }

    return ret;
}

/* Function: rtTimerDestroy ====================================================
 * Abstract:
 *  This routine destroys all objects of the posix timer 
 *
 * Returns: 
 *	Success of timer destruction 
 *
 */
static int_T rtTimerDestroy() {
    timer_delete(timer_id);
    sem_destroy(&timer_sync_sem);

    return 0;
}

/* Function: rtSetSampleRate ===================================================
 * Abstract:
 *	This routine changes the interrupt frequency to the closest available
 *	approximation to ``requestedSR''.  This will not in general be 
 *	exactly the same as requestedSR, as the hardware timer being used has 
 *	a finite resolution.  This routine sets the sample rate of the fastest 
 *	loop rate.  The other models (if present) are set to their appropriate
 *	scaled values.
 *
 *	StethoScope and the model (via rtmSetStepSize) are informed of the 
 *	change, being careful to provide the actual rate in effect (since it 
 *	may be rounded).  However, there is no guarantee the model will 
 *	calculate reasonable results with at the new rate.
 *
 * Returns: 
 *	The actual sample rate achieved.
 *
 */
static real_T rtSetSampleRate(real_T requestedSR) {
    int ret = 0;

    value.it_value.tv_sec = GET_SECONDS(requestedSR);
    value.it_value.tv_nsec = GET_NANOSECONDS(requestedSR);
    value.it_interval.tv_sec = GET_SECONDS(requestedSR);
    value.it_interval.tv_nsec = GET_NANOSECONDS(requestedSR);

    if (timer_settime(timer_id, 0, &value, NULL) == -1) {
        perror("timer_settime");
        ret = -1;
    }
 
    return ret;
}
#endif /* !EXTERNAL_TIMER */

#endif /* !NO_TIMER */

extern boolean_T ext_mode_stop;


#ifdef MULTITASKING

typedef struct SubRate_Parameters {
    RT_MODEL *rtM;
    sem_t    *pTriggerSem;
    int_T     i;
    int       priority;
} SubRate_Parameters_t;

/* Function: tSubRate ==========================================================
 * Abstract:
 *  This is the entry point for each sub-rate task.  This task simply executes
 *  the appropriate  blocks in the model each time the passed semaphore is
 *  given.  This routine never returns.
 */
static void* SubRate_Thread(void* arg) {
    SubRate_Parameters_t *params = (SubRate_Parameters_t*)arg;

    struct sched_param param;
    param.sched_priority = params->priority;

    /* scheduling parameters of current thread */
    if (pthread_setschedparam(pthread_self(), SCHED_FIFO, &param) == -1)
        perror("pthread_setschedparam");

    while(!rtmGetStopRequested(params->rtM)) {
        sem_wait(params->pTriggerSem);

        if (rtmGetStopRequested(params->rtM))
            break;

        OUTPUTS(params->rtM, params->i);
#ifdef EXT_MODE
        rtExtModeUpload(params->i, rtmGetTaskTime(params->rtM, params->i));
#endif
        UPDATED(params->rtM, params->i);

        rt_SimUpdateDiscreteTaskTime(rtmGetTPtr(params->rtM),
                rtmGetTimingData(params->rtM), params->i);
    }

    return NULL;
} /* end tSubRate */

typedef struct BaseRate_Parameters {
    RT_MODEL *rtM;
    sem_t    *pStartStopSem;
    sem_t    *pTaskSemList;
    int       priority;
    int       affinity_mask;
} BaseRate_Parameters_t;

/* Function: tBaseRate =========================================================
 * Abstract:
 *  This is the entry point for the base-rate task.  This task executes
 *  the fastest rate blocks in the model each time its semaphore is given
 *  and gives semaphores to the sub tasks if they need to execute.
 */
static void* BaseRate_Thread(void* arg) {

    BaseRate_Parameters_t *params = (BaseRate_Parameters_t*)arg;
    int_T  i;
    real_T tnext;
    int_T  finalstep = 0;
    int_T  *sampleHit = rtmGetSampleHitPtr(params->rtM);

    struct sched_param param;
    param.sched_priority = params->priority;

    /* scheduling parameters of current thread */
    if (pthread_setschedparam(pthread_self(), SCHED_FIFO, &param) == -1)
        perror("pthread_setschedparam");

    if (params->affinity_mask != 0xF) {
        int i;

#ifdef __QNX__
        ThreadCtl(_NTO_TCTL_RUNMASK, (void *)params->affinity_mask); 
#else
        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        for (i = 0; i < 32; ++i)
            if (params->affinity_mask & (1 << i))
                CPU_SET(i, &cpuset);

        if (pthread_setaffinity_np(pthread_self(), sizeof(cpuset), &cpuset) != 0)
            perror("pthread_setaffinity_np");
#endif
    }

#ifndef NO_TIMER
    /* take all signalled timer ticks to avoid timer overrun on startup */
    while (sem_trywait(&timer_sync_sem) == 0);
#endif

    while(!rtmGetStopRequested(params->rtM)) {
        /***********************************
         * Check and see if stop requested *
         ***********************************/
        if (rtmGetStopRequested(params->rtM)) {
            sem_post(params->pStartStopSem);
            break;
        }

        /***************************************
         * Check and see if final time reached *
         ***************************************/
        if (rtmGetTFinal(params->rtM) != RUN_FOREVER &&
            rtmGetTFinal(params->rtM)-rtmGetT(params->rtM) <= rtmGetT(params->rtM)*DBL_EPSILON) {
            if (finalstep) {
                sem_post(params->pStartStopSem);
                break;
            }
            finalstep = 1;
        }

        /***********************************************
         * Check and see if error status has been set  *
         ***********************************************/
        if (rtmGetErrorStatus(params->rtM) != NULL) {
            fprintf(stderr,"%s\n", rtmGetErrorStatus(params->rtM));
            sem_post(params->pStartStopSem);
            break;
        }

#ifndef NO_TIMER
        /* wait for timer */
        if (sem_trywait(&timer_sync_sem) == 0) {
            printf("timer overrun detected\n");
#ifdef ENSURE_HARD_REALTIME
            break;
#endif
        }

        while (sem_wait(&timer_sync_sem) == -1) {
            switch (errno) {
                case EINTR:
                    break;
                default:
                    printf("sem_wait returned %s\n", strerror(errno));
                    break;
            }
        }
#endif

        tnext = rt_SimUpdateDiscreteEvents(rtmGetNumSampleTimes(params->rtM),
                                           rtmGetTimingData(params->rtM),
                                           rtmGetSampleHitPtr(params->rtM),
                                           rtmGetPerTaskSampleHitsPtr(params->rtM));
        rtsiSetSolverStopTime(rtmGetRTWSolverInfo(params->rtM),tnext);
        for (i = FIRST_TID + 1; i < NUMST; i++) {
            if (sampleHit[i]) {
                /* Signal any lower priority tasks that have a hit,
                 * then check to see if task took sema (i.e. is it  
                 * blocking).  If not, it means that task did not 
                 * finish in its alloted time period.
                 *
                 * NOTE:These tasks won't run until tBaseRate blocks
                 * on semTake(sem, WAIT_FOREVER) above.
                 */
                sem_post(&params->pTaskSemList[i]);
            }
        }

        /*******************************************
         * Step the model for the base sample time *
         *******************************************/
        OUTPUTS(params->rtM, FIRST_TID);

#ifdef EXT_MODE
        rtExtModeUploadCheckTrigger(rtmGetNumSampleTimes(params->rtM));
        rtExtModeUpload(FIRST_TID,rtmGetTaskTime(params->rtM, FIRST_TID));
#endif

#ifdef MAT_FILE
        if (rt_UpdateTXYLogVars(rtmGetRTWLogInfo(params->rtM),
                                rtmGetTPtr(params->rtM)) != NULL) {
            fprintf(stderr,"rt_UpdateTXYLogVars() failed\n");
            break;
        }
#endif

#ifdef STETHOSCOPE
        ScopeCollectSignals(0);
#endif

        UPDATED(params->rtM, FIRST_TID);

        if (rtmGetSampleTime(params->rtM,0) == CONTINUOUS_SAMPLE_TIME) {
            rt_UpdateContinuousStates(params->rtM);
        } else {
            rt_SimUpdateDiscreteTaskTime(rtmGetTPtr(params->rtM),
                                         rtmGetTimingData(params->rtM),0);
        }
#if FIRST_TID == 1
        rt_SimUpdateDiscreteTaskTime(rtmGetTPtr(params->rtM),
                                     rtmGetTimingData(params->rtM),1);
#endif

#ifdef EXT_MODE
        rtExtModeCheckEndTrigger();
        
        if (ext_mode_stop) {
            printf("got ext mode stop request ...\n");

            rtmSetStopRequested(rtM, 1);
        }
#endif
    }  /* end while(1) */

    rtmSetStopRequested(rtM, 1);

    for (i = FIRST_TID + 1; i < NUMST; ++i)
        sem_post(&params->pTaskSemList[i]);

    sem_post(params->pStartStopSem);
    return NULL;
} /* end tBaseRate */

#else /*SingleTasking*/

typedef struct SingleRate_Parameters {
    RT_MODEL *rtM;
    sem_t    *pStartStopSem;
    int       priority;
    int       affinity_mask;
} SingleRate_Parameters_t;

unsigned long long cps = 0;
unsigned long long myrdtsc(void) 
{ unsigned a, d; __asm__ volatile("rdtsc" : "=a" (a), "=d" (d)); 
    return ((unsigned long long)a) | (((unsigned long long)d) << 32); }


/* Function: tSingleRate ========================================================
 * Abstract:
 *  This is the entry point for the single-rate task.  This task executes
 *      all required blocks in the model each time its semaphore is given.
 */
static void* SingleRate_Thread(void* arg) {
    SingleRate_Parameters_t *params = (SingleRate_Parameters_t*)arg;
    real_T tnext;
    int_T  finalstep = 0;

    struct sched_param param;
    param.sched_priority = params->priority;

    /* scheduling parameters of current thread */
    if (pthread_setschedparam(pthread_self(), SCHED_FIFO, &param) == -1)
        perror("pthread_setschedparam");

    if (params->affinity_mask != 0xF) {
#ifdef __QNX__
        ThreadCtl(_NTO_TCTL_RUNMASK, (void *)params->affinity_mask);
#elif defined __VXWORKS__
        int i;
        cpuset_t affinity;
        CPUSET_ZERO(affinity);
        for (i = 0; i < 32; ++i)
            if (params->affinity_mask & (1 << i))
                CPUSET_SET(affinity, i);
     
        if (taskCpuAffinitySet (0, affinity) == ERROR)
            perror("taskCpuAffinitySet");
#else
        int i;
        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        for (i = 0; i < 32; ++i)
            if (params->affinity_mask & (1 << i))
                CPU_SET(i, &cpuset);

        if (pthread_setaffinity_np(pthread_self(), sizeof(cpuset), &cpuset) != 0)
            perror("pthread_setaffinity_np");
#endif
    }

    /* calibrate cps */
    cps = myrdtsc();
    sleep(1);
    cps = myrdtsc() - cps;
    unsigned long long lastclk = 0;

#ifndef NO_TIMER
    /* take all signalled timer ticks to avoid timer overrun on startup */
    while (sem_trywait(&timer_sync_sem) == 0);
#endif

    while(!rtmGetStopRequested(params->rtM)) {
        /* Check and see if final time reached */
        if (rtmGetTFinal(params->rtM) != RUN_FOREVER &&
            rtmGetTFinal(params->rtM)-rtmGetT(params->rtM) <= rtmGetT(params->rtM)*DBL_EPSILON) {
            if (finalstep)
                break;
            finalstep = 1;
        }

        /* Check and see if error status has been set  */
        if (rtmGetErrorStatus(params->rtM) != NULL) {
            fprintf(stderr,"%s\n", rtmGetErrorStatus(params->rtM));
            break;
        }

#ifndef NO_TIMER
        /* wait for timer */
        if (sem_trywait(&timer_sync_sem) == 0) {
            unsigned long long actclk = myrdtsc();

            printf("timer overrun detected, last tick was %.3f us ago\n",
                    ((double)(actclk - lastclk))/cps * 1000000);
#ifdef ENSURE_HARD_REALTIME
            break;
#endif
        }

        while (sem_wait(&timer_sync_sem) == -1) {
            switch (errno) {
                case EINTR:
                    break;
                default:
                    printf("sem_wait returned %s\n", strerror(errno));
                    break;
            }
        }
#endif
        lastclk = myrdtsc();

#if defined(RT_MALLOC)
        tnext = rt_SimGetNextSampleHit(rtmGetTimingData(rtM),
                                       rtmGetNumSampleTimes(rtM));
#else
        tnext = rt_SimGetNextSampleHit();
#endif
        rtsiSetSolverStopTime(rtmGetRTWSolverInfo(params->rtM),tnext);

#ifdef LTTNG
        tracef("before MDL OUTPUTS");
#endif

        /* Step the model for the all sample times */
        OUTPUTS(params->rtM, 0);

#ifdef LTTNG
        tracef("after MDL OUTPUTS");
#endif

#ifdef EXT_MODE
        rtExtModeSingleTaskUpload(params->rtM);
#endif

#ifdef MAT_FILE
        if (rt_UpdateTXYLogVars(rtmGetRTWLogInfo(params->rtM),
                                rtmGetTPtr(params->rtM)) != NULL) {
            fprintf(stderr,"rt_UpdateTXYLogVars() failed\n");
            break;
        }
#endif

#ifdef STETHOSCOPE
        ScopeCollectSignals(0);
#endif

        UPDATED(params->rtM,0);
        rt_SimUpdateDiscreteTaskSampleHits(rtmGetNumSampleTimes(params->rtM),
                                           rtmGetTimingData(params->rtM),
                                           rtmGetSampleHitPtr(params->rtM),
                                           rtmGetTPtr(params->rtM));

        if (rtmGetSampleTime(params->rtM,0) == CONTINUOUS_SAMPLE_TIME) {
            rt_UpdateContinuousStates(params->rtM);
        }

#ifdef EXT_MODE
        rtExtModeCheckEndTrigger();
         
        if (ext_mode_stop) {
            printf("got ext mode stop request ...\n");
        
            rtmSetStopRequested(rtM, 1);
        }
#endif
    }  /*end while(1)*/

    sem_post(params->pStartStopSem);

    return NULL;
} /* end tSingleRate */

#endif /*MULTITASKING*/

/* Function: rt_main ===========================================================
 * Abstract:
 *  Initialize the Simulink model pointed to by "model_name" and start
 *  model execution.
 *
 *  This routine spawns a task to execute the passed model.  It will 
 *  optionally initialize StethoScope (via ScopeInitServer), if it hasn't
 *  already been done.  It also optionally sets up external mode 
 *  communications channels to Simulink.
 *
 * Parameters:
 *  
 *  "model_name" is the entry point for the Simulink-generated code 
 *  and is the same as the Simulink block diagram model name.
 *
 *  "optStr" is an option string of the form:
 *      -option1 val1 -option2 val2 -option3
 *
 *      for example, "-tf 20 -w" instructs the target program to use a stop time
 *      of 20 and to wait (in external mode) for a message from Simulink
 *      before starting the "simulation".  Note that -tf inf sets the stop time to
 *      infinity.
 *
 *  "scopeInstallString" determines which signals will be installed to
 *  StethoScope.  If scopeInstallString is NULL (the default) no signals
 *  are installed.  If it is "*", then all signals are installed.  If it
 *  is "[A-Z]*", signals coming from blocks whose names start with capital
 *  letters will be installed. If it is any other string, then signals 
 *  starting with that string are installed.  
 *
 *  "scopeFullNames" parameter determines how signals are named: if
 *  0, the block names are used, if 1, then the full hierarchical 
 *  name is used.
 *
 *  "priority" is the priority at which the model's highest priority task
 *  will run.  Other model tasks will run at successively lower priorities
 *  (i.e., high priority numbers).
 *
 * Example:
 *  To run the equalizer example from windsh, with printing of external mode
 *  information, use:
 *  
 *      sp(rt_main,vx_equal,"0.0", "*", 0, 30)
 *
 * Returns:
 *  EXIT_SUCCESS on success.
 *  EXIT_FAILURE on failure.
 */
#include  <stdio.h>
#include  <signal.h>

extern RT_MODEL* MODEL(void);

/* Function: sig_handler ===========================================================
 * Abstract:
 *  Attaches to SIGINT and stops model execution
 *
 * Parameters:
 *  
 *  "sig" is the signal number received
 */
void sig_handler(int sig) {

    printf("\nsignal %d received, shutting down ...\n", sig);
    rtmSetStopRequested(rtM, 1);
}

int usage(const char name[]) {
    printf("usage: %s [-p <priority>] "
#ifdef EXT_MODE
            "[-l <listening port>] "
#endif
            "[-t <final time>] "
#if !defined EXTERNAL_TIMER && !defined NO_TIMER
            "[-s <sample rate>] "
#endif
            "\n\n", name);
    printf(" -p <priority>         specify base model priority\n");
#ifdef EXT_MODE
    printf(" -l <listening port>   listening port for external mode connection\n");
#endif
    printf(" -t <final time>       final time value or 'inf'\n");
#if !defined EXTERNAL_TIMER && !defined NO_TIMER
    printf(" -s <sample rate>      specify sample rate (0 use block trigger)\n");
#endif
    return -1;
}

enum state_color {
    green = 0,
    red
};

void print_state(enum state_color col, const char text[]) {
    switch (col) {
        default:
        case green:
            printf("\033[500C\033[%dD\033[1;32m%s\033[0m\n", strlen(text), text);
            break;
        case red:
            printf("\033[500C\033[%dD\033[1;31m%s\033[0m\n", strlen(text), text);
            break;
    }
}

int main(int argc, char** argv) {
    int_T priority = BASE_PRIORITY;
    double finaltime = -2.0;
    double sample_rate = -1;
    int finished = 0; 
    const char *status;
    pthread_t  pids[NUMST];
    int i;
#ifndef MULTITASKING
	SingleRate_Parameters_t srp;
#endif

    printf("posix target for matlab/simulink 2010b realtime workshop\n\n");
    signal(SIGINT, sig_handler);
    signal(SIGHUP, sig_handler);
    signal(SIGTERM, sig_handler);

    for (i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            /* show help page */
            return usage(argv[0]);
        }
        if (strcmp(argv[i], "-p") == 0) {
            /* parse priority */
            if (++i >= argc)
                return usage(argv[0]);

            priority = atoi(argv[i]);
        } else if (strcmp(argv[i], "-t") == 0) {
            /* parse listening port */
            if (++i >= argc) {
                printf("-t must be followed by final time value or 'inf'!\n");
                return usage(argv[0]);
            }

            if (strcmp(argv[i], "inf") == 0) 
                finaltime = RUN_FOREVER;
            else
                finaltime = atof(argv[i]);
        } 
#if !defined EXTERNAL_TIMER && !defined NO_TIMER
        else if (strcmp(argv[i], "-s") == 0) {
            /* parse sample rate */
            if (++i >= argc) {
                printf("-s must be followed by sample rate!\n");
                return usage(argv[0]);
            }

            sample_rate = atof(argv[i]);
        } 
#endif
    }

#ifdef EXT_MODE
    rtExtModeParseArgs(argc, (const char_T **)argv, NULL);
#endif

    /* Initialize the model */
#ifdef RTW_HEADER_rt_nonfinite_h_
    rt_InitInfAndNaN(sizeof(real_T));
#endif
    
    printf("model registration"); fflush(stdout);
    rtM = RT_MDL;
    if (!rtM) {
        printf("memory allocation error\n");
        exit(EXIT_FAILURE);    
    }
    INITIALIZE();
    if (rtmGetErrorStatus(rtM) != NULL) {
        printf("error : %s\n",rtmGetErrorStatus(rtM));
        TERMINATE(rtM);
        exit(EXIT_FAILURE);
    }
    print_state(green, "done");

    if (finaltime == -2.0)
        finaltime = rtmGetTFinal(rtM);

    printf("setting final time"); fflush(stdout);
    if (finaltime >= 0.0 || finaltime  == RUN_FOREVER) {
        rtmSetTFinal(rtM, (real_T)finaltime);

        if (finaltime == RUN_FOREVER)
            print_state(green, "infinity");
        else {
            char buf[16];
            snprintf(buf, sizeof(buf), "%.3f sec", finaltime);
            print_state(green, buf);
        }
    } else 
        print_state(red, "error");

    printf("initializing sample time engine"); fflush(stdout);
    INITIALIZE_SIZES(rtM);
    INITIALIZE_SAMPLE_TIMES(rtM);
    status = rt_SimInitTimingEngine(rtmGetNumSampleTimes(rtM),
            rtmGetStepSize(rtM),
            rtmGetSampleTimePtr(rtM),
            rtmGetOffsetTimePtr(rtM),
            rtmGetSampleHitPtr(rtM),   
            rtmGetSampleTimeTaskIDPtr(rtM),
            rtmGetTStart(rtM),
            &rtmGetSimTimeStep(rtM),
            &rtmGetTimingData(rtM));

    if (status != NULL) {
        printf("failed : %s\n", status);
        exit(EXIT_FAILURE);
    }
    print_state(green, "done");

    printf("creating integration data"); fflush(stdout);
    rt_CreateIntegrationData(rtM);
#if defined(RT_MALLOC) && NCSTATES > 0
    if(rtmGetErrorStatus(rtM) != NULL) {
        printf("error\n");
        rt_ODEDestroyIntegrationData(rtmGetRTWSolverInfo(rtM));
        TERMINATE(rtM);
        exit(EXIT_FAILURE);
    }
#endif
    print_state(green, "done");
    
#ifdef MAT_FILE
    printf("starting data logging"); fflush(stdout);
    if (rt_StartDataLogging(rtmGetRTWLogInfo(rtM),
                rtmGetTFinal(rtM),
                rtmGetStepSize(rtM),
                &rtmGetErrorStatus(rtM)) != NULL) {
        printf("error\n");
        return(EXIT_FAILURE);
    }
    print_state(green, "done");
#endif

    sem_init(&startStopSem, 1, 0);

#ifdef EXT_MODE
    printf("initializing and starting external mode"); fflush(stdout);
    rtExtModeStartup(rtmGetRTWExtModeInfo(rtM),
                     rtmGetNumSampleTimes(rtM), 
                     priority);
    print_state(green, "done");
#endif

    printf("creating model"); fflush(stdout);
    START(rtM);
    print_state(green, "done");

    if (rtmGetErrorStatus(rtM) != NULL) {
        /* Need to execute MdlTerminate() before we can exit */
        goto TERMINATE;
    }

#ifdef STETHOSCOPE
    /* Make sure that Stethoscope has been properly initialized. */
    ScopeInitServer(4*32*1024, 4*2*1024, 0, 0);
    rtInstallRemoveSignals(rtM, scopeInstallString,scopeFullNames,1);
#endif

    if (sample_rate == -1)
        sample_rate = rtmGetStepSize(rtM);

#ifndef NO_TIMER
#ifdef EXTERNAL_TIMER
    printf("attaching to external timer source"); fflush(stdout);

    /* set up sync semaphore and create timer */
    sem_init(&timer_sync_sem, 1, 0);
    EXTERNAL_TIMER_CREATE(&timer_sync_sem);

    print_state(green, "done");
#else
    printf("setting samplerate to %.6f sec", sample_rate); fflush(stdout);
    rtTimerCreate();
    if (rtSetSampleRate(sample_rate) == 0)
        print_state(green, "done");
    else 
        print_state(red, "error");
#endif
#endif

    /* attributes for thread creation */
    pthread_attr_t attr;
    if (pthread_attr_init(&attr) != 0)
        perror("pthread_attr_init");
    if (pthread_attr_setstacksize(&attr, 0x1000000) != 0)
        perror("pthread_attr_setstacksize");

#ifdef MULTITASKING  
    sem_t rtTaskSemaphoreList[NUMST];
    SubRate_Parameters_t srp[NUMST];

    printf("creating subrate threads "); fflush(stdout);
    for (i = FIRST_TID + 1; i < NUMST; i++) {
        printf("%d ", i); fflush(stdout);

        sem_init(&rtTaskSemaphoreList[i], 1, 0);
        srp[i].rtM = rtM;
        srp[i].pTriggerSem = &rtTaskSemaphoreList[i];
        srp[i].i = i;
        srp[i].priority = priority - i;
        pthread_create(&pids[i], &attr, SubRate_Thread, &srp[i]); 
    }
    print_state(green, "done");

    printf("creating baserate thread"); fflush(stdout);
    BaseRate_Parameters_t brp = {
        .rtM = rtM,
        .pStartStopSem = &startStopSem,
        .pTaskSemList = (sem_t*)rtTaskSemaphoreList,
        .priority = priority,
        .affinity_mask = BASE_THREAD_AFFINITY_MASK };
    pthread_create(&pids[0], &attr, BaseRate_Thread, &brp);
    print_state(green, "done");
#else /* SingleTasking */
    int ret;
    printf("creating singlerate thread"); fflush(stdout);

    srp.rtM = rtM;
    srp.pStartStopSem = &startStopSem;
    srp.priority = priority;
    srp.affinity_mask = BASE_THREAD_AFFINITY_MASK;
    if ((ret = pthread_create(&pids[0], &attr, SingleRate_Thread, &srp)) != 0) {
        print_state(red, strerror(ret));
        return(EXIT_FAILURE);
    }
    print_state(green, "done");
#endif

    /*LTTNG test*/
    #ifdef LTTNG
    printf("Using LTTNG\n");
    #endif

    printf("model is now running\n");

    while(!finished) {
        int ret = sem_wait(&startStopSem);

        if (ret == 0)
            finished = 1;
        else if (ret == -1) {
            switch(errno) {
                case EINTR:
                case EAGAIN:
#ifndef NO_TIMER
                case TIMER_SIGNAL:
#endif
                    /* we were interrupted, just try again */
                    break;
                default:
                    /* we are finished now */
                    perror("sem_wait");
                    finished = 1;
                    break;
            }
        }
    }

    /********************
    * Cleanup and exit *
    ********************/

    printf("waiting until simulation finished"); fflush(stdout);
    pthread_join(pids[0], NULL);
    print_state(green, "done");

#ifdef MULTITASKING
    printf("waiting until subrates are finished "); fflush(stdout);
    for (i = FIRST_TID + 1; i < NUMST; i++) {
        printf("%d ", i); fflush(stdout);
        sem_post(&rtTaskSemaphoreList[i]);
        pthread_join(pids[i], NULL);
    }
    print_state(green, "done");
#endif

#ifndef NO_TIMER
#ifdef EXTERNAL_TIMER
    EXTERNAL_TIMER_DESTROY();
    sem_destroy(&timer_sync_sem);
#else
    rtTimerDestroy();
#endif
#endif
    sem_destroy(&startStopSem);

#ifdef EXT_MODE
    printf("waiting for external mode threads to finish"); fflush(stdout);
    rtExtModeCleanup(rtmGetNumSampleTimes(rtM));
    print_state(green, "done");
#endif

#ifdef STETHOSCOPE
    rtInstallRemoveSignals(rtM, scopeInstallString,scopeFullNames,0);
#endif

TERMINATE:
#ifdef MAT_FILE
    rt_StopDataLogging(MATFILE,rtmGetRTWLogInfo(rtM));
#endif

#if defined(RT_MALLOC) && NCSTATES > 0
    rt_ODEDestroyIntegrationData(rtmGetRTWSolverInfo(rtM));
#endif
    TERMINATE(rtM);

    printf("model successfully terminated!\n");

    return(EXIT_SUCCESS);

}

/* Functions: rt_installSignal, rt_removeSignal=================================
 * Abstract:
 *      Provide functions for users to call from WindSh command prompt that will
 *      install and remove a Blocks' Signals for StethoScope. All output signals
 *      for the Block will be installed/removed.
 *
 * Parameters:
 *      installStr     The name of the Block.
 *      fullNames      Whether or not the installStr is the full path name
 *                     of the Block.
 *                           1 - full hierarchical path name of Block
 *                           0 - name of Block only
 */

#ifdef STETHOSCOPE
int_T rt_installSignal(char_T *installStr, int_T fullNames) {
  return( rtInstallRemoveSignals(rtM, installStr,fullNames, 1));
}
int_T rt_removeSignal(char_T *removeStr, int_T fullNames) {
  return( rtInstallRemoveSignals(rtM, removeStr,fullNames, 0));
}

int_T rt_lkupBlocks(char_T *string) {
  register uint_T          i;
  rtwCAPI_ModelMappingInfo *mmi;
  rtwCAPI_Signals          const *sig;
  char_T                   const *blockName;
  int_T                    ret = -1;

  if (string == NULL) {
    return -1;
  }

  mmi = &(rtmGetDataMapInfo(rtM).mmi);
  if (mmi == NULL) {
      return -1;
  }

  sig = rtwCAPI_GetSignals(mmi);
  if (sig == NULL) {
      return -1;
  }

  if (!strcmp(string,"*")) {
    for(i = 0; i < rtwCAPI_GetNumSignals(mmi); i++) {
        blockName = rtwCAPI_GetSignalBlockPath(sig,i);  
        printf("blockName: %s\n",blockName);
    }
    return 0;
  } else {
      for(i = 0; i < (uint_T) rtmGetNumBlockIO(rtM); i++) {
          blockName = rtwCAPI_GetSignalBlockPath(sig,i);
          if (strstr(blockName,string) != NULL) {
              printf("blockName: %s\n",blockName);
              ret = 0;
          }
      }
      return ret;
  }
  return -1;
} 
#endif

/* [EOF] rt_main.c */
