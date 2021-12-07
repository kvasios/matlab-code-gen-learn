% iWriteFunctionHeader
%   write C function comment header

%   Copyright 2010 The MathWorks, Inc.

function iWriteFunctionHeader(fid, title, fcn_name)

fprintf(fid, '/*');
for i=1:76
    fprintf(fid, '=');
end
fprintf(fid, '\n');
fprintf(fid, [' * ' title ': ' fcn_name '\n']);
fprintf(fid, ' */\n');
% End of function
