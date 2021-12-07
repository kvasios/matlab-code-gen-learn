% iGetTaskStackSize
%   get OSEK Task stack size

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetTaskStackSize(model)

blk = iGetExportedFcnCallsScheduler(model);
ch = get_param(blk, 'stacksize');
ret = evalin('base', ch{1});
% End of function
