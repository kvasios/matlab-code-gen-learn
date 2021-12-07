% iGetJSPSemaphore 
%   get defined JSP Semaphores 

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetJSPSemaphore(model)

blk = iGetExportedFcnCallsScheduler(model);
ch = get_param(blk, 'semaphores');
if ~isempty(ch)
    ret = eval([ '{',ch{1} , '}']);
else
    ret = [];
end
% End of function
