% nxtbuild
%   nxtbuild is the function to generate binary executables for LEGO
%   MINDSTORMS NXT. 
%   This function is designed for the following model architechture. 
%   1. Support for only Exporting Function-Call Subsystem code generation
%   2. Requires Exported Function-Call Scheduler block to identify C functions
%   3. Requires LEGO Mindstorms NXT Blockset to implement NXT devece APIs
%   (For more detailed information, please see nxtmouse, nxtracer and nxtway demos) 
%
%   NXTBUILD(MODEL, CMD):
%     MODEL is a Virtual Subsystem name for RTW-EC Exporting Function-Call Subsystems.
%     CMD is command to specify code generation procedure.
%
%   <Examples>
%   nxtbuild('model', 'cgen'): 
%     invokes RTW-EC as Exporting Function-Call Subsystems mode, then generates 
%     ecrobot_main.c file under ./nxtprj directory to build an executable.
%
%   nxtbuild('model', 'build'):
%     builds RXE/ROM/RXE executables by using GCC toolchain.
%
%   nxtbuild('model', 'build', {'./foo.c', './foo1.c'}, [], pwd):
%     build binary executable which includes external C source files and library.
%     The third argument: external C source files with relative path from
%       the current directory.
%     The forth argument: external C library with absolute path
%     The fifth argument: path to external C header files with absolute path
%
%   nxtbuild('model', 'buildrxe'):
%     builds an executable for only Enhanced NXT firmware by using GCC toolchain.
%
%   nxtbuild('model', 'buildrom'):
%     builds an executable for only NXT BIOS by using GCC toolchain.
%
%   nxtbuild('model', 'buildram'):
%     builds an executable for only No firmware by using GCC toolchain.
%
%   nxtbuild('model', 'clean'):
%     remove generated object files
%
%   nxtbuild('model', 'rxeflash'):
%     upload the ECRobot generated binary file into Enhanced NXT firmware
%     in the NXT. nxtOSEK 2.02 or later version is required.
%
%   nxtbuild('biosflash'):
%     upload NXT BIOS to the NXT for ul2flash. 
%     LEJOS OSEK 2.00 or later version is required. 
%     NOTE that biosflash is required only for when LEGO standard firmware or 
%     other non-nxtOSEK firmware were installed in the NXT.
%
%   nxtbuild('model', 'ul2flash'):
%   nxtbuild('model', 'appflash'):
%     upload the ECRobot generated binary file into FLASH memory in the
%     NXT. nxtOSEK 2.00 or later version is required.
%
%   nxtbuild('model', 'ul2ram'):
%   nxtbuild('model', 'ramboot'):
%     upload the ECRobot generated binary file into SRAM memory in the NXT. 
%
%   nxtbuild('model', 'cgen', 'xcp'):
%     standard cgen command + implement Vector XCP on Bluetooth hook routines   
%
%   nxtbuild('model', 'build', 'xcp'):
%     build binary executable for Vector XCP on Bluetooth with CANape   
%
%   NOTE:
%   Embedded Coder Robot NXT 3.10 or later version supports XCP on Bluetooth 
%   for Vector CANape. 
%   XCP on Bluetooth allows users to measure and calibrate data in NXT via 
%   XCP protocol on Bluetooth by using Vector CANape.
%   XCP driver porting to nxtOSEK and Embedded Coder Robot NXT integration
%   are originally done by Yoshiaki SHOI <yoshiaki.shoi@vector-japan.co.jp>.

%   Copyright 2010 The MathWorks, Inc.

function nxtbuild(varargin)

% check arguments
xcp_bt = 0; % init the flag to notify the use of XCP on Bluetooth
external_source = '';
external_lib = '';
external_path = '';
switch nargin
    case 1
        if isequal(lower(varargin{1}), 'biosflash')
            cmd = 'biosflash';
            env_dir = fileparts(which('nxtbuild'));
            prj_dir = 'nxtprj';
        else
            error('NXTBuild:invalid argument.')
        end
    case 2
        sys = varargin{1};
        cmd = lower(varargin{2});
        ert_rtw_dir = [sys '_ert_rtw'];
        env_dir = fileparts(which('nxtbuild'));
        prj_dir = 'nxtprj';
        model = bdroot;
    case 3
        sys = varargin{1};
        cmd = lower(varargin{2});
        ert_rtw_dir = [sys '_ert_rtw'];
        env_dir = fileparts(which('nxtbuild'));
        prj_dir = 'nxtprj';
        model = bdroot;
        if ((isequal(cmd, 'build') || ...
                isequal(cmd, 'buildrxe') || ...
                isequal(cmd, 'buildrom') || ...
                isequal(cmd, 'buildram') || ...
                isequal(cmd, 'cgen')) && ...
                isequal(lower(varargin{3}), 'xcp'))
            % check Bluetooth device mode is set as Slave
            if isequal(iGetBluetoothDeviceMode(model), 'Master')
                error('Bluetooth device mode should be configured as Slave for XCP on Bluetooth.');
            else
                xcp_bt = 1;
            end
        elseif (isequal(cmd, 'build') || ...
                isequal(cmd, 'buildrxe') || ...
                isequal(cmd, 'buildrom') || ...
                isequal(cmd, 'buildram') || ...
                isequal(cmd, 'cgen'))
            external_source = varargin{3};
        else
            error('NXTBuild:invalid argument.')
        end
    case 4
        sys = varargin{1};
        cmd = lower(varargin{2});
        ert_rtw_dir = [sys '_ert_rtw'];
        env_dir = fileparts(which('nxtbuild'));
        prj_dir = 'nxtprj';
        model = bdroot;
        if (isequal(cmd, 'build') || ...
            isequal(cmd, 'buildrxe') || ...
            isequal(cmd, 'buildrom') || ...
            isequal(cmd, 'buildram') || ...
            isequal(cmd, 'cgen'))
            external_source = varargin{3};
            external_lib = varargin{4};
        else
            error('NXTBuild:invalid argument.')
        end
    case 5
        sys = varargin{1};
        cmd = lower(varargin{2});
        ert_rtw_dir = [sys '_ert_rtw'];
        env_dir = fileparts(which('nxtbuild'));
        prj_dir = 'nxtprj';
        model = bdroot;
        if (isequal(cmd, 'build') || ...
            isequal(cmd, 'buildrxe') || ...
            isequal(cmd, 'buildrom') || ...
            isequal(cmd, 'buildram') || ...
            isequal(cmd, 'cgen'))
            external_source = varargin{3};
            external_lib = varargin{4};
            external_path = varargin{5};
        else
            error('NXTBuild:invalid argument.')
        end
    otherwise
        error('NXTBuild:invalid argument.')
end

% check third party tool configurations
if isequal(cmd, 'cgen') == 0
    % check ecrobotnxtsetupinfo.m was generated
    try
        evalin('base', 'ecrobotnxtsetupinfo');
    catch
        error(['ecrobotnxtsetupinfo.m does not exist in environment directory. '...
            'Execute ecrobotnxtsetup.m to specify necessity information.']);
    end

    % check GNUARM_ROOT is still defined in Windows Environment Varibles
    % ECRobot NXT V3.10 or later version retrieves GNUARM root directory path 
    % by ecrobotnxtsetup.m.
    % Therefore, GNUARM_ROOT makes a confliction during build process.
    if (~isempty(getenv('GNUARM_ROOT')))
        error('Please remove GNUARM_ROOT from Windows Environment Variable.');
    end
end

% command handler
switch cmd
    case 'cgen'
        % generate code from the Virtual Subsystem to be connected to the 
        % Exported Function-Calls Scheduler block by using RTW-EC Export
        % Function cgen
        rtwbuild([gcs '/' sys], 'Mode', 'ExportFunctionCalls');
 
        % create 'nxtprj' directory
        try
            if ~isempty(dir(prj_dir))
                rmdir(prj_dir,'s');
            end
            mkdir(prj_dir);
        catch
            error(['### Failed to create nxtprj directory for model: '  sys]);
        end
                
        % generate ECRobot scheduler file(s)
        disp(['### Generating ECRobot NXT scheduler file(s) for model: ' sys]);
        iGenerateSchedulerFiles(model, sys, prj_dir, xcp_bt);
        disp(['### Successful completion of ECRobot NXT scheduler file(s) generation for model: ' sys]);

        % clear NXT.Signals in baseworkspace
        clearNXTSignalObjects();

        % if c_indent M function was found, then call it to indent generated C file(s)
        if isempty(which('c_indent'))==0
            cfiles = dir(['./' prj_dir '/*.c']);
            for i = 1:length(cfiles)
                c_indent(['./' prj_dir '/' cfiles(i).name]);
            end
        end
        
    case {'build', 'buildrxe', 'buildrom', 'buildram'} 
        if xcp_bt == 1
            nxtbuild(sys, 'cgen', 'xcp'); % call this function recursively
        else
            nxtbuild(sys, 'cgen'); % call this function recursively
        end

        current_dir = pwd;
        cd(prj_dir); % move to project dir
        try
            disp('### Executing GNU-ARM toolchain for building executable ...');
            iGenerateBuildBat(iGetCYGWIN_BIN()); % generate build.bat file in nxtprj dir
            iGenerateMakefile(cmd, model, sys, ert_rtw_dir, env_dir, xcp_bt, external_source, external_lib, external_path); % generated Makefile in nxtprj dir
            iGenerateCommand('make all'); % invoke GNU make with Makefile
            cd(current_dir); % back to the model located dir
        catch
            cd(current_dir); % back to the model located dir
        end

    case 'rebuild'
        nxtbuild(sys, 'clean'); % call this recursively with 'clean' cmd
        nxtbuild(sys, 'build'); % call this recursively with 'build' cmd
        
    case 'clean'
        disp('### Executing GNU-ARM toolchain to clean up generated object files');
        current_dir = pwd;
        cd(prj_dir); % move to project dir
        try
            iGenerateCommand('make clean'); % invoke GNU make with Makefile
            cd(current_dir); % back to the model located dir
        catch
            cd(current_dir); % back to the model located dir
        end

    case {'ul2ram', 'ramboot'}
        current_dir = pwd;
        cd(prj_dir); % move to project dir
        try
            bin_file = [sys '_ram.bin'];
            disp(['### Execute ramboot for uploading a program into RAM: ./' prj_dir '/' bin_file]);
            iGenerateCommand('make ramboot');
            iGenerateCommand('sh ./ramboot.sh');
            cd(current_dir); % back to the model located dir
        catch
            cd(current_dir); % back to the model located dir
        end

    case {'ul2flash', 'appflash'}
        current_dir = pwd;
        cd(prj_dir); % move to project dir
        
        try
            bin_file = [sys '_rom.bin'];
            disp(['### Execute appflash for uploading a program into FLASH: ./' prj_dir '/' bin_file]);
            iGenerateCommand('make appflash');
            iGenerateCommand('sh ./appflash.sh');
            cd(current_dir); % back to the model located dir
        catch
            cd(current_dir); % back to the model located dir
        end

    case 'rxeflash'
        current_dir = pwd;
        cd(prj_dir); % move to project dir
        
        try
            rxe_file = [sys '.rxe'];
            disp(['### Execute NeXTTool for uploading a program to the enhanced NXT standard firmware: ./' prj_dir '/' rxe_file]);
            iGenerateCommand('make rxeflash');
            iGenerateCommand('sh ./rxeflash.sh');
            cd(current_dir); % back to the model located dir
        catch
            cd(current_dir); % back to the model located dir
        end

    case 'biosflash'
        current_dir = pwd;
        cd(prj_dir); % move to project dir
        try
            disp('### Execute NeXTTool for uploading NXT BIOS...');
            iGenerateBuildBat(iGetCYGWIN_BIN()); % generate build.bat file in nxtprj dir
            iGenerateCommand('make biosflash');
            iGenerateCommand('sh ./biosflash.sh');
            cd(current_dir); % back to the model located dir
        catch
            cd(current_dir); % back to the model located dir
        end
        
    otherwise
        error(['### NXTBuild:' cmd ' is invalid.']);
end
% End of function

% End of file