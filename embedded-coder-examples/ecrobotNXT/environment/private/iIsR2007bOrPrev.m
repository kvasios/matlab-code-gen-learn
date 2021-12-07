% iIsR2007bOrPrev
%   check MATLAB version
%   Since R2008a(7.6), RTW utility C source files have been removed. 
%   Thus, version check is required (01/15/2008)
%
%   R2010a is 7.10, so numerical comparison does not work (7.10 and 7.1 is
%   same value. Then switched to string comparison (12/10/2009)

%   Copyright 2010 The MathWorks, Inc.

function ret = iIsR2007bOrPrev()
ML = ver('MATLAB');
ret = find(strcmp(ML.Version, {'7.2', '7.3', '7.4', '7.5'})); 
% End of function
