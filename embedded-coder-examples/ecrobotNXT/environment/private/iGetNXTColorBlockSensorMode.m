% iGetNXTColorBlockSensorMode
%   gets sensor mode of all NXT Color Sensor Read blocks in used
%   This check routine is used to implement device init/term functions

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetNXTColorBlockSensorMode(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
blk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'NXTColor Sensor Read');

if isempty(blk)
    ret = '';
else
     sensor_modes = {};
     id = 1;
     for i = 1:length(blk)
         if isempty(strmatch(get_param(blk(i), 'sensor_mode'), sensor_modes))
             sensor_modes(id) = get_param(blk(i), 'sensor_mode');
             id = id + 1;
         end
     end
     ret = sensor_modes;
end
% End of function
