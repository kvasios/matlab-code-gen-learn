% iGetNumOfPeriodicalTasks
%   get number of Periodical Tasks

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetNumOfPeriodicalTasks(model)

fcn_source = iGetFunctionSource(model);
numOfPeriodicalTasks = 0;
for i=1:length(fcn_source)
    if fcn_source(i) > 0
        numOfPeriodicalTasks = numOfPeriodicalTasks + 1;
    end
end
ret = numOfPeriodicalTasks;
