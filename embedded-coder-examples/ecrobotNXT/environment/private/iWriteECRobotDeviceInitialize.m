% iWriteECRobotDeviceInitialize
%   write ECRobot NXT device initialize function

%   Copyright 2010 The MathWorks, Inc.

function iWriteECRobotDeviceInitialize(fid, model, sys, xcp_bt)

iWriteFunctionHeader(fid, 'Function', 'ecrobot_device_initialize');
fprintf(fid, 'void ecrobot_device_initialize(void)\n');
fprintf(fid, '{\n');

if iHasBluetoothBlock(model, sys)
    bt_mode = iGetBluetoothDeviceMode(model);
    if isequal(bt_mode{1}, 'Master')
        fprintf(fid, 'const U8 bd_addr[7] = {');
        addr = iGetBluetoothDeviceAddress(model);
        for i = 1:7
            fprintf(fid, ['0x' addr{i}]);
            if (i < 7)
                fprintf(fid, ', ');
            end
        end
        fprintf(fid, '};\n');
    end
end

fprintf(fid, '/* Initialize ECRobot used devices */\n');
obj = evalin('base', 'whos');
for i = 1:length(obj)
    if isequal(obj(i).class, 'NXT.Signal') && ...
            ~isequal(evalin('base', [obj(i).name '.InitialFunction']), '')
        fprintf(fid, [evalin('base', [obj(i).name '.InitialFunction']) ';\n']);
    end
end

% If a NXT Color Sensor block is used, it needs to implement
% device init function
portID = iGetNXTColorBlockPortID(model, sys);
sensor_mode = iGetNXTColorBlockSensorMode(model, sys);
if ~isempty(portID) && ~isempty(sensor_mode)
    for i = 1:length(portID)
         if strcmp(sensor_mode{i}, 'COLORSENSOR_ID') || strcmp(sensor_mode{i}, 'COLORSENSOR_RGB') 
            fprintf(fid, ['ecrobot_init_nxtcolorsensor(NXT_PORT_' portID{i} ', NXT_COLORSENSOR);\n']);
         elseif strcmp(sensor_mode{i}, 'LIGHTSENSOR_RED')
            fprintf(fid, ['ecrobot_init_nxtcolorsensor(NXT_PORT_' portID{i} ', NXT_LIGHTSENSOR_RED);\n']);
         elseif strcmp(sensor_mode{i}, 'LIGHTSENSOR_GREEN')
            fprintf(fid, ['ecrobot_init_nxtcolorsensor(NXT_PORT_' portID{i} ', NXT_LIGHTSENSOR_GREEN);\n']);
         elseif strcmp(sensor_mode{i}, 'LIGHTSENSOR_BLUE')
            fprintf(fid, ['ecrobot_init_nxtcolorsensor(NXT_PORT_' portID{i} ', NXT_LIGHTSENSOR_BLUE);\n']);
         elseif strcmp(sensor_mode{i}, 'LIGHTSENSOR_FULL')
            fprintf(fid, ['ecrobot_init_nxtcolorsensor(NXT_PORT_' portID{i} ', NXT_LIGHTSENSOR_WHITE);\n']);
         elseif strcmp(sensor_mode{i}, 'LIGHTSENSOR_NONE')
            fprintf(fid, ['ecrobot_init_nxtcolorsensor(NXT_PORT_' portID{i} ', NXT_LIGHTSENSOR_NONE);\n']);
         end
    end
end

% If a HiTechnic Acceleration Sensor block is used, it needs to implement
% device init function
portID = iGetAccelerationBlockPortID(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
         fprintf(fid, ['ecrobot_init_accel_sensor(NXT_PORT_' portID{i} ');\n']);
    end
end

% If a HiTechnic IR Seeker block is used, it needs to implement
% device init function
portID = iGetIRSeekerBlockPortID(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
         fprintf(fid, ['ecrobot_init_ir_seeker(NXT_PORT_' portID{i} ');\n']);
    end
end

% If a HiTechnic Color Sensor block is used, it needs to implement
% device init function
portID = iGetColorSensorBlockPortID(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
         fprintf(fid, ['ecrobot_init_color_sensor(NXT_PORT_' portID{i} ');\n']);
    end
end

% If a HiTechnic Prototype Sensor block is used, it needs to implement
% device init function
portID = iGetPrototypeBlockPortID(model, sys);
sensorSampleTime = iGetPrototypeBlockSensorSampleTime(model, sys);
if ~isempty(portID)
    for i = 1:length(portID)
         fprintf(fid, ['ecrobot_init_prototype_sensor(NXT_PORT_' portID{i}, ', ' sensorSampleTime{i}, ', 0x00);\n']);
    end
end

% If a USB Rx/Tx block is used, it needs to implement device term function
if iHasUSBBlock(model, sys)
    fprintf(fid, 'ecrobot_init_usb();\n');
end

% write XCP initialize function
if xcp_bt == 1
    fprintf(fid, '\n/* XCP initialize and XCP command handler */\n');
    fprintf(fid, 'if (ecrobot_get_bt_status() == BT_NO_INIT)\n');
    fprintf(fid, '{\n');
    fprintf(fid, 'XcpInit();\n');
    fprintf(fid, '}\n\n');
end

% If a Bluetooth related block is used or XCP on Bluetooth is requested,
% it needs to implement BT device init function 
% (This should be the last at the init functions)
if iHasBluetoothBlock(model, sys) || xcp_bt == 1
    bt_mode = iGetBluetoothDeviceMode(model);
    if isequal(bt_mode{1}, 'Master')
        fprintf(fid, 'ecrobot_init_bt_master(bd_addr, "MATLAB");\n');
    elseif isequal(bt_mode{1}, 'Slave')
        fprintf(fid, 'ecrobot_init_bt_slave("MATLAB");\n');
    end
end

fprintf(fid, '}\n\n\n');
% End of function

