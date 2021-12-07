// 
// File: untitled.cpp
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


    

  
        #include "untitled.h"


        #include "untitled_private.h"





  


  


  


  


  


  


  


  


  


  


    
    

  

  
    
      /* Block states (default storage) */
                


  DW_untitled_T untitled_DW;

          
      /* External inputs (root inport signals with default storage) */
                      


  ExtU_untitled_T untitled_U;

        
    
      /* External outputs (root outports fed by signals with default storage) */
                      


  ExtY_untitled_T untitled_Y;

        

  
        /* Real-time model */
          


  RT_MODEL_untitled_T untitled_M_;

        


  RT_MODEL_untitled_T *const untitled_M = &untitled_M_;




  


  


  


  


    
  
  
    
  
  
        
    
    
    
    // Model step function
    
          
    void untitled_step(void)   
    {
            


      
      
      
            
      
        
        

      

        
  



          
        
  



                        
                /* M-S-Function: '<Root>/DarwinOP communication' incorporates:
 *  Inport: '<Root>/In1'
 *  Outport: '<Root>/Out1'
 *  Outport: '<Root>/Out2'
 *  Outport: '<Root>/Out3'
 *  Outport: '<Root>/Out4'
 *  Outport: '<Root>/Out5'
 *  Outport: '<Root>/Out6'
 */
/*@[195b*/                
  /* M-S-Function Block: <Root>/DarwinOP communication */
  {
    unsigned char buf[256];






    unsigned int int_value;


    cm730->ReadTable(1, 36, 41, buf, NULL);
    /*@>1a53*/untitled_Y./*@>1a60*/Out1 = (((unsigned int)buf[37]) << 8) + buf[36];
    /*@>1a84*/untitled_Y./*@>1a91*/Out2 = (((unsigned int)buf[39]) << 8) + buf[38];
    /*@>1ab5*/untitled_Y./*@>1ac2*/Out3 = (((unsigned int)buf[41]) << 8) + buf[40];
    int_value = (unsigned int) /*@>1a22*/untitled_U./*@>1a2f*/In1;
    buf[30] = (unsigned char) int_value;
    buf[31] = (unsigned char)(int_value >> 8);
    cm730->WriteTable(1, 30, 31, buf, NULL);
    cm730->ReadTable(200, 44, 49, buf, NULL);
    /*@>1ae6*/untitled_Y./*@>1af3*/Out4 = (((unsigned int)buf[45]) << 8) + buf[44];
    /*@>1b17*/untitled_Y./*@>1b24*/Out5 = (((unsigned int)buf[47]) << 8) + buf[46];
    /*@>1b48*/untitled_Y./*@>1b55*/Out6 = (((unsigned int)buf[49]) << 8) + buf[48];
  }
  

   
  
/*@]*/





        
  


            
      
      
      
      
            
  
  
    
    

      
        

    


    
    
  
  

        
          
     


      
      
      


      
          
  

    } 
    
      




  







  // Model initialize function
  
      void untitled_initialize(void)
  { 
      


    
    
    
    
        
    
    
        /* Registration code */
            
      
      

      
  
  
  

  
  
  
      
        
        
        
        
            
  

        
            
            /* initialize error status */
            rtmSetErrorStatus(untitled_M, (NULL));
      
      
      
  
  

  
  
  


  







    /* states (dwork) */
    
        

    
        
                    (void) memset((void *)&untitled_DW,  0,
 sizeof(DW_untitled_T));
        

        

        
      
  
    
    
    
    
    
        
  
    
        /* external inputs */
        
        
                  
                untitled_U.In1 = 0.0;






      
    

  
  
        
        
        /* external outputs */
        
        
      

  
  
        

          (void) memset((void *)&untitled_Y,  0,
 sizeof(ExtY_untitled_T));
  


        
        

    
      



  

          

  
      
      

    
    
    
        




      
                      
                

    

    
 
    

    
 
/* Start for M-S-Function: '<Root>/DarwinOP communication' incorporates:
 *  Inport: '<Root>/In1'
 *  Outport: '<Root>/Out1'
 *  Outport: '<Root>/Out2'
 *  Outport: '<Root>/Out3'
 *  Outport: '<Root>/Out4'
 *  Outport: '<Root>/Out5'
 *  Outport: '<Root>/Out6'
 */
/*@[197a*/          
        /* M-S-Function Block: <Root>/DarwinOP communication */
  {
  }

 /*@]*/    

    
 
        








      
    
    
        

  


      
  


  }    




      
  


  
    
    // Model terminate function
          void untitled_terminate(void)

    {
      

      
                                
  



          
  



                    
            
                /* Terminate for M-S-Function: '<Root>/DarwinOP communication' incorporates:
 *  Inport: '<Root>/In1'
 *  Outport: '<Root>/Out1'
 *  Outport: '<Root>/Out2'
 *  Outport: '<Root>/Out3'
 *  Outport: '<Root>/Out4'
 *  Outport: '<Root>/Out5'
 *  Outport: '<Root>/Out6'
 */
/*@[1966*/                  /* M-S-Function Block: <Root>/DarwinOP communication */
  {
  }


 /*@]*/




          



            
  



    




          
  

    }
      
  




  
  
   




  


  


  


  


// 
// File trailer for generated code.
// 
// [EOF]
// 

