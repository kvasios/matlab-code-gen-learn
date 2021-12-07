% iGenerateSchedulerFiles
%   generates ECRobot scheduler files

%   Copyright 2010 The MathWorks, Inc.

function iGenerateSchedulerFiles(model, sys, prj_dir, xcp_bt)

fcn_name = iGetFunctionName(model);
fcn_source = iGetFunctionSource(model);
stacksize = iGetTaskStackSize(model);
blk = iGetExportedFcnCallsScheduler(model);
if ~isequal(size(fcn_name), size(fcn_source), size(stacksize))
    error('### Number of Function-Call name, Function-Call source, and Task stack size are unmatch.');
end

% generate ecrobot_main.c file
try
    fid = fopen(['./' prj_dir '/ecrobot_main.c'], 'w');
    if fid == -1
        error('NXTBuild:Can not open ecrobot_main.c');
    end
    
    % write file header section
    iWriteNXTHeader(fid, model, sys);
    
    % write description of RTW-EC generated functions
    iWriteNXTFunctionDescription(fid, model, sys, iGetFunctionName(model), iGetFunctionSource(model))

    if isequal(iGetPlatform(model), 'OSEK')
        % write header file include section
        headerfiles = {'kernel.h', 'kernel_id.h', 'ecrobot_interface.h', [sys '.h']};
        iWriteNXTInclude(fid, headerfiles, xcp_bt);
        % write declarations/global data/macro definitions
        iWriteNXTDefinitionForOSEK(fid, model, sys, iGetFunctionName(model), iGetFunctionSource(model));
    elseif isequal(iGetPlatform(model), 'JSP')
        % write header file include section
        headerfiles = {'ecrobot_main.h', 'kernel.h', 'kernel_id.h', 'ecrobot_interface.h', [sys '.h']};
        iWriteNXTInclude(fid, headerfiles, xcp_bt);
    end
    
    % write ECRobot used devices initialize function
    iWriteECRobotDeviceInitialize(fid, model, sys, xcp_bt);
    
    % write ECRobot used devices terminate function
    iWriteECRobotDeviceTerminate(fid, model, sys, xcp_bt);

    % write ecrobot main functions
    if isequal(iGetPlatform(model), 'OSEK')
        iWriteECRobotMainForOSEK(fid, model, sys, iGetFunctionName(model), iGetFunctionSource(model), xcp_bt);
    elseif isequal(iGetPlatform(model), 'JSP')
        iWriteECRobotMainForJSP(fid, model, sys, iGetFunctionName(model), iGetFunctionSource(model), xcp_bt);
    end
    
    % write file footer section
    iWriteNXTFooter(fid);
    
    fclose(fid);
catch
    fclose(fid); % Release the resource
    error(['### Failed to generate ECRobot NXT main file for model: ' sys]);
end

% generate platform configration files
if isequal(iGetPlatform(model), 'OSEK')
    % write ecrobot.oil file
    try
        fid = fopen(['./' prj_dir '/ecrobot.oil'], 'w');
        if fid == -1
            error('NXTBuild:Can not open ecrobot.oil');
        end
        iWriteECRobotOIL(fid, model, sys, blk{1}, fcn_name, fcn_source, stacksize, iGetOSEKResource(model));
        fclose(fid);
    catch
        fclose(fid); % Release the resource
        error(['### Failed to generate ecrobot.oil file for model: ' sys]);
    end
elseif isequal(iGetPlatform(model), 'JSP')
    % write ecrobot.cfg file
    try
        fid = fopen(['./' prj_dir '/ecrobot.cfg'], 'w');
        if fid == -1
            error('NXTBuild:Can not open ecrobot.cfg');
        end
        iWriteECRobotCFG(fid, model, sys, blk{1}, fcn_name, fcn_source, stacksize, iGetJSPSemaphore(model));
        fclose(fid);
    catch
        fclose(fid); % Release the resource
        error(['### Failed to generate ecrobot.cfg file for model: ' sys]);
    end
    
    % write ecrobot_main.h file
    try
        fid = fopen(['./' prj_dir '/ecrobot_main.h'], 'w');
        if fid == -1
            error('NXTBuild:Can not open ecrobot_main.h');
        end
        iWriteECRobotMainH(fid, model, sys, blk{1}, fcn_name, fcn_source, stacksize);
        fclose(fid);
    catch
        fclose(fid); % Release the resource
        error(['### Failed to generate ecrobot_main.h file for model: ' sys]);
    end
end

% generate ecrobot_external_interface.h file
try
    fid = fopen(['./' prj_dir '/ecrobot_external_interface.h'], 'w');
    if fid == -1
        error('NXTBuild:Can not open ecrobot_external_interface.h');
    end
    iWriteECRobotExternalInterfaceH(fid, model, sys);
    fclose(fid);
catch
    fclose(fid); % Release the resource
    error(['### Failed to generate ecrobot_external_interface.h for model: ' sys]);
end

% generate xcp_par.c file
if xcp_bt == 1
    disp(['### Generating Vector XCP on Bluetooth parameter C file for model: ' sys]);
    try
        fid = fopen(['./' prj_dir '/xcp_par.c'], 'w');
        if fid == -1
            error('NXTBuild:Can not open xcp_par.c');
        end
        iWriteXCP_PAR(fid, model, sys, fcn_name, fcn_source);
        fclose(fid);
    catch
        fclose(fid); % Release the resource
        error(['### Failed to generate XCP on Bluetooth file for model: ' sys]);
    end
end
% End of function
