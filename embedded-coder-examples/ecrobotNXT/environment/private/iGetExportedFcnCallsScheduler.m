% iGetExportedFcnCallsScheduler
%   get the Exported Function-Calls Scheduler block 

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetExportedFcnCallsScheduler(model)

blk = find_system(model, 'BlockType', 'S-Function', 'MaskType', 'Exported Function-Calls Scheduler');
if isempty(blk)
    disp([model ' must have an Exported Function-Calls Scheduler block.']);
    error('');
end
ret = blk;
% End of function
