% iGetIRSeekerBlockPortID
%   get port id of all IR Seeker Read blocks in used
%   This check routine is used to implement device init/term functions

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetIRSeekerBlockPortID(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
blk = find_system(appSubsystem, 'regexp', 'on', ...
    'BlockType', 'S-Function', ...
    'MaskType', 'IR Seeker Read');

if isempty(blk)
    ret = '';
else
     port_ids = {};
     id = 1;
     for i = 1:length(blk)
         if isempty(strmatch(get_param(blk(i), 'ip'), port_ids))
             port_ids(id) = get_param(blk(i), 'ip');
             id = id + 1;
         end
     end
     ret = port_ids;
end
% End of function
