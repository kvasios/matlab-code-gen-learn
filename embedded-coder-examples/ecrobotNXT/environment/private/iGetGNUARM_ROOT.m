% iGetGNUARM_ROOT
%   get GNU ARM root directory path

%   Copyright 2010 The MathWorks, Inc.

function GNUARM_ROOT = iGetGNUARM_ROOT()

evalin('base', 'ecrobotnxtsetupinfo');
GNUARM_ROOT = iConvAbsPath2CygPath(evalin('base', 'ECROBOTNXT_GNUARM_ROOT'));
% End of function
