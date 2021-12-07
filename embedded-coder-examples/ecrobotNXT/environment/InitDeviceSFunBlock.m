% InitDeviceSFunBlock
%   This function is invoked at the mask initilization of Device S-Function
%   blocks (e.g. Bluetooth Rx/Tx blocks, HiTechnic Acceleration blocks) to
%   support multiple NXT controller models simulation.

%   Copyright 2010 The MathWorks, Inc.

function bd_mode = InitDeviceSFunBlock(mdl)

blk = find_system(mdl, 'regexp', 'on', ...
    'BlockType', 'S-Function', ...
    'MaskType', 'Exported Function-Calls Scheduler');
if ~isempty(blk)
    if strcmp(get_param(blk, 'bd_mode'), 'Master')
        bd_mode = 0;
    else
        bd_mode = 1;
    end
else
    bd_mode = 0;
end
% End of function
