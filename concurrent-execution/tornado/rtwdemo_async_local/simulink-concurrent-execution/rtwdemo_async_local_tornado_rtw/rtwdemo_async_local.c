/*
 * rtwdemo_async_local.c
 *
 * Sponsored License - for use in support of a program or activity
 * sponsored by MathWorks.  Not for government, commercial or other
 * non-sponsored organizational use.
 *
 * Code generation for model "rtwdemo_async_local".
 *
 * Model version              : 4.1
 * Simulink Coder version : 9.5 (R2021a) 14-Nov-2020
 * C source code generated on : Mon Nov 15 22:12:47 2021
 *
 * Target selection: tornado.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "rtwdemo_async_local.h"
#include "rtwdemo_async_local_private.h"

/* Block signals (default storage) */
B_rtwdemo_async_local_T rtwdemo_async_local_B;

/* Block states (default storage) */
DW_rtwdemo_async_local_T rtwdemo_async_local_DW;

/* External inputs (root inport signals with default storage) */
ExtU_rtwdemo_async_local_T rtwdemo_async_local_U;

/* External outputs (root outports fed by signals with default storage) */
ExtY_rtwdemo_async_local_T rtwdemo_async_local_Y;

/* Real-time model */
static RT_MODEL_rtwdemo_async_local_T rtwdemo_async_local_M_;
RT_MODEL_rtwdemo_async_local_T *const rtwdemo_async_local_M =
  &rtwdemo_async_local_M_;
static void rate_monotonic_scheduler(void);

/* VxWorks Task Block: '<S5>/S-Function' (vxtask1) */
/* Spawned with priority: 50 */
void Task0(void)
{
  /* Wait for semaphore to be released by system: rtwdemo_async_local/Task Sync */
  for (;;) {
    if (semTake(*(SEM_ID *)rtwdemo_async_local_DW.SFunction_PWORK.SemID,NO_WAIT)
        != ERROR) {
      logMsg("Rate for Task Task0() too fast.\n",0,0,0,0,0,0);

#if STOPONOVERRUN

      logMsg("Aborting real-time simulation.\n",0,0,0,0,0,0);
      semGive(stopSem);
      return(ERROR);

#endif

    } else {
      semTake(*(SEM_ID *)rtwdemo_async_local_DW.SFunction_PWORK.SemID,
              WAIT_FOREVER);
    }

    /* Use the upstream clock tick counter for this Task. */
    rtwdemo_async_local_M->Timing.clockTick2 =
      rtwdemo_async_local_M->Timing.clockTick4;

    /* Call the system: '<Root>/Algorithm' */
    {
      int32_T i;
      int32_T i_0;

      /* RateTransition: '<Root>/Protected RT1' */
      i = rtwdemo_async_local_DW.ProtectedRT1_ActiveBufIdx * 60;
      for (i_0 = 0; i_0 < 60; i_0++) {
        rtwdemo_async_local_B.ProtectedRT1[i_0] =
          rtwdemo_async_local_DW.ProtectedRT1_Buffer[i_0 + i];
      }

      /* End of RateTransition: '<Root>/Protected RT1' */

      /* S-Function (vxtask1): '<S5>/S-Function' */

      /* Output and update for function-call system: '<Root>/Algorithm' */
      {
        int32_T i;
        rtwdemo_async_local_M->Timing.clockTick2 =
          rtwdemo_async_local_M->Timing.clockTick4;
        if (rtwdemo_async_local_DW.Algorithm_RESET_ELAPS_T) {
          rtwdemo_async_local_DW.Algorithm_ELAPS_T = 0U;
        } else {
          rtwdemo_async_local_DW.Algorithm_ELAPS_T =
            rtwdemo_async_local_M->Timing.clockTick2 -
            rtwdemo_async_local_DW.Algorithm_PREV_T;
        }

        rtwdemo_async_local_DW.Algorithm_PREV_T =
          rtwdemo_async_local_M->Timing.clockTick2;
        rtwdemo_async_local_DW.Algorithm_RESET_ELAPS_T = false;

        /* DiscreteIntegrator: '<S1>/Integrator' */
        if (rtwdemo_async_local_DW.Integrator_SYSTEM_ENABLE == 0) {
          /* DiscreteIntegrator: '<S1>/Integrator' */
          rtwdemo_async_local_DW.Integrator_DSTATE += 0.016666666666666666 *
            (real_T)rtwdemo_async_local_DW.Algorithm_ELAPS_T
            * rtwdemo_async_local_DW.Integrator_PREV_U;
        }

        /* End of DiscreteIntegrator: '<S1>/Integrator' */

        /* Outport: '<Root>/Out3' incorporates:
         *  SignalConversion generated from: '<S1>/Out2'
         */
        rtwdemo_async_local_Y.Out3 = rtwdemo_async_local_DW.Integrator_DSTATE;

        /* Sum: '<S1>/Sum1' */
        rtwdemo_async_local_DW.Integrator_PREV_U = -0.0;
        for (i = 0; i < 60; i++) {
          /* Sum: '<S1>/Sum' incorporates:
           *  Constant: '<S1>/Offset'
           */
          rtwdemo_async_local_B.Sum[i] = rtwdemo_async_local_B.ProtectedRT1[i] +
            1.25;

          /* Sum: '<S1>/Sum1' */
          rtwdemo_async_local_DW.Integrator_PREV_U +=
            rtwdemo_async_local_B.Sum[i];
        }

        /* Update for DiscreteIntegrator: '<S1>/Integrator' */
        rtwdemo_async_local_DW.Integrator_SYSTEM_ENABLE = 0U;
      }

      /* End of Outputs for S-Function (vxtask1): '<S5>/S-Function' */

      /* RateTransition: '<Root>/Protected RT2' */
      for (i = 0; i < 60; i++) {
        rtwdemo_async_local_DW.ProtectedRT2_Buffer[i +
          (rtwdemo_async_local_DW.ProtectedRT2_ActiveBufIdx == 0) * 60] =
          rtwdemo_async_local_B.Sum[i];
      }

      rtwdemo_async_local_DW.ProtectedRT2_ActiveBufIdx = (int8_T)
        (rtwdemo_async_local_DW.ProtectedRT2_ActiveBufIdx == 0);

      /* End of RateTransition: '<Root>/Protected RT2' */
    }
  }
}

/* VxWorks Interrupt Block: '<Root>/Async Interrupt' */
void isr_num1_vec192(void)
{
  int_T lock;
  FP_CONTEXT context;

  /* Use tickGet()  as a portable tick
     counter example. A much higher resolution can
     be achieved with a hardware counter */
  rtwdemo_async_local_M->Timing.clockTick3 = tickGet();

  /* disable interrupts (system is configured as non-preemptive) */
  lock = intLock();

  /* save floating point context */
  fppSave(&context);

  /* Call the system: '<Root>/Count' */
  {
    /* S-Function (vxinterrupt1): '<Root>/Async Interrupt' */

    /* Output and update for function-call system: '<Root>/Count' */
    if (rtwdemo_async_local_DW.Count_RESET_ELAPS_T) {
      rtwdemo_async_local_DW.Count_ELAPS_T = 0U;
    } else {
      rtwdemo_async_local_DW.Count_ELAPS_T =
        rtwdemo_async_local_M->Timing.clockTick3 -
        rtwdemo_async_local_DW.Count_PREV_T;
    }

    rtwdemo_async_local_DW.Count_PREV_T =
      rtwdemo_async_local_M->Timing.clockTick3;
    rtwdemo_async_local_DW.Count_RESET_ELAPS_T = false;

    /* DiscreteIntegrator: '<S2>/Integrator' */
    if (rtwdemo_async_local_DW.Integrator_SYSTEM_ENABLE_h == 0) {
      /* DiscreteIntegrator: '<S2>/Integrator' */
      rtwdemo_async_local_DW.Integrator_DSTATE_l += 0.016666666666666666 *
        (real_T)rtwdemo_async_local_DW.Count_ELAPS_T
        * rtwdemo_async_local_DW.Integrator_PREV_U_o;
    }

    /* End of DiscreteIntegrator: '<S2>/Integrator' */

    /* Outport: '<Root>/Out1' incorporates:
     *  SignalConversion generated from: '<S2>/Out'
     */
    rtwdemo_async_local_Y.Out1 = rtwdemo_async_local_DW.Integrator_DSTATE_l;

    /* Update for DiscreteIntegrator: '<S2>/Integrator' incorporates:
     *  Constant: '<S2>/Constant'
     */
    rtwdemo_async_local_DW.Integrator_SYSTEM_ENABLE_h = 0U;
    rtwdemo_async_local_DW.Integrator_PREV_U_o = 1.0;

    /* End of Outputs for S-Function (vxinterrupt1): '<Root>/Async Interrupt' */
  }

  /* restore floating point context */
  fppRestore(&context);

  /* re-enable interrupts */
  intUnlock(lock);
}

/* VxWorks Interrupt Block: '<Root>/Async Interrupt' */
void isr_num2_vec193(void)
{
  /* Use tickGet()  as a portable tick
     counter example. A much higher resolution can
     be achieved with a hardware counter */
  rtwdemo_async_local_M->Timing.clockTick4 = tickGet();

  /* Call the system: '<S4>/Subsystem' */
  {
    /* S-Function (vxinterrupt1): '<Root>/Async Interrupt' */

    /* Output and update for function-call system: '<S4>/Subsystem' */

    /* S-Function (vxtask1): '<S5>/S-Function' */

    /* VxWorks Task Block: '<S5>/S-Function' (vxtask1) */
    /* Release semaphore for system task: Task0 */
    semGive(*(SEM_ID *)rtwdemo_async_local_DW.SFunction_PWORK.SemID);

    /* End of Outputs for S-Function (vxtask1): '<S5>/S-Function' */

    /* End of Outputs for S-Function (vxinterrupt1): '<Root>/Async Interrupt' */
  }
}

time_T rt_SimUpdateDiscreteEvents(
  int_T rtmNumSampTimes, void *rtmTimingData, int_T *rtmSampleHitPtr, int_T
  *rtmPerTaskSampleHits )
{
  rtmSampleHitPtr[1] = rtmStepTask(rtwdemo_async_local_M, 1);
  UNUSED_PARAMETER(rtmNumSampTimes);
  UNUSED_PARAMETER(rtmTimingData);
  UNUSED_PARAMETER(rtmPerTaskSampleHits);
  return(-1);
}

/*
 *   This function updates active task flag for each subrate
 * and rate transition flags for tasks that exchange data.
 * The function assumes rate-monotonic multitasking scheduler.
 * The function must be called at model base rate so that
 * the generated code self-manages all its subrates and rate
 * transition flags.
 */
static void rate_monotonic_scheduler(void)
{
  /* Compute which subrates run during the next base time step.  Subrates
   * are an integer multiple of the base rate counter.  Therefore, the subtask
   * counter is reset when it reaches its limit (zero means run).
   */
  (rtwdemo_async_local_M->Timing.TaskCounters.TID[1])++;
  if ((rtwdemo_async_local_M->Timing.TaskCounters.TID[1]) > 2) {/* Sample time: [0.05s, 0.0s] */
    rtwdemo_async_local_M->Timing.TaskCounters.TID[1] = 0;
  }
}

/* Model output function for TID0 */
static void rtwdemo_async_local_output0(void)
                                /* Sample time: [0.016666666666666666s, 0.0s] */
{
  int32_T i;

  {                             /* Sample time: [0.016666666666666666s, 0.0s] */
    rate_monotonic_scheduler();
  }

  /* Switch: '<S3>/Environment Switch' */
  rtwdemo_async_local_B.EnvironmentSwitch[0] = 0.0;
  rtwdemo_async_local_B.EnvironmentSwitch[1] = 0.0;

  /* RateTransition: '<Root>/Protected RT1' incorporates:
   *  Inport: '<Root>/In1_60hz'
   *  Inport: '<Root>/In2_60_hz'
   *  Inport: '<Root>/In3_60hz'
   */
  for (i = 0; i < 20; i++) {
    rtwdemo_async_local_DW.ProtectedRT1_Buffer[i +
      (rtwdemo_async_local_DW.ProtectedRT1_ActiveBufIdx == 0) * 60] =
      rtwdemo_async_local_U.In1_60hz[i];
  }

  for (i = 0; i < 20; i++) {
    rtwdemo_async_local_DW.ProtectedRT1_Buffer[(i +
      (rtwdemo_async_local_DW.ProtectedRT1_ActiveBufIdx == 0) * 60) + 20] =
      rtwdemo_async_local_U.In2_60_hz[i];
  }

  for (i = 0; i < 20; i++) {
    rtwdemo_async_local_DW.ProtectedRT1_Buffer[(i +
      (rtwdemo_async_local_DW.ProtectedRT1_ActiveBufIdx == 0) * 60) + 40] =
      rtwdemo_async_local_U.In3_60hz[i];
  }

  rtwdemo_async_local_DW.ProtectedRT1_ActiveBufIdx = (int8_T)
    (rtwdemo_async_local_DW.ProtectedRT1_ActiveBufIdx == 0);

  /* End of RateTransition: '<Root>/Protected RT1' */
}

/* Model update function for TID0 */
static void rtwdemo_async_local_update0(void)
                                /* Sample time: [0.016666666666666666s, 0.0s] */
{
  /* Update absolute time */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   */
  rtwdemo_async_local_M->Timing.t[0] =
    ((time_T)(++rtwdemo_async_local_M->Timing.clockTick0)) *
    rtwdemo_async_local_M->Timing.stepSize0;
}

/* Model output function for TID1 */
static void rtwdemo_async_local_output1(void) /* Sample time: [0.05s, 0.0s] */
{
  real_T rtb_ProtectedRT2[60];
  int32_T i;
  int32_T i_0;

  /* RateTransition: '<Root>/Protected RT2' */
  i = rtwdemo_async_local_DW.ProtectedRT2_ActiveBufIdx * 60;
  for (i_0 = 0; i_0 < 60; i_0++) {
    rtb_ProtectedRT2[i_0] = rtwdemo_async_local_DW.ProtectedRT2_Buffer[i_0 + i];
  }

  /* End of RateTransition: '<Root>/Protected RT2' */

  /* Sum: '<Root>/Sum' */
  rtwdemo_async_local_Y.Out2 = -0.0;
  for (i = 0; i < 60; i++) {
    rtwdemo_async_local_Y.Out2 += rtb_ProtectedRT2[i];
  }

  /* End of Sum: '<Root>/Sum' */
}

/* Model update function for TID1 */
static void rtwdemo_async_local_update1(void) /* Sample time: [0.05s, 0.0s] */
{
  /* Update absolute time */
  /* The "clockTick1" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick1"
   * and "Timing.stepSize1". Size of "clockTick1" ensures timer will not
   * overflow during the application lifespan selected.
   */
  rtwdemo_async_local_M->Timing.t[1] =
    ((time_T)(++rtwdemo_async_local_M->Timing.clockTick1)) *
    rtwdemo_async_local_M->Timing.stepSize1;
}

/* Model wrapper function for compatibility with a static main program */
static void rtwdemo_async_local_output(int_T tid)
{
  switch (tid) {
   case 0 :
    rtwdemo_async_local_output0();
    break;

   case 1 :
    rtwdemo_async_local_output1();
    break;

   default :
    break;
  }
}

/* Model wrapper function for compatibility with a static main program */
static void rtwdemo_async_local_update(int_T tid)
{
  switch (tid) {
   case 0 :
    rtwdemo_async_local_update0();
    break;

   case 1 :
    rtwdemo_async_local_update1();
    break;

   default :
    break;
  }
}

/* Model initialize function */
static void rtwdemo_async_local_initialize(void)
{
  /* Start for S-Function (vxinterrupt1): '<Root>/Async Interrupt' incorporates:
   *  SubSystem: '<S4>/Subsystem'
   */

  /* Start for function-call system: '<S4>/Subsystem' */

  /* Start for S-Function (vxtask1): '<S5>/S-Function' */

  /* VxWorks Task Block: '<S5>/S-Function' (vxtask1) */
  /* VxWorks binary semaphore for task: Task0 */
  {
    static SEM_ID Task0_semaphore;
    rtwdemo_async_local_DW.SFunction_PWORK.SemID = (void *)&Task0_semaphore;
  }

  /* VxWorks Task Block: '<S5>/S-Function' (vxtask1) */
  /* Spawn task: Task0 with priority 50 */
  *(SEM_ID *)rtwdemo_async_local_DW.SFunction_PWORK.SemID = semBCreate
    (SEM_Q_PRIORITY, SEM_EMPTY);
  if (rtwdemo_async_local_DW.SFunction_PWORK.SemID == NULL) {
    printf("semBCreate call failed for block Task0.\n");
  }

  rtwdemo_async_local_DW.SFunction_IWORK.TaskID = taskSpawn("Task0",
    50.0,
    VX_FP_TASK,
    8192.0,
    (FUNCPTR)Task0,
    0, 0, 0, 0, 0, 0, 0,0, 0, 0);
  if (rtwdemo_async_local_DW.SFunction_IWORK.TaskID == ERROR) {
    printf("taskSpawn call failed for block Task0.\n");
  }

  /* End of Start for S-Function (vxtask1): '<S5>/S-Function' */

  /* VxWorks Interrupt Block: '<Root>/Async Interrupt' */
  /* Connect and enable ISR function: isr_num1_vec192 */
  if (intConnect(INUM_TO_IVEC(192), isr_num1_vec192, 0) != OK) {
    printf("intConnect failed for ISR 1.\n");
  }

  sysIntEnable(1);

  /* VxWorks Interrupt Block: '<Root>/Async Interrupt' */
  /* Connect and enable ISR function: isr_num2_vec193 */
  if (intConnect(INUM_TO_IVEC(193), isr_num2_vec193, 0) != OK) {
    printf("intConnect failed for ISR 2.\n");
  }

  sysIntEnable(2);

  /* End of Start for S-Function (vxinterrupt1): '<Root>/Async Interrupt' */
  {
    int32_T i;

    /* InitializeConditions for RateTransition: '<Root>/Protected RT1' */
    for (i = 0; i < 60; i++) {
      rtwdemo_async_local_DW.ProtectedRT1_Buffer[i] = 0.0;
    }

    /* End of InitializeConditions for RateTransition: '<Root>/Protected RT1' */

    /* InitializeConditions for RateTransition: '<Root>/Protected RT2' */
    for (i = 0; i < 60; i++) {
      rtwdemo_async_local_DW.ProtectedRT2_Buffer[i] = 0.0;
    }

    /* End of InitializeConditions for RateTransition: '<Root>/Protected RT2' */

    /* SystemInitialize for S-Function (vxinterrupt1): '<Root>/Async Interrupt' incorporates:
     *  SubSystem: '<Root>/Count'
     */
    /* System initialize for function-call system: '<Root>/Count' */

    /* InitializeConditions for DiscreteIntegrator: '<S2>/Integrator' */
    rtwdemo_async_local_DW.Integrator_DSTATE_l = 0.0;
    rtwdemo_async_local_DW.Integrator_PREV_U_o = 0.0;

    /* SystemInitialize for Outport: '<Root>/Out1' incorporates:
     *  Outport: '<S2>/Out'
     */
    rtwdemo_async_local_Y.Out1 = 0.0;

    /* SystemInitialize for S-Function (vxinterrupt1): '<Root>/Async Interrupt' incorporates:
     *  SubSystem: '<S4>/Subsystem'
     */
    /* System initialize for function-call system: '<S4>/Subsystem' */

    /* SystemInitialize for S-Function (vxtask1): '<S5>/S-Function' incorporates:
     *  SubSystem: '<Root>/Algorithm'
     */

    /* System initialize for function-call system: '<Root>/Algorithm' */
    rtwdemo_async_local_M->Timing.clockTick2 =
      rtwdemo_async_local_M->Timing.clockTick4;

    /* InitializeConditions for DiscreteIntegrator: '<S1>/Integrator' */
    rtwdemo_async_local_DW.Integrator_DSTATE = 0.0;

    /* InitializeConditions for Sum: '<S1>/Sum1' incorporates:
     *  DiscreteIntegrator: '<S1>/Integrator'
     */
    rtwdemo_async_local_DW.Integrator_PREV_U = 0.0;

    /* SystemInitialize for Sum: '<S1>/Sum' incorporates:
     *  Outport: '<S1>/Out1'
     */
    memset(&rtwdemo_async_local_B.Sum[0], 0, 60U * sizeof(real_T));

    /* SystemInitialize for Outport: '<Root>/Out3' incorporates:
     *  Outport: '<S1>/Out2'
     */
    rtwdemo_async_local_Y.Out3 = 0.0;

    /* End of SystemInitialize for S-Function (vxtask1): '<S5>/S-Function' */

    /* End of SystemInitialize for S-Function (vxinterrupt1): '<Root>/Async Interrupt' */
  }

  /* Enable for S-Function (vxinterrupt1): '<Root>/Async Interrupt' incorporates:
   *  SubSystem: '<Root>/Count'
   */
  /* Enable for function-call system: '<Root>/Count' */
  rtwdemo_async_local_DW.Count_RESET_ELAPS_T = true;

  /* Enable for DiscreteIntegrator: '<S2>/Integrator' */
  rtwdemo_async_local_DW.Integrator_SYSTEM_ENABLE_h = 1U;

  /* Enable for S-Function (vxinterrupt1): '<Root>/Async Interrupt' incorporates:
   *  SubSystem: '<S4>/Subsystem'
   */

  /* Enable for function-call system: '<S4>/Subsystem' */

  /* Enable for S-Function (vxtask1): '<S5>/S-Function' incorporates:
   *  SubSystem: '<Root>/Algorithm'
   */

  /* Enable for function-call system: '<Root>/Algorithm' */
  rtwdemo_async_local_M->Timing.clockTick2 =
    rtwdemo_async_local_M->Timing.clockTick4;
  rtwdemo_async_local_DW.Algorithm_RESET_ELAPS_T = true;

  /* Enable for DiscreteIntegrator: '<S1>/Integrator' */
  rtwdemo_async_local_DW.Integrator_SYSTEM_ENABLE = 1U;

  /* End of Enable for S-Function (vxtask1): '<S5>/S-Function' */

  /* End of Enable for S-Function (vxinterrupt1): '<Root>/Async Interrupt' */
}

/* Model terminate function */
static void rtwdemo_async_local_terminate(void)
{
  /* Terminate for S-Function (vxinterrupt1): '<Root>/Async Interrupt' */

  /* VxWorks Interrupt Block: '<Root>/Async Interrupt' */
  /* Disable interrupt for ISR system: isr_num1_vec192 */
  sysIntDisable(1);

  /* VxWorks Interrupt Block: '<Root>/Async Interrupt' */
  /* Disable interrupt for ISR system: isr_num2_vec193 */
  sysIntDisable(2);

  /* End of Terminate for S-Function (vxinterrupt1): '<Root>/Async Interrupt' */

  /* Terminate for S-Function (vxinterrupt1): '<Root>/Async Interrupt' incorporates:
   *  SubSystem: '<S4>/Subsystem'
   */

  /* Termination for function-call system: '<S4>/Subsystem' */

  /* Terminate for S-Function (vxtask1): '<S5>/S-Function' */

  /* VxWorks Task Block: '<S5>/S-Function' (vxtask1) */
  /* Destroy task: Task0 */
  taskDelete(rtwdemo_async_local_DW.SFunction_IWORK.TaskID);

  /* End of Terminate for S-Function (vxtask1): '<S5>/S-Function' */

  /* End of Terminate for S-Function (vxinterrupt1): '<Root>/Async Interrupt' */
}

/*========================================================================*
 * Start of Classic call interface                                        *
 *========================================================================*/
void MdlOutputs(int_T tid)
{
  rtwdemo_async_local_output(tid);
}

void MdlUpdate(int_T tid)
{
  rtwdemo_async_local_update(tid);
}

void MdlInitializeSizes(void)
{
}

void MdlInitializeSampleTimes(void)
{
}

void MdlInitialize(void)
{
}

void MdlStart(void)
{
  rtwdemo_async_local_initialize();
}

void MdlTerminate(void)
{
  rtwdemo_async_local_terminate();
}

/* Registration function */
RT_MODEL_rtwdemo_async_local_T *rtwdemo_async_local(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)rtwdemo_async_local_M, 0,
                sizeof(RT_MODEL_rtwdemo_async_local_T));

  /* Initialize timing info */
  {
    int_T *mdlTsMap = rtwdemo_async_local_M->Timing.sampleTimeTaskIDArray;
    mdlTsMap[0] = 0;
    mdlTsMap[1] = 1;
    rtwdemo_async_local_M->Timing.sampleTimeTaskIDPtr = (&mdlTsMap[0]);
    rtwdemo_async_local_M->Timing.sampleTimes =
      (&rtwdemo_async_local_M->Timing.sampleTimesArray[0]);
    rtwdemo_async_local_M->Timing.offsetTimes =
      (&rtwdemo_async_local_M->Timing.offsetTimesArray[0]);

    /* task periods */
    rtwdemo_async_local_M->Timing.sampleTimes[0] = (0.016666666666666666);
    rtwdemo_async_local_M->Timing.sampleTimes[1] = (0.05);

    /* task offsets */
    rtwdemo_async_local_M->Timing.offsetTimes[0] = (0.0);
    rtwdemo_async_local_M->Timing.offsetTimes[1] = (0.0);
  }

  rtmSetTPtr(rtwdemo_async_local_M, &rtwdemo_async_local_M->Timing.tArray[0]);

  {
    int_T *mdlSampleHits = rtwdemo_async_local_M->Timing.sampleHitArray;
    int_T *mdlPerTaskSampleHits =
      rtwdemo_async_local_M->Timing.perTaskSampleHitsArray;
    rtwdemo_async_local_M->Timing.perTaskSampleHits = (&mdlPerTaskSampleHits[0]);
    mdlSampleHits[0] = 1;
    rtwdemo_async_local_M->Timing.sampleHits = (&mdlSampleHits[0]);
  }

  rtmSetTFinal(rtwdemo_async_local_M, 0.5);
  rtwdemo_async_local_M->Timing.stepSize0 = 0.016666666666666666;
  rtwdemo_async_local_M->Timing.stepSize1 = 0.05;
  rtwdemo_async_local_M->solverInfoPtr = (&rtwdemo_async_local_M->solverInfo);
  rtwdemo_async_local_M->Timing.stepSize = (0.016666666666666666);
  rtsiSetFixedStepSize(&rtwdemo_async_local_M->solverInfo, 0.016666666666666666);
  rtsiSetSolverMode(&rtwdemo_async_local_M->solverInfo, SOLVER_MODE_MULTITASKING);

  /* block I/O */
  rtwdemo_async_local_M->blockIO = ((void *) &rtwdemo_async_local_B);
  (void) memset(((void *) &rtwdemo_async_local_B), 0,
                sizeof(B_rtwdemo_async_local_T));

  /* states (dwork) */
  rtwdemo_async_local_M->dwork = ((void *) &rtwdemo_async_local_DW);
  (void) memset((void *)&rtwdemo_async_local_DW, 0,
                sizeof(DW_rtwdemo_async_local_T));

  /* external inputs */
  rtwdemo_async_local_M->inputs = (((void*)&rtwdemo_async_local_U));
  (void)memset(&rtwdemo_async_local_U, 0, sizeof(ExtU_rtwdemo_async_local_T));

  /* external outputs */
  rtwdemo_async_local_M->outputs = (&rtwdemo_async_local_Y);
  (void) memset((void *)&rtwdemo_async_local_Y, 0,
                sizeof(ExtY_rtwdemo_async_local_T));

  /* Initialize Sizes */
  rtwdemo_async_local_M->Sizes.numContStates = (0);/* Number of continuous states */
  rtwdemo_async_local_M->Sizes.numY = (3);/* Number of model outputs */
  rtwdemo_async_local_M->Sizes.numU = (60);/* Number of model inputs */
  rtwdemo_async_local_M->Sizes.sysDirFeedThru = (1);/* The model is direct feedthrough */
  rtwdemo_async_local_M->Sizes.numSampTimes = (2);/* Number of sample times */
  rtwdemo_async_local_M->Sizes.numBlocks = (20);/* Number of blocks */
  rtwdemo_async_local_M->Sizes.numBlockIO = (7);/* Number of block outputs */
  return rtwdemo_async_local_M;
}

/*========================================================================*
 * End of Classic call interface                                          *
 *========================================================================*/
