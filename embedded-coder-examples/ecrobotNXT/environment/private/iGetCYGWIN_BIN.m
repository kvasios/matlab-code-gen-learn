% iGetCYGWIN_BIN 
%   get Cygwin/bin directory path

%   Copyright 2010 The MathWorks, Inc.

function CYGWIN_BIN = iGetCYGWIN_BIN()

evalin('base', 'ecrobotnxtsetupinfo');
CYGWIN_BIN = evalin('base', 'ECROBOTNXT_CYGWIN_BIN');
% End of function
