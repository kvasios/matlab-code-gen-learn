% iWriteNXTHeader
%   write ecrobot_main.c file header

%   Copyright 2010 The MathWorks, Inc.

function iWriteNXTHeader(fid, model, sys)

% get the actual date and Simulink version
thisDate = datestr(now, 0);
slVer = ver('simulink');
if iIsR2010bOrPrev()
    rtwVer = ver('RTW');
    ecVer = ver('ecoder');
else % R2011a or later
     rtwVer = ver('simulinkcoder');
     ecVer = ver('embeddedcoder');
end

fprintf(fid, '/');
for i=1:77
    fprintf(fid, '*');
end
fprintf(fid, '\n');

fprintf(fid, ' * FILE: ecrobot_main.c\n');
fprintf(fid, ' *\n');
fprintf(fid, ' * MODEL: %s.mdl\n', model);
fprintf(fid, ' *\n');
fprintf(fid, ' * APP SUBSYSTEM: %s\n', sys);
fprintf(fid, ' *\n');
fprintf(fid, ' * PLATFORM: %s\n', iGetPlatform(model)); 
fprintf(fid, ' *\n');
fprintf(fid, ' * DATE: %s\n', thisDate);
fprintf(fid, ' *\n');
fprintf(fid, ' * TOOL VERSION:\n');
fprintf(fid, ' *   Simulink: %s %s %s\n',...
    slVer.Version, slVer.Release, slVer.Date);
if iIsR2010bOrPrev()
    fprintf(fid, ' *   Real-Time Workshop: %s %s %s\n',...
        rtwVer.Version, rtwVer.Release, rtwVer.Date);
    fprintf(fid, ' *   Real-Time Workshop Embedded Coder: %s %s %s\n',...
        ecVer.Version, ecVer.Release, ecVer.Date);
else % R2011a or later
    fprintf(fid, ' *   Simulink Coder: %s %s %s\n',...
        rtwVer.Version, rtwVer.Release, rtwVer.Date);
    fprintf(fid, ' *   Embedded Coder: %s %s %s\n',...
        ecVer.Version, ecVer.Release, ecVer.Date);
end

fprintf(fid, ' ');
for i=1:77
    fprintf(fid, '*');
end
fprintf(fid, '/\n');
% End of function
