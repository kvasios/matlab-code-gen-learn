% iWriteXCP_PAR
%   write xcp_par.c file to define XCP_DAQ_EVENT_INFO

%   Copyright 2010 The MathWorks, Inc.

function iWriteXCP_PAR(fid, model, sys, fcn_name, fcn_source)

fprintf(fid, '#include "xcpBasic.h"\n\n');
fprintf(fid, '#if defined ( kXcpStationIdLength )\n');
fprintf(fid, 'V_MEMROM0 MEMORY_ROM vuint8 kXcpStationId[kXcpStationIdLength] = kXcpStationIdString;\n');
fprintf(fid, '#endif\n\n');
fprintf(fid, '#if defined ( XCP_ENABLE_DAQ_EVENT_INFO )\n\n');
periodicalTask_id = 0;
for i=1:length(fcn_source)
    if fcn_source(i) > 0
        fprintf(fid, ['V_MEMROM0 static vuint8 MEMORY_ROM kXcpEventName_%d[] = "' fcn_name{i} '";\n'], periodicalTask_id);
        periodicalTask_id = periodicalTask_id + 1;
    end
end
fprintf(fid, 'V_MEMROM0 vuint8* MEMORY_ROM kXcpEventName[] =\n{\n');
periodicalTask_id = 0;
for i=1:length(fcn_source)
    if fcn_source(i) > 0
        fprintf(fid, 'kXcpEventName_%d', periodicalTask_id);
        periodicalTask_id = periodicalTask_id + 1;
        if i ~= length(fcn_source)
            fprintf(fid, ', ');
        end
    end
end
fprintf(fid, '\n};\n');
fprintf(fid, 'V_MEMROM0 vuint8 MEMORY_ROM kXcpEventNameLength[] =\n{\n');
for i=1:length(fcn_source)
    if fcn_source(i) > 0
        fprintf(fid, '%d', length(fcn_name{i}) );
        if i ~= length(fcn_source)
            fprintf(fid, ', ');
        end
    end
end
fprintf(fid, '\n};\n');
fprintf(fid, 'V_MEMROM0 vuint8 MEMORY_ROM kXcpEventCycle[] =\n{\n');
for i=1:length(fcn_source)
    if fcn_source(i) > 0
        % set Task execution cycle in ms
        fprintf(fid, '%d', fcn_source(i));
        if i ~= length(fcn_source)
            fprintf(fid, ', ');
        end
    end
end
fprintf(fid, '\n};\n');
fprintf(fid, 'V_MEMROM0 vuint8 MEMORY_ROM kXcpEventDirection[] =\n{\n');
for i=1:length(fcn_source)
    if fcn_source(i) > 0
        fprintf(fid,  'kXcpEventDirectionDaq');
        if i ~= length(fcn_source)
            fprintf(fid, ', ');
        end
    end
end
fprintf(fid, '\n};\n');
fprintf(fid, '#endif');
% End of function
