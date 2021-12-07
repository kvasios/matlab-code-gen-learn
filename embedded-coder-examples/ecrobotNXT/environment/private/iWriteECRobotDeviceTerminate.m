% iWriteECRobotDeviceTerminate
%   write ECRobot NXT device terminate function

%   Copyright 2010 The MathWorks, Inc.

function iWriteECRobotDeviceTerminate(fid, model, sys, xcp_bt)

iWriteFunctionHeader(fid, 'Function', 'ecrobot_device_terminate');
fprintf(fid, 'void ecrobot_device_terminate(void)\n');
fprintf(fid, '{\n');
fprintf(fid, '/* Terminate ECRobot used devices */\n');
obj = evalin('base', 'whos');
for i = 1:length(obj)
    if isequal(obj(i).class, 'NXT.Signal') && ...
            ~isequal(evalin('base', [obj(i).name '.TerminateFunction']), '')
        fprintf(fid, [evalin('base', [obj(i).name '.TerminateFunction']) ';\n']);
    end
end

% If a NXT Color Sensor block is used, it needs to implement
% device term function
portID = iGetNXTColorBlockPortID(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
        fprintf(fid, ['ecrobot_term_nxtcolorsensor(NXT_PORT_' portID{i} ');\n']);
    end
end

% If a HiTechnic Acceleration Sensor block is used, it needs to implement
% device term function
portID = iGetAccelerationBlockPortID(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
        fprintf(fid, ['ecrobot_term_accel_sensor(NXT_PORT_' portID{i} ');\n']);
    end
end

% If a HiTechnic IR Seeker block is used, it needs to implement
% device term function
portID = iGetIRSeekerBlockPortID(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
        fprintf(fid, ['ecrobot_term_ir_seeker(NXT_PORT_' portID{i} ');\n']);
    end
end

% If a HiTechnic Color Sensor block is used, it needs to implement
% device term function
portID = iGetColorSensorBlockPortID(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
        fprintf(fid, ['ecrobot_term_color_sensor(NXT_PORT_' portID{i} ');\n']);
    end
end

% If a HiTechnic Prototype Sensor block is used, it needs to implement
% device term function
portID = iGetPrototypeBlockPortID(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
        fprintf(fid, ['ecrobot_term_prototype_sensor(NXT_PORT_' portID{i} ');\n']);
    end
end

% If a USB Rx/Tx block is used, it needs to implement device term function
if iHasUSBBlock(model, sys)
    fprintf(fid, 'ecrobot_term_usb();\n');
end

% If a Bluetooth related block is used or XCP on Bluetooth is requested, 
% it needs to implement device term function 
% (This should be the last in the term functions
if iHasBluetoothBlock(model, sys) || xcp_bt == 1
    fprintf(fid, 'ecrobot_term_bt_connection();\n');
end

fprintf(fid, '}\n\n\n');
% End of function
