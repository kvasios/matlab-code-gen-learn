% iWriteECRobotCFG
%   write JSP CFG file
%   Periodical Tasks are executed by Rate Monotonic Scheduling

%   Copyright 2010 The MathWorks, Inc.

function iWriteECRobotCFG(fid, model, sys, blk, fcn_name, fcn_source, stacksize, semaphore)

stacksizeForInit = 0;  
for i=1:length(fcn_source)
    if fcn_source(i) == 0
        % If there were multiple Initialization Tasks, sum up all
        % stacks
        stacksizeForInit = stacksizeForInit + stacksize(i);
    end
end
% If there was no Initialization Task, set minimum stacksize for
% default model initialize
if stacksizeForInit == 0
    stacksizeForInit = 128;
end

% write ecrobot.cfg file
fprintf(fid, ['/* JSP configuration for ' model ' */\n']);
fprintf(fid, '#define _MACRO_ONLY\n');
fprintf(fid, '#include "ecrobot_main.h"\n');
fprintf(fid, 'INCLUDE("\\"ecrobot_main.h\\"");\n\n');

% Definition of initialization Task
fprintf(fid, '/* Definition of Initialization Task */\n');
fprintf(fid, ['CRE_TSK(TSK_Initialize, {TA_HLNG | TA_ACT, TSK_Initialize, JSP_Task_Initialize, 1, ' num2str(stacksizeForInit) ', NULL});\n\n']); 

% Definitions of periodical Tasks
% Set the second highest priority 
numPrio = 2;
for i = 1:length(fcn_source)
    if fcn_source(i) > 0
        fprintf(fid, ['/* Definition of a Periodical Task for: ' fcn_name{i} ' */\n']);
        fprintf(fid, ['CRE_CYC(CYC_' fcn_name{i} ', {TA_HLNG | TA_ACT, CYC_' fcn_name{i}...
            ', JSP_Cyc_' fcn_name{i} ', ' num2str(fcn_source(i)) ', 0});\n']); 
        fprintf(fid, ['CRE_TSK(TSK_' fcn_name{i} ', {TA_HLNG, TSK_' fcn_name{i}...
            ', JSP_Task_' fcn_name{i} ', ' num2str(numPrio) ', ' num2str(stacksize(i)) ', NULL});\n\n']);
        numPrio = numPrio + 1;
    end
end

% Definition of LCD monitor Task 
fprintf(fid, '/* Definition of LCD monitor Task */\n');
fprintf(fid, 'CRE_CYC(CYC_ECRobotLCDMonitor, {TA_HLNG | TA_ACT, CYC_ECRobotLCDMonitor, JSP_Cyc_ECRobotLCDMonitor, 500, 0});\n');
fprintf(fid, ['CRE_TSK(TSK_ECRobotLCDMonitor, {TA_HLNG, TSK_ECRobotLCDMonitor, JSP_Task_ECRobotLCDMonitor, ' num2str(numPrio) ', 512, NULL});\n\n']);

% If a USB Rx/Tx block is used, it needs to implement device term function
% If a NXT Color Sensor block is used, it needs to implement
% background process function
if iHasUSBBlock(model, sys) || ~isempty(iGetNXTColorBlockPortID(model, sys))
    numPrio = numPrio + 1;
    fprintf(fid, '/* Definition of Background Task */\n');
    fprintf(fid, ['CRE_TSK(TSK_Background, {TA_HLNG | TA_ACT, TSK_Background, JSP_Task_Background, ' num2str(numPrio) ', 512, NULL});\n\n']);
end

% Definition of JSP Semaphore
if ~isempty(semaphore)
    fprintf(fid, '/* Definition of JSP Semaphores */\n');
    for i = 1:length(semaphore)
        fprintf(fid, ['CRE_SEM(' semaphore{i} ', {TA_TPRI, 1, 1});\n']);
    end
    fprintf(fid, '\n');
end

fprintf(fid, '#include <at91sam7s.h>\n');
fprintf(fid, 'INCLUDE("\\"at91sam7s.h\\"");\n');
fprintf(fid, 'DEF_INH(IRQ_PWM_PID, {TA_HLNG, jsp_systick_low_priority});\n');

% End of function
