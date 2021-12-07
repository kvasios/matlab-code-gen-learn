% iGetFunctionSource
%   get Function sources  

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetFunctionSource(model)

blk = iGetExportedFcnCallsScheduler(model);
ch = get_param(blk, 'fctrigger');
ret = evalin('base', ch{1});
% End of function
