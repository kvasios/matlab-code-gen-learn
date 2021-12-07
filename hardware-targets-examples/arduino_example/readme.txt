This exmaple shows how to create a custom driver for the Arduino target. This could serve as a starting point if you want to develop a driver for an unsupported shield.

Here are the interesting things to notice:

arduino_digital_out.c

The s-function mdlOutput and mdlStart is basically empty because the block does nothing in simulation.

To handle the parameter (pin number), we need an mdlRTW function that will write the parameter to the model.rtw file. In mdlRTW, we use ssWriteRTWParamSettings to register this non-tunable parameter. Since the parameter is integer, we specify it using SSWRITE_VALUE_DTYPE_NUM.

arduino_digital_out.tlc

Here we have 3 functions:

%function BlockTypeSetup

Here we specify the header file (arduino.h) that will declare functions like digitalWrite and define variables like OUTPUT. The include will show up in modelname_private.h

%function Start

Here we set the pinMode, like we did in the setup function when programming the board using the arduino software. This code ends up in model_initialize function in the generated code.

%function Outputs

We take the input signal and write it to the pin.
