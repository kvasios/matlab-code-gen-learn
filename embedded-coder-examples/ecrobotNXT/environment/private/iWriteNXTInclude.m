% iWriteNXTInclude
%   write include header file

%   Copyright 2010 The MathWorks, Inc.

function iWriteNXTInclude(fid, headerfile_list, xcp_bt)

if xcp_bt == 1
    headerfile_list = [headerfile_list, 'xcp_interface.h'];
end

for i = 1:length(headerfile_list)
    fprintf(fid, '#include "%s"\n', headerfile_list{i});
end
fprintf(fid, '\n');
% End of function
