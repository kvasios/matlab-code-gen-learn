/*
 * rtwdemo_async_local_private.h
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

#ifndef RTW_HEADER_rtwdemo_async_local_private_h_
#define RTW_HEADER_rtwdemo_async_local_private_h_
#include "rtwtypes.h"
#include "multiword_types.h"
#include "zero_crossing_types.h"
#include "rtwdemo_async_local.h"

/* include header files for VxWorks O/S calls */
#include <vxWorks.h>
#include <sysLib.h>
#include <intLib.h>
#include <iv.h>
#include <fppLib.h>
#include <logLib.h>

extern SEM_ID stopSem;
void isr_num1_vec192(void);

#endif                           /* RTW_HEADER_rtwdemo_async_local_private_h_ */
