// 
// File: arm_copy.h
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



  #ifndef RTW_HEADER_arm_copy_h_
  #define RTW_HEADER_arm_copy_h_
    

  
#include <stddef.h>

#include <string.h>
    #ifndef arm_copy_COMMON_INCLUDES_
  # define arm_copy_COMMON_INCLUDES_
    #include "rtwtypes.h"
    #include "CM730.h"
    #include "webcam.h"
  #endif /* arm_copy_COMMON_INCLUDES_ */
  

    #include "arm_copy_types.h"    



  


  


  


  
    /* Macros for accessing real-time model data structure */
    

    #ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm) ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val) ((rtm)->errorStatus = (val))
#endif


  
   
    
    
      



  


  


  


  


              /* Block signals (default storage) */
                  
          
  
     typedef struct   {
  

        /*@[3545*/
        


        
        

          
          

    
            
          
            

              /*@[3542*/
                          
                   real_T Delay; /* '<Root>/Delay' */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3543*/
                          
                   real_T Delay1; /* '<Root>/Delay1' */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3544*/
                          
                   real_T Delay2; /* '<Root>/Delay2' */
                          
            
              
            /*@]*/ 

          
          
          
    

        /*@]*/            
      



  }    BlockIO_arm_copy_T;
  

        
              
          /* Block states (default storage) for system '<Root>' */
              
        
  
     typedef struct   {
  

        /*@[354c*/
        


        
        

          
          

    
            
          
            

              /*@[3546*/
                          
                   real_T Delay_DSTATE; /* '<Root>/Delay' */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3547*/
                          
                   real_T Delay1_DSTATE; /* '<Root>/Delay1' */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3548*/
                          
                   real_T Delay2_DSTATE; /* '<Root>/Delay2' */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3549*/
                          
                   real_T NetObj; /* '<Root>/DarwinOP communication' */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[354a*/
                          
                   uint32_T TicH; /* '<Root>/Real-time simulation' */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[354b*/
                          
                   uint32_T TicL; /* '<Root>/Real-time simulation' */
                          
            
              
            /*@]*/ 

          
          
          
    

        /*@]*/            
      



  }    D_Work_arm_copy_T;
  

      
        
      
            /* Parameters (default storage) */
          
        struct Parameters_arm_copy_T_ {
          

        /*@[3555*/
        


        
        

          
          

    
            
          
            

              /*@[354d*/
                          
                   real_T Constant_Value; /* Expression: 0
  * Referenced by: '<Root>/Constant'
   */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[354e*/
                          
                   real_T Delay_InitialCondition; /* Expression: 2048
  * Referenced by: '<Root>/Delay'
   */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[354f*/
                          
                   real_T Delay1_InitialCondition; /* Expression: 2048
  * Referenced by: '<Root>/Delay1'
   */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3550*/
                          
                   real_T Delay2_InitialCondition; /* Expression: 2048
  * Referenced by: '<Root>/Delay2'
   */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3551*/
                          
                   real_T Mirroir_Value; /* Expression: 4095
  * Referenced by: '<Root>/Mirroir'
   */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3552*/
                          
                   uint32_T Delay_DelayLength; /* Computed Parameter: Delay_DelayLength
  * Referenced by: '<Root>/Delay'
   */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3553*/
                          
                   uint32_T Delay1_DelayLength; /* Computed Parameter: Delay1_DelayLength
  * Referenced by: '<Root>/Delay1'
   */
                          
            
              
            /*@]*/ 

          
          
          
    



        
        

          
          

    
            
          
            

              /*@[3554*/
                          
                   uint32_T Delay2_DelayLength; /* Computed Parameter: Delay2_DelayLength
  * Referenced by: '<Root>/Delay2'
   */
                          
            
              
            /*@]*/ 

          
          
          
    

        /*@]*/            
      



        };
      

    


      /* Real-time Model Data Structure */
      
  struct tag_RTM_arm_copy_T {
            const char_T *errorStatus;



  };
      
        
          



  


  


          

      /* Block parameters (default storage) */
        #ifdef __cplusplus
        extern "C" {
        #endif
      


  extern         Parameters_arm_copy_T arm_copy_P;



        #ifdef __cplusplus
        }
        #endif
      
      /* Block signals (default storage) */
      


  extern         BlockIO_arm_copy_T arm_copy_B;



      
        /* Block states (default storage) */
      


  extern         D_Work_arm_copy_T arm_copy_DWork;



    


  
    #ifdef __cplusplus
    extern "C" {
    #endif
      /* Model entry point functions */
              extern void arm_copy_initialize(void);
            
        
                          extern void arm_copy_step(void);
                
    
               extern void arm_copy_terminate(void);
             #ifdef __cplusplus
    }
    #endif
    



  


            
          /* Real-time Model object */
          
            #ifdef __cplusplus
            extern "C" {
            #endif
          


  extern             RT_MODEL_arm_copy_T *const arm_copy_M;



            #ifdef __cplusplus
            }
            #endif
          



  


  


  


        
  /*-
   * The generated code includes comments that allow you to trace directly 
   * back to the appropriate location in the model.  The basic format
   * is <system>/block_name, where system is the system number (uniquely
   * assigned by Simulink) and block_name is the name of the block.
   *
   * Use the MATLAB hilite_system command to trace the generated code back
   * to the model.  For example,
   *
   * hilite_system('<S3>')    - opens system 3
   * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
   *
   * Here is the system hierarchy for this model
   *
    * '<Root>' : 'arm_copy'
   */



  


  #endif /* RTW_HEADER_arm_copy_h_ */

// 
// File trailer for generated code.
// 
// [EOF]
// 

