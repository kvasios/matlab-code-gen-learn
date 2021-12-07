// 
// File: untitled.h
//  
// Code generated for Simulink model 'untitled'.
// 
// Model version                  : 1.5
// Simulink Coder version         : 9.1 (R2019a) 23-Nov-2018
// C/C++ source code generated on : Mon Jul 15 14:57:38 2019
// 
// Target selection: darwinoplib.tlc
// Embedded hardware selection: Generic->32-bit Embedded Processor
// Code generation objectives: Unspecified
// Validation result: Not run
// 



  #ifndef RTW_HEADER_untitled_h_
  #define RTW_HEADER_untitled_h_
    

  
#include <stddef.h>

#include <string.h>
    #ifndef untitled_COMMON_INCLUDES_
  # define untitled_COMMON_INCLUDES_
    #include "rtwtypes.h"
    #include "CM730.h"
    #include "webcam.h"
  #endif /* untitled_COMMON_INCLUDES_ */
  

    #include "untitled_types.h"    



  


  


  


  
    /* Macros for accessing real-time model data structure */
    

    #ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm) ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val) ((rtm)->errorStatus = (val))
#endif


  
   
    
    
      



  


  


  


  


      
          /* Block states (default storage) for system '<Root>' */
              
        
  
     typedef struct   {
  

        /*@[1ec0*/
        


        
        

          
          

    
            
          
            

              /*@[1ebf*/
                          
                   real_T NetObj; /* '<Root>/DarwinOP communication' */
                          
            
              
            /*@]*/ 

          
          
          
    

        /*@]*/            
      



  }    DW_untitled_T;
  

      
        
    
    
    
              /* External inputs (root inport signals with default storage) */
            typedef struct {
               
    
    
    


    
    
    /*@[1ec1*/
        real_T In1;      /* '<Root>/In1' */
    /*@]*/
    
    
            } ExtU_untitled_T;
      
          
    
              /* External outputs (root outports fed by signals with default storage) */
            typedef struct {
                  



    
    
    
    /*@[1ec2*/
       real_T Out1;     /* '<Root>/Out1' */
    /*@]*/
    
     
    



    
    
    
    /*@[1ec3*/
       real_T Out2;     /* '<Root>/Out2' */
    /*@]*/
    
     
    



    
    
    
    /*@[1ec4*/
       real_T Out3;     /* '<Root>/Out3' */
    /*@]*/
    
     
    



    
    
    
    /*@[1ec5*/
       real_T Out4;     /* '<Root>/Out4' */
    /*@]*/
    
     
    



    
    
    
    /*@[1ec6*/
       real_T Out5;     /* '<Root>/Out5' */
    /*@]*/
    
     
    



    
    
    
    /*@[1ec7*/
       real_T Out6;     /* '<Root>/Out6' */
    /*@]*/
    
     
            } ExtY_untitled_T;
      
      
    


      /* Real-time Model Data Structure */
      
  struct tag_RTM_untitled_T {
            const char_T *errorStatus;



  };
      
        
          



  


  


          
      
        /* Block states (default storage) */
      


  extern         DW_untitled_T untitled_DW;



          #ifdef __cplusplus
          extern "C" {
            #endif
                    /* External inputs (root inport signals with default storage) */
            


  extern           ExtU_untitled_T untitled_U;



          /* External outputs (root outports fed by signals with default storage) */
            


  extern           ExtY_untitled_T untitled_Y;





            #ifdef __cplusplus
          }
          #endif
    


  
    #ifdef __cplusplus
    extern "C" {
    #endif
      /* Model entry point functions */
              extern void untitled_initialize(void);
            
        
                          extern void untitled_step(void);
                
    
               extern void untitled_terminate(void);
             #ifdef __cplusplus
    }
    #endif
    



  


            
          /* Real-time Model object */
          
            #ifdef __cplusplus
            extern "C" {
            #endif
          


  extern             RT_MODEL_untitled_T *const untitled_M;



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
    * '<Root>' : 'untitled'
   */



  


  #endif /* RTW_HEADER_untitled_h_ */

// 
// File trailer for generated code.
// 
// [EOF]
// 

