% iHasBluetoothBlock
%   check a Bluetooth Rx Read/Tx Write/NXT GamePad Data Logger
%   is used. This check routine is needed to implement device init/term functions 

%   Copyright 2010 The MathWorks, Inc.

function ret = iHasBluetoothBlock(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
RxBlk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'Bluetooth Rx Read');
TxBlk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'Bluetooth Tx Write');
LoggerBlk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'NXT GamePad Data Logger');
ADCLoggerBlk = find_system(appSubsystem, 'BlockType', 'S-Function', 'MaskType', 'NXT GamePad ADC Data Logger');

if isempty(RxBlk) && isempty(TxBlk) && isempty(LoggerBlk) && isempty(ADCLoggerBlk)
    ret = 0; % Bluetooth related blocks are not includeded
else
    if max([length(RxBlk) length(TxBlk) length(LoggerBlk) length(ADCLoggerBlk)]) > 1 || ...
            length(LoggerBlk)+length(ADCLoggerBlk) > 1
        disp('Bluetooth blocks should have only single instance in a model.');
        error(' ');
    end
    ret = 1;
end
% End of function
