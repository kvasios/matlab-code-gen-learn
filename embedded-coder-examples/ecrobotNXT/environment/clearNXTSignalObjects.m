% clearNXTSignalObjects
%   clears all NXT.Signal objects in the base workspace.

%   Copyright 2010 The MathWorks, Inc.

function clearNXTSignalObjects

obj = evalin('base', 'whos');
for i = 1:length(obj)
    if isequal(obj(i).class, 'NXT.Signal')
        evalin('base', ['clear ' obj(i).name]);
    end
end
% End of function
