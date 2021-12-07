% iHasSoundWavWriteBlock
%   check a Sound WAV Write block is used in Application Subsystem

%   Copyright 2010 The MathWorks, Inc.

function ret = iHasSoundWavWriteBlock(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
blk = find_system(appSubsystem, 'BlockType', 'SubSystem', 'MaskType', 'Sound WAV Write');

if isempty(blk)
    ret = 0;
else
    ret = 1;
end
% End of function
