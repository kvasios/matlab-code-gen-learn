% iWriteECRobotExternalInterfaceH
%   write ecrobot_external_interface.h

%   Copyright 2010 The MathWorks, Inc.

function iWriteECRobotExternalInterfaceH(fid, model, sys)

fprintf(fid,'#ifndef _ECROBOT_EXTERNAL_INTERFACE_H_\n');
fprintf(fid,'#define _ECROBOT_EXTERNAL_INTERFACE_H_\n\n');

fprintf(fid,'#include "ecrobot_interface.h"\n\n');

% Declarations of OSEK Resources
resource = iGetOSEKResource(model);
if ~isempty(resource)
    fprintf(fid, '#ifdef OSEK\n\n');
    fprintf(fid, '#include "kernel.h"\n');
    fprintf(fid, '#include "kernel_id.h"\n\n');
    for i = 1:length(resource)
        fprintf(fid, ['DeclareResource( ' resource{i} ' );\n']);
    end
    fprintf(fid, '\n#endif\n\n');
end

% Declarations of JSP Semaphores
semaphore = iGetJSPSemaphore(model);
if ~isempty(semaphore)
    fprintf(fid, '#ifdef JSP\n\n');
    fprintf(fid, '#ifdef TRUE\n');
    fprintf(fid, '#undef TRUE\n');
    fprintf(fid, '#endif\n\n');
    fprintf(fid, '#ifdef FALSE\n');
    fprintf(fid, '#undef FALSE\n');
    fprintf(fid, '#endif\n\n');
    fprintf(fid, '#include "kernel.h"\n');
    fprintf(fid, '#include "kernel_id.h"\n\n');
    fprintf(fid, '#endif\n\n');
end

if iHasSoundWavWriteBlock(model, sys) == 1
    iWriteWavDataDeclarations(fid, model, sys);
end

fprintf(fid,'\n#endif\n');
% End of function
