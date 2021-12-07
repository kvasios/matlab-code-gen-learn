% iHasLCDVariablesMonitorBlock
% check a LCD Variables Monitor block is used. 
% This check routine is needed to implement device init/term functions 

%   Copyright 2010 The MathWorks, Inc.

function ret = iHasLCDVariablesMonitorBlock(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
blk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'LCD Variables Monitor');

ret = ~isempty(blk);
% End of function
