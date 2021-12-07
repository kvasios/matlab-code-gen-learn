% iWriteECRobotMainH
%   write ecrobot_main.h for JSP

%   Copyright 2010 The MathWorks, Inc.

function iWriteECRobotMainH(fid, model, sys, blk, fcn_name, fcn_source, stacksize)

fprintf(fid, '#ifndef _ECROBOTMAIN_H_\n');
fprintf(fid, '#define _ECROBOTMAIN_H_\n\n');
fprintf(fid, '#include <t_services.h>\n\n');

fprintf(fid, '#ifndef _MACRO_ONLY\n\n');

% Declaration of initialization Task
fprintf(fid, 'extern void JSP_Task_Initialize(VP_INT exinf);\n'); 

% Declarations of periodical Tasks
for i = 1:length(fcn_source)
    if fcn_source(i) > 0
        fprintf(fid, ['extern void JSP_Cyc_' fcn_name{i} '(VP_INT exinf);\n']);
        fprintf(fid, ['extern void JSP_Task_' fcn_name{i} '(VP_INT exinf);\n']);
    end
end

% Declaration of LCD monitor Task 
fprintf(fid, 'extern void JSP_Cyc_ECRobotLCDMonitor(VP_INT exinf);\n');
fprintf(fid, 'extern void JSP_Task_ECRobotLCDMonitor(VP_INT exinf);\n');

% If a USB Rx/Tx block is used, it needs to implement device term function
% If a NXT Color Sensor block is used, it needs to implement
% background process function
if iHasUSBBlock(model, sys) || ~isempty(iGetNXTColorBlockPortID(model, sys))
    fprintf(fid, 'extern void JSP_Task_Background(VP_INT exinf);\n');
end

fprintf(fid, '\n#endif\n');
fprintf(fid, '\n#endif\n');

% End of function
