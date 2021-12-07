% iGetOSEKResource
%   get defined OSEK Resources

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetOSEKResource(model)

blk = iGetExportedFcnCallsScheduler(model);
ch = get_param(blk, 'resources');
if ~isempty(ch)
    ret = eval([ '{',ch{1} , '}']);
else
    ret = [];
end
% End of function
