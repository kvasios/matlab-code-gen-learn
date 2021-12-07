% iWriteWavDataDeclarations
%   generates data declarations for external binary files (e.g. wav files)

%   Copyright 2010 The MathWorks, Inc.

function iWriteWavDataDeclarations(fid, model, sys)

wav = iGetWavFileNames(model, sys);
if ~isempty(wav)
    for i = 1:length(wav)
        fprintf(fid,['/* Data Declarations for ' wav{i} '.wav file */\n']);
        fprintf(fid,['EXTERNAL_WAV_DATA(' wav{i} ');\n']);
    end
end
% End of function
