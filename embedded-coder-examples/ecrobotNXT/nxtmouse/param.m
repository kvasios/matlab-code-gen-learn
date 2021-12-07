%   Copyright 2010 The MathWorks, Inc.

% Parameters for NXTmouse characteristics

Ts = 0.0001;     % base sample rate[sec]

Lm = 1.4e-3;     % motor inductance[H]
Rm = 1.0;        % motor coil resistance[ƒ¶]
Kt = 0.022;      % motor torque gain[Nm/A]
Kb = 0.022;      % motor back EMF[Vs/rad]
Jm = 0.5e-7;     % motor inertia moment[kgm^2] 
Jw = 20.0e-7;    % wheel inertia moment[kgm^2] 
Cm = 9.00e-6;    % motor viscous friction[Nms/rad]
Cw = 9.00e-4;    % wheel viscous friction[Nms/rad]

bl = 0.05;       % mechanical backlash of motor and gear
n  = 24;         % gear ratio(motor:wheel=1:n) 
Rw = 0.056/2;    % wheel radius[m]
W  = 0.16;       % wheel tread[m]
M  = 0.64;       % robot weight[kg] 
J  = M*(W/2)^2;  % robot inertia moment[kgm^2]
Dx  =1e-3;       % robot friction(forward dir)
Dzz =1e-6;       % robot friction(rotation dir)
e = -0.2;

% Parameters for Virtual Reality Toolbox
WIDTH   = 16;
WIDTH1  = 12; % Rear right and left
LENGTH  = 20; % Rotation diameter of Front right and left 
LENGTH2 = 16; % Rotation diameter of Rear right and left

VR_TS = Ts*500;
START_POS = [22 15]; % robot initial position[pixels]
CAMERA_POS = [100 100]; % camera position for Chaser view[pixels]
TRACK_MAP = double(imread('track.bmp'));
WALL = 128; % gray
LINE = 0;   % black
WALL_MAP = ~(TRACK_MAP - WALL);
LINE_MAP = ~(TRACK_MAP - LINE);

% Simulink Buses for NXT Controller I/O
elements(1) = Simulink.BusElement;
elements(1).Name = 'In_Sonar';
elements(1).DataType = 'int32';
elements(1).Complexity = 'real';
elements(1).Dimensions = 1;
elements(1).SamplingMode = 'Sample based';
elements(1).SampleTime = Ts*10;

elements(2) = Simulink.BusElement;
elements(2).Name = 'In_LightR';
elements(2).DataType = 'uint16';
elements(2).Complexity = 'real';
elements(2).Dimensions = 1;
elements(2).SamplingMode = 'Sample based';
elements(2).SampleTime = Ts*10;

elements(3) = Simulink.BusElement;
elements(3).Name = 'In_LightL';
elements(3).DataType = 'uint16';
elements(3).Complexity = 'real';
elements(3).Dimensions = 1;
elements(3).SamplingMode = 'Sample based';
elements(3).SampleTime = Ts*10;

elements(4) = Simulink.BusElement;
elements(4).Name = 'In_RevR';
elements(4).DataType = 'int32';
elements(4).Complexity = 'real';
elements(4).Dimensions = 1;
elements(4).SamplingMode = 'Sample based';
elements(4).SampleTime = Ts*10;

elements(5) = Simulink.BusElement;
elements(5).Name = 'In_RevL';
elements(5).DataType = 'int32';
elements(5).Complexity = 'real';
elements(5).Dimensions = 1;
elements(5).SamplingMode = 'Sample based';
elements(5).SampleTime = Ts*10;

Inputs = Simulink.Bus;
Inputs.Elements = elements; 
clear elements;

elements(1) = Simulink.BusElement;
elements(1).Name = 'Out_motorSpdR';
elements(1).DataType = 'int8';
elements(1).Complexity = 'real';
elements(1).Dimensions = 1;
elements(1).SamplingMode = 'Sample based';
elements(1).SampleTime = Ts*10;

elements(2) = Simulink.BusElement;
elements(2).Name = 'Out_motorSpdL';
elements(2).DataType = 'int8';
elements(2).Complexity = 'real';
elements(2).Dimensions = 1;
elements(2).SamplingMode = 'Sample based';
elements(2).SampleTime = Ts*10;

Outputs = Simulink.Bus;
Outputs.Elements = elements;
clear elements;


