// 
// File: arm_copy.cpp
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


    

  
        #include "arm_copy.h"


        #include "arm_copy_private.h"





  


  


  


  


  


  


  


  


  


  


    
    

  
    
    /* Block signals (default storage) */
                


  BlockIO_arm_copy_T arm_copy_B;

      
  
      
    
    
    
    
    
    
    
      /* Block states (default storage) */
                


  D_Work_arm_copy_T arm_copy_DWork;

      
  
        /* Real-time model */
          


  RT_MODEL_arm_copy_T arm_copy_M_;

        


  RT_MODEL_arm_copy_T *const arm_copy_M = &arm_copy_M_;




  


  


  


  


    
  
  
    
  
  
        
    
    
    
    // Model step function
    
          
    void arm_copy_step(void)   
    {
            


      
      
      
            
                  /* local block i/o variables */
                    
                real_T rtb_DarwinOPcommunication_o1;


    
                real_T rtb_DarwinOPcommunication_o2;


    
                real_T rtb_DarwinOPcommunication_o3;





        
        

      

        
  



          
        
  



                        
                


/* Delay: '<Root>/Delay' */
/*@>290e*/arm_copy_B./*@>345e*/Delay/*@>6e6*/ = /*@>29b0*/arm_copy_DWork./*@>3470*/Delay_DSTATE;
/* Delay: '<Root>/Delay1' */
/*@>2914*/arm_copy_B./*@>3461*/Delay1/*@>6f2*/ = /*@>29b6*/arm_copy_DWork./*@>3473*/Delay1_DSTATE;
/* Delay: '<Root>/Delay2' */
/*@>291a*/arm_copy_B./*@>3464*/Delay2/*@>6fe*/ = /*@>29bc*/arm_copy_DWork./*@>3476*/Delay2_DSTATE;
/* M-S-Function: '<Root>/DarwinOP communication' incorporates:
 *  Constant: '<Root>/Constant'
 */
/*@[2d38*/                
  /* M-S-Function Block: <Root>/DarwinOP communication */
  {
    unsigned char buf[256];






    unsigned int int_value;


    int_value = (unsigned int) /*@>2e6d*/arm_copy_B./*@>2e7a*/Delay;
    buf[30] = (unsigned char) int_value;
    buf[31] = (unsigned char)(int_value >> 8);
    cm730->WriteTable(1, 30, 31, buf, NULL);
    cm730->ReadTable(2, 36, 37, buf, NULL);
    /*@>2f8b*/rtb_DarwinOPcommunication_o1 = (((unsigned int)buf[37]) << 8) + buf[36];
    int_value = (unsigned int) /*@>2e9e*/arm_copy_P./*@>2eab*/Constant_Value;
    buf[24] = (unsigned char) int_value;
    cm730->WriteTable(2, 24, 24, buf, NULL);
    int_value = (unsigned int) /*@>2ecf*/arm_copy_B./*@>2edc*/Delay1;
    buf[30] = (unsigned char) int_value;
    buf[31] = (unsigned char)(int_value >> 8);
    cm730->WriteTable(3, 30, 31, buf, NULL);
    cm730->ReadTable(4, 36, 37, buf, NULL);
    /*@>2fae*/rtb_DarwinOPcommunication_o2 = (((unsigned int)buf[37]) << 8) + buf[36];
    int_value = (unsigned int) /*@>2f00*/arm_copy_P./*@>2f0d*/Constant_Value;
    buf[24] = (unsigned char) int_value;
    cm730->WriteTable(4, 24, 24, buf, NULL);
    int_value = (unsigned int) /*@>2f31*/arm_copy_B./*@>2f3e*/Delay2;
    buf[30] = (unsigned char) int_value;
    buf[31] = (unsigned char)(int_value >> 8);
    cm730->WriteTable(5, 30, 31, buf, NULL);
    cm730->ReadTable(6, 36, 37, buf, NULL);
    /*@>2fd1*/rtb_DarwinOPcommunication_o3 = (((unsigned int)buf[37]) << 8) + buf[36];
    int_value = (unsigned int) /*@>2f62*/arm_copy_P./*@>2f6f*/Constant_Value;
    buf[24] = (unsigned char) int_value;
    cm730->WriteTable(6, 24, 24, buf, NULL);
  }
  

   
  
/*@]*//* M-S-Function: '<Root>/Real-time simulation' */
/*@[2d3b*/                /* M-S-Function Block: <Root>/Real-time simulation */
  {
  }

   
  
/*@]*//* Update for Delay: '<Root>/Delay' incorporates:
 *  Constant: '<Root>/Mirroir'
 *  Sum: '<Root>/Sum'
 */
/*@>29d4*/arm_copy_DWork./*@>3479*/Delay_DSTATE/*@>71a*/ = /*@>2984*/arm_copy_P./*@>3467*/Mirroir_Value/*@>11c2*/ - /*@>1e14*/rtb_DarwinOPcommunication_o1;
/* Update for Delay: '<Root>/Delay1' incorporates:
 *  Constant: '<Root>/Mirroir'
 *  Sum: '<Root>/Sum1'
 */
/*@>29da*/arm_copy_DWork./*@>347c*/Delay1_DSTATE/*@>726*/ = /*@>298a*/arm_copy_P./*@>346a*/Mirroir_Value/*@>11c8*/ - /*@>1e18*/rtb_DarwinOPcommunication_o2;
/* Update for Delay: '<Root>/Delay2' incorporates:
 *  Constant: '<Root>/Mirroir'
 *  Sum: '<Root>/Sum2'
 */
/*@>29e0*/arm_copy_DWork./*@>347f*/Delay2_DSTATE/*@>732*/ = /*@>2990*/arm_copy_P./*@>346d*/Mirroir_Value/*@>11ce*/ - /*@>1e1c*/rtb_DarwinOPcommunication_o3;






        
  


            
      
      
      
      
            
  
  
    
    

      
        

    


    
    
  
  

        
          
     


      
      
      


      
          
  

    } 
    
      




  







  // Model initialize function
  
      void arm_copy_initialize(void)
  { 
      


    
    
    
    
        
    
    
        /* Registration code */
            
      
      

      
  
  
  

  
  
  
      
        
        
        
        
            
  

        
            
            /* initialize error status */
            rtmSetErrorStatus(arm_copy_M, (NULL));
      
      
      
  
  

  
  
  

    /* block I/O */
    
      
        
        (void) memset(((void *) &arm_copy_B), 0,
sizeof(BlockIO_arm_copy_T));
        

        

  
    
  
  
    

  







    /* states (dwork) */
    
        

    
        
                    (void) memset((void *)&arm_copy_DWork,  0,
 sizeof(D_Work_arm_copy_T));
        

        

        
      
  
    
    
    
    
    
        
  
    

    
      



  

          

  
      
      

    
    
    
        




      
                      
                

    

    
 
    

    
 
/* Start for M-S-Function: '<Root>/DarwinOP communication' incorporates:
 *  Constant: '<Root>/Constant'
 */
/*@[2d67*/          
        /* M-S-Function Block: <Root>/DarwinOP communication */
  {
  }

 /*@]*//* Start for M-S-Function: '<Root>/Real-time simulation' */
/*@[2d6a*/          
        /* M-S-Function Block: <Root>/Real-time simulation */
  {
  }

 /*@]*/    

    
 
/* InitializeConditions for Delay: '<Root>/Delay' */
/*@>2a0a*/arm_copy_DWork./*@>353b*/Delay_DSTATE/*@>7cc*/ = /*@>2996*/arm_copy_P./*@>3532*/Delay_InitialCondition;
/* InitializeConditions for Delay: '<Root>/Delay1' */
/*@>2a10*/arm_copy_DWork./*@>353e*/Delay1_DSTATE/*@>7d8*/ = /*@>299c*/arm_copy_P./*@>3535*/Delay1_InitialCondition;
/* InitializeConditions for Delay: '<Root>/Delay2' */
/*@>2a16*/arm_copy_DWork./*@>3541*/Delay2_DSTATE/*@>7e4*/ = /*@>29a2*/arm_copy_P./*@>3538*/Delay2_InitialCondition;
        








      
    
    
        

  


      
  


  }    




      
  


  
    
    // Model terminate function
          void arm_copy_terminate(void)

    {
      

      
                                
  



          
  



                    
            
                /* Terminate for M-S-Function: '<Root>/DarwinOP communication' incorporates:
 *  Constant: '<Root>/Constant'
 */
/*@[2d49*/                  /* M-S-Function Block: <Root>/DarwinOP communication */
  {
  }


 /*@]*//* Terminate for M-S-Function: '<Root>/Real-time simulation' */
/*@[2d4c*/                  /* M-S-Function Block: <Root>/Real-time simulation */
  {
  }


 /*@]*/




          



            
  



    




          
  

    }
      
  




  
  
   




  


  


  


  


// 
// File trailer for generated code.
// 
// [EOF]
// 

