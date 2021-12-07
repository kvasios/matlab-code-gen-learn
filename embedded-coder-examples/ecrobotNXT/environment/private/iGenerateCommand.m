% iGenerateCommand
%   generates cmd file and invoke Cygwin bash with cmd (redirected to File I/O)

%   Copyright 2010 The MathWorks, Inc.

function status = iGenerateCommand(cmd)

try
    fid = fopen('cmd', 'w');
    if fid == -1
        error('NXTBuild:Can not open cmd');
    end

    fprintf(fid, '%c', cmd);
    fclose(fid);
catch
    fclose(fid);
    error('### Failed to generate cmd file');
end

[status, result] = system('build.bat'); % invoke Cygwin bash
disp(result);
% End of function


