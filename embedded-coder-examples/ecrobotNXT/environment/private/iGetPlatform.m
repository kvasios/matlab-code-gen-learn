% iGetPlatform
%   get NXT run-time platform it returns 'OSEK' or 'JSP'

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetPlatform(model)

blk = iGetExportedFcnCallsScheduler(model);
platform = get_param(blk, 'platform'); 
ret = platform{1};
% End of function
