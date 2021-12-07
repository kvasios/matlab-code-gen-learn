% iGetFunctionName
%   get Function names 

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetFunctionName(model)

blk = iGetExportedFcnCallsScheduler(model);
ch = get_param(blk, 'fcname');
ret = eval([ '{',ch{1} , '}']);
% End of function
