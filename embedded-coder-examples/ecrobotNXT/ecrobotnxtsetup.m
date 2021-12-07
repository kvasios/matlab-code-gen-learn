% ECROBOTNXTSETUP
%   This function is used to retrieve and confirm necessity settings to build 
%   Embedded Coder Robot NXT generated code.
%   User can execute this function either with GUI or programmatically.
%
%   <How to use>
%   - GUI based set up (Dialogs pop up to specify necessity information)
%   ecrobotnxtsetup
%
%   - MATLAB prompt based set up (specify necessity information as arguments)
%   ecrobotnxtsetup(path to cygwin/bin, path to GNUARM, path to NeXTToo.exe) 
%    dir1 = 'C:/cygwin/bin';
%    dir2 = 'C:/cygwin/GNUARM';
%    dir3 = 'C:/cygwin/nexttool';
%   ecrobotnxtsetup(dir1, dir2, dir3);

%   Copyright 2010 The MathWorks, Inc.

function ecrobotnxtsetup(varargin)

% Note that these versions have to be updated for the release
% 03/10/2009 Embedded Coder Robot NXT v3.17
% VER_NXTOSEK = 2.08; % supported version of nxtOSEK
% VER_ECROBOTNXT = 3.17; % version of ECRobot NXT
% 10/20/2010 Embedded Coder Robot NXT v4.00
VER_NXTOSEK = 2.14; % supported version of nxtOSEK
VER_ECROBOTNXT = 4.00; % version of ECRobot NXT

disp('### Start verifying Embedded Coder Robot NXT installations...');

% check MATLAB is installed in the directory which does not contain spaces.
if strfind(matlabroot, ' ')
    % There is a workaound for Program Files, thus it is OK.
    if (~strfind(matlabroot, 'Program Files'))
        error('MATLAB should be installed in the directory which does not contain spaces (and/or multi-byte characters).');
    end
end

% check ECRobot NXT is installed in the directory which does not contain spaces.
if strfind(pwd, ' ')
    error('Embedded Coder Robot NXT should be installed in the directory which does not contain spaces (and/or multi-byte characters).');
end

% check GNUARM_ROOT is still defined in Windows Environment Varibles
% ECRobot NXT V3.10 or later version retrieves GNUARM root directory path 
% by ecrobotnxtsetup.m.
% Therefore, GNUARM_ROOT makes a confliction during build process.
if (~isempty(getenv('GNUARM_ROOT')))
    errordlg('A Windows Environment Variable: GNUARM_ROOT is defined. Please remove it to use the new Embedded Coder Robot NXT.');
end

% run desired set up 
switch nargin
    case 0 % execute GUI based set up
        [cygwin_bin_dir, gnuarm_root_dir, nexttool_root_dir] = ...
            GuiBasedSetUp();

    case 2 % execute prompt based set up for NXT BIOS
        [cygwin_bin_dir, gnuarm_root_dir, nexttool_root_dir] = ...
            PromptBasedSetUp(varargin{1}, varargin{2}, 0);

    case 3 % execute prompt based set up for Enhanced NXT firmware
        [cygwin_bin_dir, gnuarm_root_dir, nexttool_root_dir] = ...
            PromptBasedSetUp(varargin{1}, varargin{2}, varargin{3});

    otherwise
            error('NXTBuild:invalid argument.')
end

% check nxtOSEK is installed in environment directory
environment_dir = [pwd '\environment'];
if ~isdir([regexprep(environment_dir, '\', '/') '/nxtOSEK'])
    error('nxtOSEK does not exist in ecrobotNXT/environment directory.')
end
% check the version of nxtOSEK
addpath([environment_dir '\nxtOSEK\ecrobot']);
nxtOSEK_ver = ver_nxtOSEK;
if nxtOSEK_ver < VER_NXTOSEK
    rmpath([environment_dir '\nxtOSEK\ecrobot']);
    error(['Embedded Coder Robot NXT ' num2str(VER_ECROBOTNXT) ' requires nxtOSEK '...
        num2str(VER_NXTOSEK) ' or later version.']);
end
rmpath([environment_dir '\nxtOSEK\ecrobot']);
disp(['### Verifying nxtOSEK ' num2str(nxtOSEK_ver) ': OK']);

% set MATLAB path to ecrobotNXT/environment directory
disp(['### Setting MATLAB path to ' environment_dir ' directory.']);
addpath(environment_dir);
savepath;

% generate ecrobotnxtsetupinfo.m in enviroment directory
setupinfo = [environment_dir '\ecrobotnxtsetupinfo.m'];
disp(['### Generating ' setupinfo]);
try
    fid = fopen(setupinfo, 'w');
    fprintf(fid, ['ECROBOTNXT_CYGWIN_BIN = ''' cygwin_bin_dir ''';\n']);
    fprintf(fid, ['ECROBOTNXT_GNUARM_ROOT = ''' gnuarm_root_dir ''';\n']);
    if nexttool_root_dir == 0
        fprintf(fid, 'ECROBOTNXT_NEXTTOOL_ROOT = '''';\n');
    else
        fprintf(fid, ['ECROBOTNXT_NEXTTOOL_ROOT = ''' nexttool_root_dir ''';\n']);
    end
    fclose(fid);
catch
    fclose(fid);
    error(['ERROR: Failed to generate ' setupinfo]);
end

disp('### Successful completion of Embedded Coder Robot NXT installations.');
end

% =========================================================================
% Sub function: GuiBasedSetUp
function [cygwin_bin_dir, gnuarm_root_dir, nexttool_root_dir] = GuiBasedSetUp()

% check cygwin/bin directory path to run bash
cygwin_bin_dir = uigetdir('C:\','Specify cygwin/bin path(e.g. C:/cygwin/bin).');
if cygwin_bin_dir == 0
    error('cygwin/bin path is not specified.');
else
    cygwin_bin_dir = regexprep(cygwin_bin_dir, '\\', '/');
    [status ret] = system([cygwin_bin_dir '/make -v']);
    disp(['### cygwin/bin path: ' cygwin_bin_dir]);
    if (strfind(ret, 'GNU Make'))
        disp('### Verifying GNU make: OK');
    else
        error('ERROR: Cygwin/bin path or GNU Make is not installed.');
    end
end

% check GNUARM root directory path for nxtOSEK Makefile (tool_gcc.mak)
gnuarm_root_dir = uigetdir('C:\','Specify GNUARM root path(e.g. C:/cygwin/GNUARM).');
if gnuarm_root_dir == 0
    error('GNUARM root path is not specified.');
else
    gnuarm_root_dir = regexprep(gnuarm_root_dir, '\\', '/');
    [status ret] = system([cygwin_bin_dir '/ls ' gnuarm_root_dir '/bin']);
    disp(['### GNUARM path: ' gnuarm_root_dir]);
    if (strfind(ret, 'arm-elf-gcc-4.0.2'))
        disp('### Verifying GNUARM 4.0.2: OK');
    else
        error('ERROR: GNUARM path or version (must be 4.0.2) might be wrong.');
    end
end

% check NeXTTool root directory path for nxtOSEK Makefile (tool_gcc.mak)
nexttool_root_dir = uigetdir('C:\','Specify NeXTTool root path(e.g. C:/cygwin/nexttool).');
if nexttool_root_dir == 0
    warning('Warning: NeXTTool root path is not specified.');
    warning('Warning: So you can not upload ECRobot NXT app to the NXT which has Enhanced NXT firmware.');
else
    nexttool_root_dir = regexprep(nexttool_root_dir, '\\', '/');
    [status ret] = system([cygwin_bin_dir '/ls ' nexttool_root_dir]);
    disp(['### NeXTTool path: ' nexttool_root_dir]);
    if (strfind(ret, 'NeXTTool.exe'))
        disp('### Verifying NeXTTool.exe: OK');
    else
        error('ERROR: NeXTTool.exe not found.');
    end
end

end % End of sub function

% =========================================================================
% Sub function: PromptBasedSetUp
function [cygwin_bin_dir, gnuarm_root_dir, nexttool_root_dir] = PromptBasedSetUp(dir1, dir2, dir3)

% check cygwin/bin directory path to run bash
if dir1 == 0
    error('cygwin/bin path is not specified.');
else
    dir1 = regexprep(dir1, '\\', '/');
    [status ret] = system([dir1 '/make -v']);
    if (strfind(ret, 'GNU Make'))
        disp('### Verifying GNU make: OK');
    else
        error('ERROR: Cygwin/bin path or GNU Make is not installed.');
    end
    cygwin_bin_dir = dir1;
end

% check GNUARM root directory path for nxtOSEK Makefile (tool_gcc.mak)
if dir2 == 0
    error('GNUARM root path is not specified.');
else
    dir2 = regexprep(dir2, '\\', '/');
    [status ret] = system([cygwin_bin_dir '/ls ' dir2 '/bin']);
    if (strfind(ret, 'arm-elf-gcc-4.0.2'))
        disp('### Verifying GNUARM 4.0.2: OK');
    else
        error('ERROR: GNUARM path or version (must be 4.0.2) might be wrong.');
    end
    gnuarm_root_dir = dir2;
end

% check NeXTTool root directory path for nxtOSEK Makefile (tool_gcc.mak)
if dir3 == 0
    warning('Warning: NeXTTool root path is not specified.');
    warning('Warning: So you can not upload ECRobot NXT app to the NXT which has Enhanced NXT firmware.');
    nexttool_root_dir = 0;
else
    dir3 = regexprep(dir3, '\\', '/');
    [status ret] = system([cygwin_bin_dir '/ls ' dir3]);
    if (strfind(ret, 'NeXTTool.exe'))
        disp('### Verifying NeXTTool.exe: OK');
    else
        error('ERROR: NeXTTool.exe not found.');
    end
    nexttool_root_dir = dir3;
end

end % End of sub function

% End of file
