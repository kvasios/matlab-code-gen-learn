function tc = fsci_tc
%fsci_tc Creates an Franka Emika 64 bit linux ToolchainInfo object.

% Copyright 2012-2016 The MathWorks, Inc.

tc = coder.make.ToolchainInfo('BuildArtifact', 'nmake makefile');
tc.Name             = 'Franka Simulink Control Interface | nmake makefile (64-bit linux)';
tc.Platform         = 'glnxa64';
tc.SupportedVersion = '4.4.x';

tc.addAttribute('TransformPathsWithSpaces');
% tc.addAttribute('RequiresCommandFile');
% tc.addAttribute('RequiresBatchFile');

% ------------------------------
% Setup
% ------------------------------
% Below we are using %ICPP_COMPILER14% as root folder where Intel Compiler is installed.
% You can either set an environment variable or give full path to the
% compilervars.bat file
% tc.ShellSetup{1} = 'call %ICPP_COMPILER14%\bin\compilervars.bat intel64';


% ------------------------------
% Macros
% ------------------------------
tc.addMacro('MW_EXTERNLIB_DIR',     ['$(MATLAB_ROOT)\extern\lib\' tc.Platform '\microsoft']);
tc.addMacro('MW_LIB_DIR',           ['$(MATLAB_ROOT)\lib\' tc.Platform]);
tc.addMacro('CFLAGS_ADDITIONAL',    '-D_CRT_SECURE_NO_WARNINGS');
tc.addMacro('CPPFLAGS_ADDITIONAL',  '-EHs -D_CRT_SECURE_NO_WARNINGS');
tc.addMacro('LIBS_TOOLCHAIN',       '$(conlibs)');
tc.addMacro('CVARSFLAG',            '');

tc.addIntrinsicMacros({'ldebug', 'conflags', 'cflags'});

% ------------------------------
% C Compiler
% ------------------------------
 
tool = tc.getBuildTool('C Compiler');

tool.setName(           'Intel C Compiler');
tool.setCommand(        'icl');
tool.setPath(           '');

tool.setDirective(      'IncludeSearchPath',    '-I');
tool.setDirective(      'PreprocessorDefine',   '-D');
tool.setDirective(      'OutputFlag',           '-Fo');
tool.setDirective(      'Debug',                '-Zi');

tool.setFileExtension(  'Source',               '.c');
tool.setFileExtension(  'Header',               '.h');
tool.setFileExtension(  'Object',               '.obj');

tool.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');

% ------------------------------
% C++ Compiler
% ------------------------------

tool = tc.getBuildTool('C++ Compiler');

tool.setName(           'Intel C++ Compiler');
tool.setCommand(        'icl');
tool.setPath(           '');

tool.setDirective(      'IncludeSearchPath',  	'-I');
tool.setDirective(      'PreprocessorDefine', 	'-D');
tool.setDirective(      'OutputFlag',           '-Fo');
tool.setDirective(      'Debug',                '-Zi');

tool.setFileExtension(  'Source',               '.cpp');
tool.setFileExtension(  'Header',               '.hpp');
tool.setFileExtension(  'Object',               '.obj');

tool.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');

% ------------------------------
% Linker
% ------------------------------

tool = tc.getBuildTool('Linker');

tool.setName(           'Intel C/C++ Linker');
tool.setCommand(        'xilink');
tool.setPath(           '');

tool.setDirective(      'Library',              '-L');
tool.setDirective(      'LibrarySearchPath',    '-I');
tool.setDirective(      'OutputFlag',           '-out:');
tool.setDirective(      'Debug',                '');

tool.setFileExtension(  'Executable',           '.exe');
tool.setFileExtension(  'Shared Library',       '.dll');

tool.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');

% ------------------------------
% C++ Linker
% ------------------------------

tool = tc.getBuildTool('C++ Linker');

tool.setName(           'Intel C/C++ Linker');
tool.setCommand(        'xilink');
tool.setPath(           '');

tool.setDirective(      'Library',              '-L');
tool.setDirective(      'LibrarySearchPath',    '-I');
tool.setDirective(      'OutputFlag',           '-out:');
tool.setDirective(      'Debug',                '');

tool.setFileExtension(  'Executable',           '.exe');
tool.setFileExtension(  'Shared Library',       '.dll');

tool.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');

% ------------------------------
% Archiver
% ------------------------------

tool = tc.getBuildTool('Archiver');

tool.setName(           'Intel C/C++ Archiver');
tool.setCommand(        'xilib');
tool.setPath(           '');
tool.setDirective(      'OutputFlag',           '-out:');
tool.setFileExtension(  'Static Library',       '.lib');
tool.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');

% ------------------------------
% Builder
% ------------------------------

tc.setBuilderApplication(tc.Platform);

% --------------------------------------------
% BUILD CONFIGURATIONS
% --------------------------------------------

optimsOffOpts    = {'/c /Od'};
optimsOnOpts     = {'/c /O2'};
cCompilerOpts    = '$(cflags) $(CVARSFLAG) $(CFLAGS_ADDITIONAL)';
cppCompilerOpts  = '$(cflags) $(CVARSFLAG) $(CPPFLAGS_ADDITIONAL)';
linkerOpts       = {'$(ldebug) $(conflags) $(LIBS_TOOLCHAIN)'};
sharedLinkerOpts = horzcat(linkerOpts, '-dll -def:$(DEF_FILE)');
archiverOpts     = {'/nologo'};

% Get the debug flag per build tool
debugFlag.CCompiler   = '$(CDEBUG)';   
debugFlag.CppCompiler = '$(CPPDEBUG)';
debugFlag.Linker      = '$(LDDEBUG)';  
debugFlag.CppLinker   = '$(CPPLDDEBUG)';  
debugFlag.Archiver    = '$(ARDEBUG)';  

% Set the toolchain flags for 'Faster Builds' build configuration

cfg = tc.getBuildConfiguration('Faster Builds');
cfg.setOption( 'C Compiler',                horzcat(cCompilerOpts,   optimsOffOpts));
cfg.setOption( 'C++ Compiler',              horzcat(cppCompilerOpts, optimsOffOpts));
cfg.setOption( 'Linker',                    linkerOpts);
cfg.setOption( 'C++ Linker',                linkerOpts);
cfg.setOption( 'Shared Library Linker',     sharedLinkerOpts);
cfg.setOption( 'Archiver',                  archiverOpts);

% Set the toolchain flags for 'Faster Runs' build configuration

cfg = tc.getBuildConfiguration('Faster Runs');
cfg.setOption( 'C Compiler',                horzcat(cCompilerOpts,   optimsOnOpts));
cfg.setOption( 'C++ Compiler',              horzcat(cppCompilerOpts, optimsOnOpts));
cfg.setOption( 'Linker',                    linkerOpts);
cfg.setOption( 'C++ Linker',                linkerOpts);
cfg.setOption( 'Shared Library Linker',     sharedLinkerOpts);
cfg.setOption( 'Archiver',                  archiverOpts);

% Set the toolchain flags for 'Debug' build configuration

cfg = tc.getBuildConfiguration('Debug');
cfg.setOption( 'C Compiler',              	horzcat(cCompilerOpts,   optimsOffOpts, debugFlag.CCompiler));
cfg.setOption( 'C++ Compiler',          	horzcat(cppCompilerOpts, optimsOffOpts, debugFlag.CppCompiler));
cfg.setOption( 'Linker',                	horzcat(linkerOpts,       debugFlag.Linker));
cfg.setOption( 'C++ Linker',               	horzcat(linkerOpts,       debugFlag.CppLinker));
cfg.setOption( 'Shared Library Linker',  	horzcat(sharedLinkerOpts, debugFlag.Linker));
cfg.setOption( 'Archiver',              	horzcat(archiverOpts,     debugFlag.Archiver));

tc.setBuildConfigurationOption('all', 'Download',      '');
tc.setBuildConfigurationOption('all', 'Execute',       '');
tc.setBuildConfigurationOption('all', 'Make Tool',     '-f $(MAKEFILE)');