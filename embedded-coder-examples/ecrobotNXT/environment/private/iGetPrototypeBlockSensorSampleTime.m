% iGetPrototypeBlockSensorSampleTime
%   gets sensor sample time of all Prototype Sensor Read blocks in used
%   This check routine is used to implement device init/term functions

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetPrototypeBlockSensorSampleTime(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
blk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'Prototype Sensor Read');

if isempty(blk)
    ret = '';
else
     port_ids = {};
     sensor_sample_times = {};
     id = 1;
     for i = 1:length(blk)
         if isempty(strmatch(get_param(blk(i), 'ip'), port_ids))
             sensor_sample_times(id) = get_param(blk(i), 'sensor_sample_time');
             id = id + 1;
         end
     end
     ret = sensor_sample_times;
end
% End of function
