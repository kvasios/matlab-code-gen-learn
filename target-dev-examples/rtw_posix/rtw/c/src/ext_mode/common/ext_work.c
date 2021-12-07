/*
 * Copyright 1994-2008 The MathWorks, Inc.
 *
 * File: ext_work.c     $Revision: 19727 $
 *
 * Abstract:
 *   
 */
#include <stdio.h>
#include <string.h>        /* optional for strcmp */
#include <stdlib.h>        /* for exit() */
#include <stdint.h>
#include <pthread.h>
#include <semaphore.h>

#include "rtwtypes.h"
#include "rtw_extmode.h"

#include "ext_types.h"
#include "ext_share.h"
#include "updown.h"
#include "ext_svr.h"
#include "ext_svr_transport.h"
#include "ext_work.h" /* includes all VxWorks headers */

int_T           volatile startModel  = FALSE;
TargetSimStatus volatile modelStatus = TARGET_STATUS_WAITING_TO_START;

pthread_mutex_t comm_mutex = PTHREAD_MUTEX_INITIALIZER;
sem_t           upload_sem;
pthread_t       tid_pktserver;
pthread_t       tid_uplserver;
boolean_T       ext_mode_stop = 0;

extern sem_t startStopSem;

typedef struct PktServer_Parameters {
    RTWExtModeInfo *ei;
    int_T priority;
    int_T numSampTimes;
    boolean_T *stopReq;
} PktServer_Parameters_t;

void* PktServer_Thread(void* arg) {
    PktServer_Parameters_t *param = (PktServer_Parameters_t*)arg;

    while (!*param->stopReq) 
        rt_PktServerWork(param->ei, param->numSampTimes, param->stopReq); 

    free(param);

    return NULL;
}

typedef struct UplServer_Parameters {
    int_T priority;
    int_T numSampTimes;
    boolean_T *stopReq;
} UplServer_Parameters_t;

void* UplServer_Thread(void* arg) {
    UplServer_Parameters_t *param = (UplServer_Parameters_t*)arg;

    while (!*param->stopReq) 
        rt_UploadServerWork(param->numSampTimes); 

    free(param);

    return NULL;
}

void rtExtModeStartup(RTWExtModeInfo *ei,
                      int_T          numSampTimes,
                      int_T          priority)
{
    sem_init(&upload_sem, 1, 0);
    rt_ExtModeInit();

    PktServer_Parameters_t *params_pktserver =
        (PktServer_Parameters_t*)malloc(sizeof(PktServer_Parameters_t));
    params_pktserver->ei = ei;
    params_pktserver->priority = priority;
    params_pktserver->numSampTimes = numSampTimes;
    params_pktserver->stopReq = (boolean_T*)&ext_mode_stop;
    pthread_create(&tid_pktserver, NULL, PktServer_Thread, params_pktserver);

    UplServer_Parameters_t *params_uplserver =
        (UplServer_Parameters_t*)malloc(sizeof(UplServer_Parameters_t));
    params_uplserver->priority = priority;
    params_uplserver->numSampTimes = numSampTimes;
    params_uplserver->stopReq = (boolean_T*)&ext_mode_stop;
    pthread_create(&tid_uplserver, NULL, UplServer_Thread, params_uplserver);

    /*
     * Pause until receive model start packet - if external mode.
     * Make sure the external mode tasks are running so that 
     * we are listening for commands from the host.
     */
    if (ExtWaitForStartPkt()) {
        printf("\nWaiting for start packet from host.\n");
        sem_wait(&startStopSem);
    }

    modelStatus = TARGET_STATUS_RUNNING;
}

void rtExtModeCleanup(int_T numSampTimes)
{
    ext_mode_stop = 1;
    sem_post(&upload_sem);
    pthread_join(tid_uplserver, NULL);    
    pthread_join(tid_pktserver, NULL);
    rt_ExtModeShutdown(numSampTimes);
    sem_destroy(&upload_sem);
}

/* Function ====================================================================
 * Pause the process (w/o hogging the cpu) until receive step packet (which
 * means the startModel flag moves to true) or until we are no longer
 * in the paused state.  The packet/upload server must continue to process
 * events (otherwise the host would not be able to communicate with the target).
 */
void rtExtModePauseIfNeeded(RTWExtModeInfo *ei,
                            int_T          numSampTimes,
                            boolean_T      *stopReqPtr)
{
    while((modelStatus == TARGET_STATUS_PAUSED) && 
          !startModel && !(*stopReqPtr)) {
//        rt_ExtModeSleep(0L, 375000L);
        rt_PktServerWork(ei,numSampTimes,stopReqPtr);
        rt_UploadServerWork(numSampTimes);
    }
    startModel = FALSE; /* reset to FALSE - if we were stepped we want to
                         *                  stop again next time we get
                         *                  back here.
                         */
} /* end rtExtModePauseIfNeeded */

/* Function ====================================================================
 * Pause the process (w/o hogging the cpu) until receive start packet
 * from the host.  The packet/upload server must continue to process
 * events (otherwise the host would not be able to communicate with the target).
 */
void rtExtModeWaitForStartPkt(RTWExtModeInfo *ei,
                              int_T          numSampTimes,
                              boolean_T      *stopReqPtr)
{
    /*
     * Pause until receive model start packet.
     */
    if (ExtWaitForStartPkt()) {
        while(!startModel && !(*stopReqPtr)) {
//            rt_ExtModeSleep(0L, 375000L);
            rt_PktServerWork(ei,numSampTimes,stopReqPtr);
            rt_UploadServerWork(numSampTimes);
        }
    }
    if (modelStatus != TARGET_STATUS_PAUSED) {
        modelStatus = TARGET_STATUS_RUNNING;
    } else {
        /* leave in pause mode */
    }
}

void rtExtModeOneStep(RTWExtModeInfo *ei,
                      int_T          numSampTimes,
                      boolean_T      *stopReqPtr)
{
    /*
     * In a multi-tasking environment, this would be removed from the base rate
     * and called as a "background" task.
     */
    if (modelStatus != TARGET_STATUS_PAUSED) {
        rt_PktServerWork(ei,numSampTimes,stopReqPtr);
        rt_UploadServerWork(numSampTimes);
    }
}

void rtExtModeUpload(int_T tid, real_T taskTime)
{
    rt_UploadBufAddTimePoint(tid, taskTime);
}

void rtExtModeCheckEndTrigger(void)
{
    rt_UploadCheckEndTrigger();
}

void rtExtModeUploadCheckTrigger(int_T numSampTimes)
{
    rt_UploadCheckTrigger(numSampTimes);
}

void rtExtModeCheckInit(int_T numSampTimes)
{
    UNUSED_PARAMETER(numSampTimes);
    if (rt_ExtModeInit() != EXT_NO_ERROR) exit(EXIT_FAILURE);
}

void rtExtModeShutdown(int_T numSampTimes)
{
    rt_ExtModeShutdown(numSampTimes);
}

void rtExtModeParseArgs(int_T        argc, 
                        const char_T *argv[],
                        real_T       *unused)
{
    UNUSED_PARAMETER(unused);
    /*
     * Parse the external mode arguments.
     */
    {
        const char_T *extParseErrorPkt = ExtParseArgsAndInitUD(argc, argv);
        if (extParseErrorPkt != NULL) {
            printf(
                "\nError processing External Mode command line arguments:\n");
            printf("\t%s",extParseErrorPkt);

            exit(EXIT_FAILURE);
        }
    }
}

/* Start of ERT specific functions and data */

static void displayUsage(void)
{
    (void) printf("usage: model_name -tf <finaltime> -w -port <TCPport>\n");
    (void) printf("arguments:\n");
    (void) printf("  -tf <finaltime> - overrides final time specified in "
                  "Simulink (inf for no limit).\n");
    (void) printf("  -w              - waits for Simulink to start model "
                  "in External Mode.\n");
    (void) printf("  -port <TCPport> - overrides 17725 default port in "
                  "External Mode, valid range 256 to 65535.\n");
}

static const real_T RUN_FOREVER = (real_T)-1;
#if INTEGER_CODE == 0
static real_T finaltime = (real_T)-2; /* default to stop time in Sim Params. */
#else
static real_T finaltime = (real_T)-1; /* default to stop time inf */
#endif

void rtERTExtModeSetTFinal(real_T *rtmTFinal)
{
    if (finaltime >= (real_T)0 || finaltime == RUN_FOREVER) {
        *rtmTFinal = finaltime;
    }
}

void rtERTExtModeParseArgs(int_T        argc, 
                           const char_T *argv[])
{
    int_T  oldStyle_argc;
    const char_T *oldStyle_argv[5];

    if ((argc > 1) && (argv[1][0] != '-')) {
        /* old style */
        if ( argc > 3 ) {
            displayUsage();
            exit(EXIT_FAILURE);
        }

        oldStyle_argc    = 1;
        oldStyle_argv[0] = argv[0];

        if (argc >= 2) {
            oldStyle_argc = 3;

            oldStyle_argv[1] = "-tf";
            oldStyle_argv[2] = argv[1];
        }

        if (argc == 3) {
            oldStyle_argc = 5;

            oldStyle_argv[3] = "-port";
            oldStyle_argv[4] = argv[2];

        }

        argc = oldStyle_argc;
        argv = oldStyle_argv;

    }

    {
        /* new style: */
        double    tmpDouble;
        char_T tmpStr2[200];
        int_T  count      = 1;
        int_T  parseError = FALSE;

        /*
         * Parse the standard RTW parameters.  Let all unrecognized parameters
         * pass through to external mode for parsing.  NULL out all args handled
         * so that the external mode parsing can ignore them.
         */
        while(count < argc) {
            const char_T *option = argv[count++];

            /* final time */
            if ((strcmp(option, "-tf") == 0) && (count != argc)) {
                const char_T *tfStr = argv[count++];

                sscanf(tfStr, "%200s", tmpStr2);
                if (strcmp(tmpStr2, "inf") == 0) {
                    tmpDouble = RUN_FOREVER;
                } else {
                    char_T tmpstr[2];

#if INTEGER_CODE == 0
                    if ( (sscanf(tmpStr2,"%lf%1s", &tmpDouble, tmpstr) != 1) ||
                         (tmpDouble < (real_T)0) ) {
                        (void)printf("finaltime must be a positive, real value or inf\n");
                        parseError = TRUE;
                        break;
                    }
#else
                    if ( (sscanf(tmpStr2,"%d%1s", &tmpDouble, tmpstr) != 1) ||
                         (tmpDouble < (real_T)0) ) {
                        (void)printf("tmpDouble = %d\n", tmpDouble);
                        (void)printf("finaltime must be a positive, integer value or inf\n");
                        parseError = TRUE;
                        break;
                    }
#endif
                }
                finaltime = (real_T) tmpDouble;

                argv[count-2] = NULL;
                argv[count-1] = NULL;
            }
        }

        if (parseError) {
            (void)printf("\nUsage: model_name -option1 val1 -option2 val2 -option3 "
                         "...\n\n");
            (void)printf("\t-tf 20 - sets final time to 20 seconds\n");

            exit(EXIT_FAILURE);
        }

        /*
         * Parse the external mode arguments.
         */
        {
            const char_T *extParseErrorPkt = ExtParseArgsAndInitUD(argc, argv);
            if (extParseErrorPkt != NULL) {
                printf(
                    "\nError processing External Mode command line arguments:\n");
                printf("\t%s",extParseErrorPkt);

                exit(EXIT_FAILURE);
            }
        }

        /*
         * Check for unprocessed ("unhandled") args.
         */
        {
            int i;
            for (i=1; i<argc; i++) {
                if (argv[i] != NULL) {
                    printf("Unexpected command line argument: %s\n",argv[i]);
                    exit(EXIT_FAILURE);
                }
            }
        }
    }

    if (finaltime == RUN_FOREVER) {
        printf ("\n**warning: the simulation will run with no stop time due "
                "to external mode with '-tf inf' argument.\n");
    }
}

/* End of ERT specific functions and data */

/* [EOF] ext_work.c */

