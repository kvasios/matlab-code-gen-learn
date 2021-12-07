% iWriteECRobotMainForJSP
%   write ecrobot main functions for JSP

%   Copyright 2010 The MathWorks, Inc.

function iWriteECRobotMainForJSP(fid, model, sys, fcn_name, fcn_source, xcp_bt)

iWriteFunctionHeader(fid, 'ISR', 'jsp_systick_low_priority');
fprintf(fid, 'void jsp_systick_low_priority(void)\n');
fprintf(fid, '{\n');
fprintf(fid, 'if (get_OS_flag()) /* check whether JSP already started or not */\n');
fprintf(fid, '{\n');
fprintf(fid, 'isig_tim();\n');
fprintf(fid, 'check_NXT_buttons();\n');
fprintf(fid, '}\n\n');

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
    fprintf(fid, '}\n\n');
end
fprintf(fid, '}\n\n');

% write periodical Task handlers
for i = 1:length(fcn_name)
    if fcn_source(i) > 0
        iWriteFunctionHeader(fid, 'Periodical Task handler', ['JSP_Cyc_' fcn_name{i}]);
        fprintf(fid, ['void JSP_Cyc_' fcn_name{i} '(VP_INT exinf)\n']);
        fprintf(fid, '{\n');
        fprintf(fid, ['iact_tsk(TSK_' fcn_name{i} ');\n']);
        fprintf(fid, '}\n\n');
    end
    fprintf(fid, '\n');
end

% write a periodial Task handler for LCD monitor Task
iWriteFunctionHeader(fid, 'Periodical Task handler', 'JSP_Cyc_ECRobotLCDMonitor');
fprintf(fid, 'void JSP_Cyc_ECRobotLCDMonitor(VP_INT exinf)\n');
fprintf(fid, '{\n');
fprintf(fid, 'iact_tsk(TSK_ECRobotLCDMonitor);\n');
fprintf(fid, '}\n\n');

% write initialization Task
iWriteFunctionHeader(fid, 'Task', 'JSP_Task_Initialize');
fprintf(fid, 'void JSP_Task_Initialize(VP_INT exinf)\n');
fprintf(fid, '{\n');
fprintf(fid, '/* Call Initialize Function(s) */\n');
fprintf(fid, '%s_initialize();\n', sys);
for i = 1:length(fcn_name)
    if fcn_source(i) == 0
        fprintf(fid, [fcn_name{i} '();\n']);
    end
end
fprintf(fid, '\next_tsk();\n');
fprintf(fid, '}\n\n');

% write periodical Tasks
periodicalTask_id = 0;
for i = 1:length(fcn_name)
    if fcn_source(i) ~= 0
        iWriteFunctionHeader(fid, 'Task', ['JSP_Task_' fcn_name{i}]);
        % Periodical execution Task
        if fcn_source(i) > 0
            fprintf(fid, ['void JSP_Task_' fcn_name{i} '(VP_INT exinf)\n']);
            fprintf(fid, '{\n');
            fprintf(fid, ['/* Call ' fcn_name{i} ' every ' num2str(fcn_source(i)) '[msec] */\n']);
            fprintf(fid, [fcn_name{i} '();\n']);
            if xcp_bt == 1
                % implement XCP DAQ hook at the end of each periodical Task
                fprintf(fid, '/* XCP DAQ */\n');
                fprintf(fid, 'XcpEvent(%d);\n', periodicalTask_id);
                periodicalTask_id = periodicalTask_id + 1;
            end
            fprintf(fid, '\next_tsk();\n');
            fprintf(fid, '}\n');
        end
    end
    fprintf(fid, '\n');
end

% write LCD status monitor Task
iWriteFunctionHeader(fid, 'Task', 'JSP_Task_ECRobotLCDMonitor');
fprintf(fid, 'void JSP_Task_ECRobotLCDMonitor(VP_INT exinf)\n');
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
fprintf(fid, 'ext_tsk();\n');
fprintf(fid, '}\n\n');

% If a USB Rx/Tx block is used, it needs to implement
% a background Task for USB process handler
% If a NXT Color Sensor block is used, it needs to implement
% background process function
portID = iGetNXTColorBlockPortID(model, sys);
if iHasUSBBlock(model, sys) || ~isempty(portID)
    iWriteFunctionHeader(fid, 'Task', 'JSP_Task_Background');
    fprintf(fid, 'void JSP_Task_Background(VP_INT exinf)\n');
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
