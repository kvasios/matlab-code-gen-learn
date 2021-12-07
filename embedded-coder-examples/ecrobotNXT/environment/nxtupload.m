function nxtupload

% NXTUPLOAD
% Upload specified a nxtOSEK executable (*.rxe or *.bin) to the NXT.
%
% How to use:
% >>nxtupload
% and then,
% choose *.rxe for a NXT which has enhanced NXT standard firmware
% or
% choose *.bin for a NXT which has NXT BIOS
%

%   Copyright 2010 The MathWorks, Inc.

ecrobotnxtsetupinfo;

[filename, pathname] = uigetfile('*.rxe;*.bin');
if filename == 0
    return;
end
file = fullfile(pathname, filename);
[path,name,ext,version] = fileparts(file);

current_dir = pwd;
cd(path);
if strcmpi(ext, '.bin')
    script = 'appflash.sh';
    fid = fopen(script, 'w');
    if fid == -1
        error(['Error: could not open ' script]);
        cd(current_dir);
    end
    
    fprintf(fid, ['echo Executing appflash to upload ' filename '...\n']);
    fprintf(fid, [iConvAbsPath2CygPath(regexprep(fileparts(which('nxtbuild.m')), '\', '/')) ...
        '/nxtOSEK/bin/appflash.exe ./' filename '\n']); 
    fclose(fid);

elseif strcmpi(ext, '.rxe')
    script = 'rxeflash.sh';
    fid = fopen(script, 'w');
    if fid == -1
        error(['Error: could not open ' script]);
        cd(current_dir);
    end
    
    fprintf(fid, ['echo Executing NeXTTool to upload ' filename '...\n']);
    fprintf(fid, [iConvAbsPath2CygPath(ECROBOTNXT_NEXTTOOL_ROOT) '/NeXTTool.exe /COM=usb -download=' filename '\n']);
    fprintf(fid, [iConvAbsPath2CygPath(ECROBOTNXT_NEXTTOOL_ROOT) '/NeXTTool.exe /COM=usb -listfiles=' filename '\n']);
    fprintf(fid, 'echo NeXTTool is terminated.\n');
    fclose(fid);

end

iGenerateBuildBat(ECROBOTNXT_CYGWIN_BIN);
iGenerateCommand(['sh ./' script]);

cd(current_dir);

% End of function

% End of file
