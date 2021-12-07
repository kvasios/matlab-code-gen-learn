% iHasUSBBlock
%   check a USB Rx Read/Tx Write/Disconnect is used. 
%   This check routine is needed to implement device init/term functions

%   Copyright 2010 The MathWorks, Inc.

function ret = iHasUSBBlock(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
RxBlk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'USB Rx Read');
TxBlk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'USB Tx Write');
DcBlk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'USB Disconnect');

if isempty(RxBlk) && isempty(TxBlk) && isempty(DcBlk) 
    ret = 0; % USB related blocks are not includeded
else
    if max([length(RxBlk) length(TxBlk) length(DcBlk)]) > 1
        disp('USB blocks should have only single instance in a model.');
        error(' ');
    end
    ret = 1;
end
% End of function
