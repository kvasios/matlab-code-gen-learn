% iGenerateBuildBat
%   generates build.bat file to invoke Cygwin shell (bash) from MATLAB

%   Copyright 2010 The MathWorks, Inc.

function iGenerateBuildBat(cygwin_bin)

try
    fid = fopen('build.bat', 'w');
    if fid == -1
        error('NXTBuild:Can not open build.bat');
    end

    fprintf(fid, '@echo off\n');
    % cygwin/bin must be first to avoid confliction between other make in
    % PC
    fprintf(fid, ['set path=' cygwin_bin, ';%%PATH%%;\n']);
    fprintf(fid, 'bash<cmd\n');
    fclose(fid);
catch
    fclose(fid);
    error('### Failed to generate build.bat');
end
% End of function
