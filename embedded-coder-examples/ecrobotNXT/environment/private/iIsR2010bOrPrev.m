% iIsR2010bOrPrev
%   check MATLAB version
%   Since R2011a(7.12), Name of RTW and RTW-EC are changed to
%   Real-Time Workshop to Simulink Coder
%   Real-Time Workshop Embedded Coder to Embedded Coder
%   In iWriteNXTHeader.m, it needs to check the version of the above products to implement the versions
%   into the C header files. Thus, this version check is required (01/07/2011)

%   Copyright 2011 The MathWorks, Inc.

function ret = iIsR2010bOrPrev()
ML = ver('MATLAB');
ret = find(strcmp(ML.Version, {'7.2', '7.3', '7.4', '7.5', '7.6', '7.7', '7.8', '7.9', '7.10', '7.11'})); 
% End of function
