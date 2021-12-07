// 
// File: arm_copy_main.cpp
//  
// Code generated for Simulink model 'arm_copy'.
// 
// Model version                  : 1.7
// Simulink Coder version         : 9.1 (R2019a) 23-Nov-2018
// C/C++ source code generated on : Mon Jul 15 16:13:19 2019
// 
// Target selection: darwinoplib.tlc
// Embedded hardware selection: Generic->32-bit Embedded Processor
// Code generation objectives: Unspecified
// Validation result: Not run
// 


    

    #include <stdio.h>
  #include <unistd.h>
  #include <limits.h>
  #include <string.h>
  #include <libgen.h>
  #include <signal.h>
  #include <time.h>
  #include <sstream>
  #include <iostream>
  #include <stdlib.h>

  #include "CM730.h"
  #include "LinuxNetwork.h"
  #include "LinuxDARwIn.h"
  #include "webcam.h"

  using namespace std;
  using namespace Robot;

  #include "arm_copy.h"

  #ifndef TRUE
    #define TRUE 1
  #endif

  #ifndef FALSE
    #define FALSE 0
  #endif

  #ifndef rtmGetStopRequested
    #define rtmGetStopRequested(S) FALSE
  #endif

  #ifdef EXT_MODE
    #include "ext_work.h"          /* External mode header files */
    #include "ext_svr.h"
    #include "ext_share.h"
    #include "updown.h"
  #endif /* EXT_MODE */




  


  


  


  


  


  


  


  


  


  


  


  


  


  


    LinuxCM730 *linux_cm730;
  CM730 *cm730;
  Webcam *webcam;
  pthread_t timer_thread;



    /*handling the signals (Ctrl + C to quit etc.)*/
  /*this is the function that kills the program (it is called by callback)*/
  void sighandler(int sig)
  {
    exit(0);
  }

  /*this initializes the signals (Ctrl + C to quit etc.)*/
  void signalInitialize()
  {
    cout << "signals: initializing" << endl;
    signal(SIGABRT, &sighandler);
    signal(SIGTERM, &sighandler);
    signal(SIGQUIT, &sighandler);
    signal(SIGINT, &sighandler);
    cout << "signals: initialized" << endl;
  }

  void* timer_proc(void *param)
  {
    static struct timespec next_time;
    uint64_t clock_ns;
    #ifdef rtmGetFinalTime
    int step_index = 0;
    #endif

    clock_gettime(CLOCK_MONOTONIC,&next_time);
    clock_ns = uint64_t(next_time.tv_sec) * uint64_t(1000000000) + uint64_t(next_time.tv_nsec);

    while(  
rtmGetErrorStatus(arm_copy_M) == (NULL))
    {
              
    
     arm_copy_step();
    /* Get model outputs here */
    



      #ifdef rtmGetFinalTime
      step_index++;
      {
        time_T FinalTime = rtmGetFinalTime(arm_copy_M);
        if((FinalTime >= 0.0) && ((step_index * 0.05) > FinalTime)) {
          rtmSetStopRequested(arm_copy_M, TRUE);
        }
      }
      #endif
      {
        clock_ns += uint64_t(0.05 * 1000000000);
        next_time.tv_sec = clock_ns / 1000000000;
        next_time.tv_nsec = clock_ns % 1000000000;
        clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &next_time, NULL);
      }
    }

    pthread_exit(NULL);
    return NULL;
  }

  void timer_create()
  {
    int error;
    struct sched_param param;
    pthread_attr_t attr;

    pthread_attr_init(&attr);

    error = pthread_attr_setschedpolicy(&attr, SCHED_RR);
    if(error != 0) {
      cout << "pthread_attr_setschedpolicy error = " << error << endl;
      exit(-1);
    }

    error = pthread_attr_setinheritsched(&attr,PTHREAD_EXPLICIT_SCHED);
    if(error != 0) {
      cout << "pthread_attr_setinheritsched error = " << error << endl;
      exit(-1);
    }

    memset(&param, 0, sizeof(param));
    param.sched_priority = 31;// RT
    error = pthread_attr_setschedparam(&attr, &param);
    if(error != 0) {
      cout << "pthread_attr_setschedparam error = " << error << endl;
      exit(-1);
    }

    // create and start the thread
    error = pthread_create(&timer_thread, &attr, &timer_proc, NULL);
    if(error != 0) {
      cout << "pthread_create error = " << error << endl;
      exit(-1);
    }
  }

  void timer_destroy()
  {
    int error;
    if((error = pthread_join(timer_thread, NULL))!= 0) {
      cout << "pthread_join error = " << error << endl;
      exit(-1);
    }
  }

  void __cxa_pure_virtual(void){}
  int_T main(void)
  {
    /* Initialize signal handlers */
    signalInitialize();

    linux_cm730 = new LinuxCM730("/dev/ttyUSB0");
    cm730 = new CM730(linux_cm730);

    cout << "robot: connecting" << endl;
    if (cm730->Connect())
    {
      cout << "robot: connected" << endl;
    }
    else
    {
      cout << "robot: unable to connect to the robot" << endl;
      exit(0);
    }

    webcam = new Webcam();
    webcam->Initialize();


    #ifndef rtmGetFinalTime
    cout << "Simulation has no MAT file logs and no external links, it will run for an infinite time" << endl;
    #endif

    /* Initialize model */
      arm_copy_initialize();

    /* Initialize sample times */
      
  


    #ifdef rtmSetStopRequested
    rtmSetStopRequested(arm_copy_M, FALSE);
    #endif

    timer_create();

    while (  
(rtmGetErrorStatus(arm_copy_M) == (NULL)) && !rtmGetStopRequested(arm_copy_M)) {
      webcam->Execute();
      usleep(1000);
    }

    timer_destroy();

        arm_copy_terminate();


    delete webcam;
    delete cm730;
    delete linux_cm730;
    return 0;
  }



  


  


  


  


// 
// File trailer for generated code.
// 
// [EOF]
// 

