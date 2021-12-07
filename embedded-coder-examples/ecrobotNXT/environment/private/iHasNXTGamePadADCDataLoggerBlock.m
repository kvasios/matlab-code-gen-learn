% iHasNXTGamePadADCDataLoggerBlock
%   check a NXTGamePad ADC Data Logger block is used 
%   This check routine is used to implement specific LCD monitor function

%   Copyright 2010 The MathWorks, Inc.

function ret = iHasNXTGamePadADCDataLoggerBlock(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
blk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'NXT GamePad ADC Data Logger');

if isempty(blk)
    ret = 0;
else
    if length(blk) > 1
        disp('NXT GamePad ADC Data Logger should have only single instance in a model.');
        error(' ');
    end
    ret = 1;
end
% End of function
