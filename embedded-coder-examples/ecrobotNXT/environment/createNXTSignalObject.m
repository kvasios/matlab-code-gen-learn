% createNXTSignalObject
%   generates NXT.Signal object to resolve Data Store Read/Write identifiers 
%   in Embedded Coder Robot NXT Blockset.
%   This function is invoked in the InitFcn callback of Interface blocks.
%   NXT.Signal provides Customised Properties to specify C device APIs.

%   Copyright 2010 The MathWorks, Inc.

function createNXTSignalObject(varargin)

switch nargin
    case 3
        model      = varargin{1};
        signalName = varargin{2};
        param1     = varargin{3};
        param2       = '';
    case 4
        model      = varargin{1};
        signalName = varargin{2};
        param1     = varargin{3};
        param2     = varargin{4};
    otherwise
        error('createNXTSignalObject:requires 3 or 4 arguments.')
end

tmpObj = NXT.Signal;
tmpObj.Complexity = 'real';
tmpObj.SamplingMode = 'Sample based';
tmpObj.RTWInfo.StorageClass = 'Custom';
tmpObj.RTWInfo.CustomStorageClass = 'GetSet';
% Specify header file name that includes extern declaration of functions and
% variables
tmpObj.RTWInfo.CustomAttributes.HeaderFile = 'ecrobot_external_interface.h';

% Enter Button Interface block
if isequal(signalName, [model 'EnterButton'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'uint8';
    tmpObj.Max = 1;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        'ecrobot_is_ENTER_button_pressed()';
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = '';

% Run Button Interface block
elseif isequal(signalName, [model 'RunButton'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'uint8';
    tmpObj.Max = 1;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        'ecrobot_is_RUN_button_pressed()';
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = '';

% Sound WAV Interface block
elseif isequal(signalName, [model 'SoundWAV'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'int32';
    tmpObj.Max = 100;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = '';
    start_addr = ['WAV_DATA_START(' param1 ')'];
    file_size = ['WAV_DATA_SIZE(' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.SetFunction = ...
        ['ecrobot_sound_wav(' start_addr ', (U32)' file_size ', -1, '];
    tmpObj.TerminateFunction = '';

% HiTechnic Gyro Sensor Interface block
elseif isequal(signalName, [model 'GyroSensor']) 
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'uint16';
    tmpObj.Max = 1023;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        ['ecrobot_get_gyro_sensor(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = '';

% Light Sensor Interface block
elseif isequal(signalName, [model 'LightSensor']) 
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'uint16';
    tmpObj.Max = 1023;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = ...
        ['ecrobot_set_light_sensor_active(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        ['ecrobot_get_light_sensor(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = ...
        ['ecrobot_set_light_sensor_inactive(NXT_PORT_' param1 ')'];

% Touch Sensor Interface block
elseif isequal(signalName, [model 'TouchSensor']) 
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'uint8';
    tmpObj.Max = 1;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        ['ecrobot_get_touch_sensor(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = '';

% Ultrasonic Sensor Interface block
elseif isequal(signalName, [model 'UltrasonicSensor'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'int32';
    tmpObj.Max = 255;
    tmpObj.Min = -1;
    tmpObj.InitialFunction = ...
        ['ecrobot_init_sonar_sensor(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        ['ecrobot_get_sonar_sensor(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = ...
        ['ecrobot_term_sonar_sensor(NXT_PORT_' param1 ')'];

% Sound Sensor Interface block
elseif isequal(signalName, [model 'SoundSensor'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'uint16';
    tmpObj.Max = 1023;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        ['ecrobot_get_sound_sensor(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = '';

% Revolution Sensor Interface block
elseif isequal(signalName, [model 'RevolutionSensor'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'int32';
    tmpObj.Max = 2^31-1;
    tmpObj.Min = -2^31;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        ['ecrobot_get_motor_rev(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = '';

% Servo Motor Interface block
elseif isequal(signalName, [model 'ServoMotor'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'int8';
    tmpObj.Max = 100;
    tmpObj.Min = -100;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = '';
    if isequal(param2, 'Brake')
        tmpObj.RTWInfo.CustomAttributes.SetFunction = ...
            ['ecrobot_set_motor_mode_speed(NXT_PORT_' param1 ', 1, '];
    else % Float
        tmpObj.RTWInfo.CustomAttributes.SetFunction = ...
            ['ecrobot_set_motor_mode_speed(NXT_PORT_' param1 ', 0, '];
    end
    tmpObj.TerminateFunction = ...
        ['ecrobot_set_motor_speed(NXT_PORT_' param1 ', 0)'];

% Battery Voltage Interface block
elseif isequal(signalName, [model 'BatteryVoltage'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'uint16';
    tmpObj.Max = 2^16-1;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        'ecrobot_get_battery_voltage()';
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = '';

% System Clock Interface block
elseif isequal(signalName, [model 'SystemClock'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'uint32';
    tmpObj.Max = 2^32-1;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = '';
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        'ecrobot_get_systick_ms()';
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = '';

% HiTechnic Compass Sensor Interface block
elseif isequal(signalName, [model 'CompassSensor'])
    tmpObj.Dimensions = [1 1];
    tmpObj.DataType = 'int16';
    tmpObj.Max = 355;
    tmpObj.Min = 0;
    tmpObj.InitialFunction = ...
        ['ecrobot_init_compass_sensor(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.GetFunction = ...
        ['ecrobot_get_compass_sensor(NXT_PORT_' param1 ')'];
    tmpObj.RTWInfo.CustomAttributes.SetFunction = '';
    tmpObj.TerminateFunction = ...
        ['ecrobot_term_compass_sensor(NXT_PORT_' param1 ')'];

else
    error(['Invalid signalName: ' signalName]);
end

assignin('base', [signalName param1], tmpObj);
% End of function
