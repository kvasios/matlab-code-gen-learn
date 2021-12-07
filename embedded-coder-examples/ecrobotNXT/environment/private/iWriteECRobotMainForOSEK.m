% iWriteECRobotMainForOSEK
%   write ecrobot main functions for OSEK

%   Copyright 2010 The MathWorks, Inc.

function iWriteECRobotMainForOSEK(fid, model, sys, fcn_name, fcn_source, xcp_bt)

% write 1msec timer ISR hook function
iWriteFunctionHeader(fid, 'Function', 'Invoked from a category 2 ISR');
fprintf(fid, 'void user_1ms_isr_type2(void)\n');
fprintf(fid, '{\n');
fprintf(fid, 'StatusType ercd;\n\n');
fprintf(fid, '/* Increment System Timer Count */\n');
fprintf(fid, 'ercd = SignalCounter(SysTimerCnt);\n');
fprintf(fid, 'if (ercd != E_OK)\n');
fprintf(fid, '{\n');
fprintf(fid, 'ShutdownOS(ercd);\n');
fprintf(fid, '}\n');

% write XCP initialize and XCP command handler
if xcp_bt == 1
    fprintf(fid, 'if (ecrobot_get_bt_status() == BT_STREAM)\n');
    fprintf(fid, '{\n');
    fprintf(fid, '/* check XCP packet */\n');
    fprintf(fid, '{\n');
    fprintf(fid, 'vuint32 xcp_cto[kXcpMaxCTO / (sizeof(vuint32) / sizeof(vuint8))];\n');
    fprintf(fid, 'if (XcpReceive((vuint8*)xcp_cto))\n');
    fprintf(fid, '{\n');
    fprintf(fid, 'XcpCommand(xcp_cto);\n');
    fprintf(fid, '}\n');
    fprintf(fid, '}\n');
    fprintf(fid, '/* check to finish XCP sent packet */\n');
    fprintf(fid, '{\n');
    fprintf(fid, 'if (XcpSendPossible())\n');
    fprintf(fid, '{\n');
    fprintf(fid, 'XcpSendCallBack();\n');
    fprintf(fid, '}\n');
    fprintf(fid, '}\n');
    fprintf(fid, '}\n');
end
fprintf(fid, '}\n\n');

% write OSEK hooks
iWriteFunctionHeader(fid, 'OSEK Hooks', 'empty functions');
fprintf(fid, 'void StartupHook(void){}\n\n');
fprintf(fid, 'void ShutdownHook(StatusType ercd){}\n\n');
fprintf(fid, 'void PreTaskHook(void){}\n\n');
fprintf(fid, 'void PostTaskHook(void){}\n\n');
fprintf(fid, 'void ErrorHook(StatusType ercd){}\n\n');

% write Initialization Task
iWriteFunctionHeader(fid, 'Task', 'OSEK_Task_Initialize');
fprintf(fid, 'TASK(OSEK_Task_ECRobotInitialize)\n');
fprintf(fid, '{\n');
fprintf(fid, '/* Call Initialize Function(s) */\n');
fprintf(fid, '%s_initialize();\n', sys);
for i = 1:length(fcn_name)
    if fcn_source(i) == 0
        fprintf(fid, [fcn_name{i} '();\n\n']);
    end
end
fprintf(fid, 'TerminateTask();\n');
fprintf(fid, '}\n\n');

% write periodical Tasks
periodicalTask_id = 0;
for i = 1:length(fcn_name)
    if fcn_source(i) > 0
        iWriteFunctionHeader(fid, 'Task', ['OSEK_Task_' fcn_name{i}]);
        fprintf(fid, ['TASK(OSEK_Task_' fcn_name{i} ')\n']);
        fprintf(fid, '{\n');
        fprintf(fid, ['/* Call ' fcn_name{i} ' every ' num2str(fcn_source(i)) '[msec] */\n']);
        fprintf(fid, [fcn_name{i} '();\n']);
        if xcp_bt == 1
            % implement XCP DAQ hook at the end of each periodical Task
            fprintf(fid, '/* XCP DAQ */\n');
            fprintf(fid, 'XcpEvent(%d);\n', periodicalTask_id);
            periodicalTask_id = periodicalTask_id + 1;
        end
        fprintf(fid, '\nTerminateTask();\n');
        fprintf(fid, '}\n');
    end
    fprintf(fid, '\n');
end

% write LCD status monitor Task
iWriteFunctionHeader(fid, 'Task', 'OSEK_Task_ECRobotLCDMonitor');
fprintf(fid, 'TASK(OSEK_Task_ECRobotLCDMonitor)\n');
fprintf(fid, '{\n');
fprintf(fid, '/* Call this function every 500[msec] */\n');
if ~iHasLCDVariablesMonitorBlock(model, sys)
    % NXT GamePad ADC Data Logger requires another LCD display routine to display
    % user selected Sensor values (i.e. HiTechnic Acceleration Sensor)
    if iHasNXTGamePadADCDataLoggerBlock(model, sys)
        fprintf(fid, ['ecrobot_adc_data_monitor("' sys '");\n\n']);
    else
        fprintf(fid, ['ecrobot_status_monitor("' sys '");\n\n']);
    end
end
fprintf(fid, 'TerminateTask();\n');
fprintf(fid, '}\n\n');

% If a USB Rx/Tx block is used, it needs to implement
% a background Task for USB process handler
% If a NXT Color Sensor block is used, it needs to implement
% background process function
portID = iGetNXTColorBlockPortID(model, sys);
if iHasUSBBlock(model, sys) || ~isempty(portID)
    iWriteFunctionHeader(fid, 'Task', 'OSEK_Task_Background');
    fprintf(fid, 'TASK(OSEK_Task_Background)\n');
    fprintf(fid, '{\n');
    fprintf(fid, 'while(1)\n{\n');
    if ~isempty(portID)
        fprintf(fid, 'ecrobot_process_bg_nxtcolorsensor(); /* NXT Color Sensor background process */\n');
    end
    if iHasUSBBlock(model, sys)
        fprintf(fid, 'ecrobot_process1ms_usb(); /* USB process handler */\n');
        fprintf(fid, 'systick_wait_ms(1); /* 1msec wait */\n');
    end
    fprintf(fid, '}\n');
    fprintf(fid, '}\n\n');
end

% End of function
