% iConvAbsPath2CygPath
%   replaces MS-DOS absolute path to Cygwin
%   make 3.8.1 acceptable path expression (i.e. 'C:/' to '/cygdrive/c/')

%   Copyright 2010 The MathWorks, Inc.

function path = iConvAbsPath2CygPath(abs_path)

% This is a workaround if MATLAB was installed under Program Files directory
abs_path = regexprep(abs_path, 'Program Files', 'Progra~1');

% convert MS-DOS absolute path to Cygwin valid path expression
if strcmpi(abs_path(2), ':') % Disk drive delimiter (e.g. C:\...) 
    abs_path = ['/cygdrive/' abs_path(1) abs_path(3:end)];
end

path = abs_path;
% End of function
