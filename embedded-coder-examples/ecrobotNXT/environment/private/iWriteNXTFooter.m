% iWriteNXTHooter
%   write ecrobot_main.c file footer

%   Copyright 2010 The MathWorks, Inc.

function iWriteNXTFooter(fid)

fprintf(fid, '/');
for i=1:32
    fprintf(fid, '*');
end
fprintf(fid, ' END OF FILE ');
for i=1:32
    fprintf(fid, '*');
end
fprintf(fid, '/\n');
% End of function
