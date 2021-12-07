% iGetPlatformFolderName
%   get folder name of the platform (it must be nxtOSEK)

%   Copyright 2010 The MathWorks, Inc.

function platform = iGetPlatformFolderName(env_dir)

% if isdir([regexprep(env_dir, '\', '/') '/lejos_osek'])
%     platform = 'lejos_osek';
if isdir([regexprep(env_dir, '\', '/') '/nxtOSEK'])
    platform = 'nxtOSEK';
else
    error('nxtOSEK folder does not exist in environment directory.');
    error(' ');
end
% End of function
