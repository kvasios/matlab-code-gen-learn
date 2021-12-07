% iWriteNXTDefinitionForOSEK
%   write data/macro definitions for OSEK

%   Copyright 2010 The MathWorks, Inc.

function iWriteNXTDefinitionForOSEK(fid, model, sys, fcn_name, fcn_source) 

% write OSEK declarations/data definition comment header
fprintf(fid, '/*');
for i=1:76
    fprintf(fid, '=');
end
fprintf(fid, '\n');
fprintf(fid, ' * OSEK declarations\n');
fprintf(fid, ' *');
for i=1:75
    fprintf(fid, '=');
end
fprintf(fid, '*/\n');

% OSEK Alarm System Timer Count declarations
fprintf(fid, 'DeclareCounter(SysTimerCnt);\n');

% OSEK Task declarations
% Initialize function(s) are executed in the pre-defined Task
fprintf(fid, 'DeclareTask(OSEK_Task_ECRobotInitialize);\n');

% User defined Tasks 
for i=1:length(fcn_source)
    if fcn_source(i) ~= 0
        fprintf(fid, ['DeclareTask(OSEK_Task_' fcn_name{i} ');\n']);
    end
end

% This is the Task for LCD status monitor
fprintf(fid, 'DeclareTask(OSEK_Task_ECRobotLCDMonitor);\n');

% If a USB Rx/Tx block is used, it needs to implement device term function
% If a NXT Color Sensor block is used, it needs to implement
% background process function
if iHasUSBBlock(model, sys) || ~isempty(iGetNXTColorBlockPortID(model, sys))
    fprintf(fid, 'DeclareTask(OSEK_Task_Background);\n');
end

fprintf(fid, '\n');

% End of function
