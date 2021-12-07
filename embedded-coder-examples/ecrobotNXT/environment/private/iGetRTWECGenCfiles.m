% iGetRTWECGenCfiles
%   get RTW-EC generated C file names in <model>_ert_rtw directory

%   Copyright 2010 The MathWorks, Inc.

function files = iGetRTWECGenCfiles(ert_rtw_dir)

current_dir = pwd;
cd(['../' ert_rtw_dir]);
cfiles = dir('*.c');
cd(current_dir);

if isempty(cfiles)
    error([ert_rtw_dir ' does not have any C files.']);
end

files = [];
for i=1:length(cfiles)
    % R2006a generates ert_main.c regardless RTW-EC option settings
    % thus, remove it from the list of RTW-EC generated C files
    if ~isequal(cfiles(i).name, 'ert_main.c') 
        files = [files ' $(ERT_RTW)/' cfiles(i).name];
    end
end
% End of function
