% iGetLibsrcFiles
%   get RTW/RTW-EC standard libsrc files for floating
%   point code generation

%   Copyright 2010 The MathWorks, Inc.

function files = iGetLibsrcFiles()
if iIsR2007bOrPrev() 
    current_dir = pwd;
    cd([matlabroot, '\rtw\c\libsrc']);
    cfiles = dir('*.c');
    cd(current_dir);
    files = [];
    for i=1:length(cfiles)
        files = [files ' ' iConvAbsPath2CygPath(regexprep(matlabroot, '\', '/')), ...
            '/rtw/c/libsrc/' cfiles(i).name];
    end
else 
    files = '';
end
% End of function
