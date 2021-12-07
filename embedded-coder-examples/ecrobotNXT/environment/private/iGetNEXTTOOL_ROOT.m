% iGetNEXTTOOL_ROOT
%   get NeXTTool root directory path

%   Copyright 2010 The MathWorks, Inc.

function NEXTTOOL_ROOT = iGetNEXTTOOL_ROOT()

evalin('base', 'ecrobotnxtsetupinfo');
NEXTTOOL_ROOT = evalin('base', 'ECROBOTNXT_NEXTTOOL_ROOT');
if isempty(NEXTTOOL_ROOT) == 0
    NEXTTOOL_ROOT = iConvAbsPath2CygPath(NEXTTOOL_ROOT);
end
% End of function
