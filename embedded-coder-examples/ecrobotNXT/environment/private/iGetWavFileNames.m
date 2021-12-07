% iGetWavFileNames
%   get WAV file names which are specified in Sound WAV Write blocks

%   Copyright 2010 The MathWorks, Inc.

function files = iGetWavFileNames(model, sys)

appSubsystem = find_system(model, 'BlockType', 'SubSystem', 'Name', sys);
blk = find_system(appSubsystem, 'BlockType', 'SubSystem', 'MaskType', 'Sound WAV Write');

files = [];
for i = 1:length(blk)
    cellstr = get_param(blk(i), 'wav');
    file = evalin('base', cellstr{1});
    if i == 1
        files{1} = file;
        j = 2;
    else
        file_chk = strfind(files, file);
        if isempty(file_chk{1})
            files{j} = file;
            j = j + 1;
        end
    end
end;
% End of function
