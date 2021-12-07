% iWriteECRobotOIL
%   write OSEK OIL file
%   Periodical Tasks are executed by Rate Monotonic Scheduling

%   Copyright 2010 The MathWorks, Inc.

function iWriteECRobotOIL(fid, model, sys, blk, fcn_name, fcn_source, stacksize, resource)

numIniTasks = 0;
numPrdTasks = 0;
numEvtTasks = 0;
stacksizeForInit = 0;  
for i=1:length(fcn_source)
    if fcn_source(i) == 0
        numIniTasks = numIniTasks + 1;
        % If there were multiple Initialization Tasks, sum each stacksize
        stacksizeForInit = stacksizeForInit + stacksize(i);
    elseif fcn_source(i) > 0
        numPrdTasks = numPrdTasks + 1;
    elseif fcn_source(i) < 0
        numEvtTasks = numEvtTasks + 1;
    end
end
% Number of Task priority = 
%   User Tasks - User Init Tasks + (ECRobot Init Task + LCD Monitor Task) +
%   Idle Task for USB
numPrio = length(fcn_source) - numIniTasks + 2;

% If a USB Rx/Tx block is used, it needs to implement device term function
% If a NXT Color Sensor block is used, it needs to implement
% background process function
if iHasUSBBlock(model, sys) || ~isempty(iGetNXTColorBlockPortID(model, sys))
    numPrio = numPrio + 1;
end

% If there was no Initialization Task, set minimum stacksize for defalut model initialize
if stacksizeForInit == 0
    stacksizeForInit = 128;
end

% write ecrobot.oil file
fprintf(fid, ['/* OSEK OIL definition for ' model ' */\n']);
fprintf(fid, '#include "implementation.oil"\n\n');

fprintf(fid, 'CPU ATMEL_AT91SAM7S256\n');
fprintf(fid, '{\n');
fprintf(fid, '  OS LEJOS_OSEK\n');
fprintf(fid, '  {\n');
fprintf(fid, '    STATUS = EXTENDED;\n');
fprintf(fid, '    STARTUPHOOK = FALSE;\n');
fprintf(fid, '    SHUTDOWNHOOK = FALSE;\n');
fprintf(fid, '    PRETASKHOOK = FALSE;\n');
fprintf(fid, '    POSTTASKHOOK = FALSE;\n');
fprintf(fid, '    USEGETSERVICEID = FALSE;\n');
fprintf(fid, '    USEPARAMETERACCESS = FALSE;\n');
fprintf(fid, '    USERESSCHEDULER = FALSE;\n');
fprintf(fid, '  };\n\n');

fprintf(fid, '  APPMODE appmode1{};\n\n');

% OIL definition for Resources
if ~isempty(resource)
    fprintf(fid, '  /* Definition of OSEK Resources */\n');
    for i = 1:length(resource)
        fprintf(fid, ['  RESOURCE ' resource{i} '\n']);
        fprintf(fid, '  {\n');
        fprintf(fid, '    RESOURCEPROPERTY = STANDARD;\n'); 
        fprintf(fid, '  };\n');
    end
    fprintf(fid, '\n');
end

% OIL definition for Initialization Task
fprintf(fid, '  /* Definition of Initialization Task */\n');
fprintf(fid, '  TASK OSEK_Task_ECRobotInitialize\n');
fprintf(fid, '  {\n');
fprintf(fid, '    AUTOSTART = TRUE\n');
fprintf(fid, '    {\n');
fprintf(fid, '      APPMODE = appmode1;\n');
fprintf(fid, '    };\n');
fprintf(fid, ['    PRIORITY = ' num2str(numPrio) ';\n']);
fprintf(fid, '    ACTIVATION = 1;\n');
fprintf(fid, '    SCHEDULE = FULL;\n');
fprintf(fid, ['    STACKSIZE = ' num2str(stacksizeForInit) ';\n']);
% Usually, we do not expect OSEK Resources were allocated in Initialization
% Function-Calls, but technically it is possible to do. So, this loop is
% needed
for i = 1:length(fcn_source)
    if fcn_source(i) == 0
        if ~isempty(resource)
            % get OSEK resources used in the Function-Call Subsystem with
            % specified Function-Call name
            resources_in_use = iGetOSEKResourcesForOIL(blk, fcn_name{i});
            for j = 1:length(resources_in_use)
                fprintf(fid, ['    RESOURCE = ' resources_in_use{j} ';\n']);
            end
        end
    end
end
fprintf(fid, '  };\n\n');

for i = 1:length(fcn_source)
    % OIL definitions for Periodical execution Tasks
    if fcn_source(i) > 0
        numPrio = numPrio - 1;
        fprintf(fid, ['  /* Definitions of a Periodical Task: ' fcn_name{i} ' */\n']);
        fprintf(fid, ['  TASK OSEK_Task_' fcn_name{i} '\n']);
        fprintf(fid, '  {\n');
        fprintf(fid, '    AUTOSTART = FALSE;\n');
        fprintf(fid, ['    PRIORITY = ' num2str(numPrio) ';\n']);
        fprintf(fid, '    ACTIVATION = 1;\n');
        fprintf(fid, '    SCHEDULE = FULL;\n');
        fprintf(fid, ['    STACKSIZE = ' num2str(stacksize(i)) ';\n']);
        
        if ~isempty(resource)
            % get OSEK resources used in the Function-Call Subsystem with
            % specified Function-Call name
            resources_in_use = iGetOSEKResourcesForOIL(blk, fcn_name{i});
            for j = 1:length(resources_in_use)
                fprintf(fid, ['    RESOURCE = ' resources_in_use{j} ';\n']);
            end
        end
        fprintf(fid, '  };\n\n');
        
        fprintf(fid, ['  ALARM OSEK_Alarm_' fcn_name{i} '\n']);
        fprintf(fid, '  {\n');
        fprintf(fid, '    COUNTER = SysTimerCnt;\n');
        fprintf(fid, '    ACTION = ACTIVATETASK\n');
        fprintf(fid, '    {\n');
        fprintf(fid, ['      TASK = OSEK_Task_' fcn_name{i} ';\n']);
        fprintf(fid, '    };\n');
        fprintf(fid, '    AUTOSTART = TRUE\n');
        fprintf(fid, '    {\n');
        fprintf(fid, '      APPMODE = appmode1;\n');
        fprintf(fid, '      ALARMTIME = 1;\n');
        fprintf(fid, ['      CYCLETIME = ' num2str(fcn_source(i)) ';\n']);
        fprintf(fid, '    };\n');
        fprintf(fid, '  };\n\n');
    end
end

% OIL definition for LCD monitor Task
fprintf(fid, '  /* Definitions of LCD monitor Task */\n');
fprintf(fid, '  TASK OSEK_Task_ECRobotLCDMonitor\n');
fprintf(fid, '  {\n');
fprintf(fid, '    AUTOSTART = FALSE;\n');
fprintf(fid, ['    PRIORITY = ' num2str(numPrio-1) ';\n']);
fprintf(fid, '    ACTIVATION = 1;\n');
fprintf(fid, '    SCHEDULE = FULL;\n');
fprintf(fid, '    STACKSIZE = 512;\n');
fprintf(fid, '  };\n\n');

fprintf(fid, '  ALARM OSEK_Alarm_ECRobotLCDMonitor\n');
fprintf(fid, '  {\n');
fprintf(fid, '    COUNTER = SysTimerCnt;\n');
fprintf(fid, '    ACTION = ACTIVATETASK\n');
fprintf(fid, '    {\n');
fprintf(fid, '      TASK = OSEK_Task_ECRobotLCDMonitor;\n');
fprintf(fid, '    };\n');
fprintf(fid, '    AUTOSTART = TRUE\n');
fprintf(fid, '    {\n');
fprintf(fid, '      APPMODE = appmode1;\n');
fprintf(fid, '      ALARMTIME = 1;\n');
fprintf(fid, '      CYCLETIME = 500;\n');
fprintf(fid, '    };\n');
fprintf(fid, '  };\n\n');

% If a USB Rx/Tx block is used, it needs to implement device term function
% If a NXT Color Sensor block is used, it needs to implement
% background process function
if iHasUSBBlock(model, sys) || ~isempty(iGetNXTColorBlockPortID(model, sys))
    % OIL definition for Background Task
    fprintf(fid, '  /* Definitions of Background Task */\n');
    fprintf(fid, '  TASK OSEK_Task_Background\n');
    fprintf(fid, '  {\n');
    fprintf(fid, '    AUTOSTART = TRUE\n');
    fprintf(fid, '    {\n');
    fprintf(fid, '      APPMODE = appmode1;\n');
    fprintf(fid, '    };\n');
    fprintf(fid, ['    PRIORITY = ' num2str(numPrio-2) ';\n']);
    fprintf(fid, '    ACTIVATION = 1;\n');
    fprintf(fid, '    SCHEDULE = FULL;\n');
    fprintf(fid, '    STACKSIZE = 512;\n');
    fprintf(fid, '  };\n\n');
end

% OIL definition for Alarm counter source
fprintf(fid, '  /* Definition of Alarm counter */\n');
fprintf(fid, '  COUNTER SysTimerCnt\n');
fprintf(fid, '  {\n');
fprintf(fid, '    MINCYCLE = 1;\n');
fprintf(fid, '    MAXALLOWEDVALUE = 10000;\n');
fprintf(fid, '    TICKSPERBASE = 1;\n');
fprintf(fid, '  };\n');

fprintf(fid, '};\n');
% End of function
