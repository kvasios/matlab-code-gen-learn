AC6_tc = AC6_embedded_toolchain();
save AC6Toolchain AC6_tc; % save the AC6_tc object to AC6Toolchain.mat file

function tc = AC6_embedded_toolchain()
% -----------------------------
% Toolchain Overview & init
% -----------------------------
platform = computer('arch');
version = '1.0';
artifact = 'gmake';

tc = coder.make.ToolchainInfo('BuildArtifact', 'gmake makefile', 'SupportedLanguages', {'Asm/C/C++'});
tc.Name = 'Arm Compiler 6 Toolchain';
%tc.Name = coder.make.internal.formToolchainName('Arm Compiler 6 for Arm Cortex-M Processors', ...
%    platform, version, artifact);
tc.Platform = platform;
tc.setBuilderApplication(platform);

% Need this to set path to executables (no arguments, returns nothing)
% Setup
tc.MATLABSetup = 'AC6_setup();';


% --------------
% Includes
% --------------
make = tc.BuilderApplication();
make.IncludeFiles = {'codertarget_assembly_flags.mk', '../codertarget_assembly_flags.mk'};

% --------------
% Attributes
% --------------
tc.addAttribute('TransformPathsWithSpaces');
if any(ismember(platform, {'win64','win32'}))
    tc.addAttribute('RequiresBatchFile');
end
tc.addAttribute('SupportsUNCPaths',     false);
tc.addAttribute('SupportsDoubleQuotes', false);

% ----------------------------------------
% Macros: Intrinsic and Defined elsewhere
% ----------------------------------------
tc.addIntrinsicMacros({'TARGET_LOAD_CMD_ARGS'});
tc.addIntrinsicMacros({'TARGET_LOAD_CMD'});
tc.addMacro('PRODUCT_BIN', '$(RELATIVE_PATH_TO_ANCHOR)/$(PRODUCT_NAME).bin');
tc.addMacro('PRODUCT_HEX', '$(RELATIVE_PATH_TO_ANCHOR)/$(PRODUCT_NAME).hex');

%AC6Path = getenv('PATH_TO_AC6_BIN_DIR'); %AC6Path = getpref('ArmCompiler','AC6_Path');
%tc.addMacro('PATH_TO_AC6_BIN_DIR',AC6Path);

% Work around for cygwin, override SHELL variable
    % http://www.gnu.org/software/make/manual/make.html#Choosing-the-Shell
if isequal(platform, 'win64')
    tc.addMacro('SHELL', '%SystemRoot%/system32/cmd.exe');
end

% ------------------------------
% Set File Extention Variables
% ------------------------------
objectExtension = '.o';
depfileExtension = '.d';


% ----------------
% Inline Commands
% ----------------
tc.InlinedCommands{1} = 'ALL_DEPS:=$(patsubst %$(OBJ_EXT),%$(DEP_EXT),$(ALL_OBJS))';
tc.InlinedCommands{2} = 'all:';
tc.InlinedCommands{3} = '';


% -----------
% Assembler
% -----------
assembler = tc.getBuildTool('Assembler');
assembler.setName('AC6 Assembler');
assembler.setPath('$(PATH_TO_AC6_BIN_DIR)');
assembler.setCommand('armasm');
assembler.setDirective('IncludeSearchPath', '-I');
assembler.setDirective('PreprocessorDefine', '-D');
assembler.setDirective('OutputFlag', '-o');
assembler.setDirective('Debug', '-g');
assembler.DerivedFileExtensions = {'Object'};
assembler.setFileExtension('Source','.s');
assembler.addFileExtension( 'ASMType1Source', coder.make.BuildItem('ASM_Type1_Ext', '.S'));
assembler.setFileExtension('Object', objectExtension);
assembler.addFileExtension( 'DependencyFile', coder.make.BuildItem('DEP_EXT', depfileExtension));
assembler.DerivedFileExtensions = {depfileExtension};
assembler.InputFileExtensions = {'Source', 'ASMType1Source'};

% -----------------------------
% C Compiler
% -----------------------------
compiler = tc.getBuildTool('C Compiler');
compiler.setName('AC6 C Compiler');
compiler.setPath('$(PATH_TO_AC6_BIN_DIR)');
compiler.setCommand('armclang');
compiler.setDirective('PreprocessFile', '-E');   % enables code coverage to work
compiler.setDirective('CompileFlag', '-c');   % enables code coverage to work
compiler.setDirective('IncludeSearchPath', '-I');
compiler.setDirective('PreprocessorDefine', '-D');
compiler.setDirective('OutputFlag', '-o');
compiler.setDirective('Debug', '-g');
compiler.setFileExtension('Source', '.c');
compiler.setFileExtension('Header', '.h');
compiler.setFileExtension('Object', objectExtension);
compiler.addFileExtension( 'DependencyFile', coder.make.BuildItem('DEP_EXT', depfileExtension));
compiler.DerivedFileExtensions = {depfileExtension};

% -----------------------------
% C++ compiler
% -----------------------------
cppompiler = tc.getBuildTool('C++ Compiler');
cppompiler.setName('AC6 C++ Compiler');
cppompiler.setPath('$(PATH_TO_AC6_BIN_DIR)');
cppompiler.setCommand('armclang');
cppompiler.setDirective('PreprocessFile', '-E');   % enables code coverage to work
cppompiler.setDirective('CompileFlag', '-c');   % enables code coverage to work
cppompiler.setDirective('IncludeSearchPath', '-I');
cppompiler.setDirective('PreprocessorDefine', '-D');
cppompiler.setDirective('OutputFlag', '-o');
cppompiler.setDirective('Debug', '-g');
cppompiler.setFileExtension('Source', '.cpp');
cppompiler.setFileExtension('Header', '.h');
cppompiler.setFileExtension('Object', objectExtension);
cppompiler.addFileExtension( 'DependencyFile', coder.make.BuildItem('DEP_EXT', depfileExtension));
cppompiler.DerivedFileExtensions = {depfileExtension};

% -----------------------------
% C Linker
% -----------------------------
linker = tc.getBuildTool('Linker');
linker.setName('AC6 Linker');
linker.setPath('$(PATH_TO_AC6_BIN_DIR)');
linker.setCommand('armlink');
linker.setDirective('Library', '-l');
linker.setDirective('LibrarySearchPath', '-L');
% linker.addDirective('LinkerFile', {''});
% linker.setDirective('LinkerFile', '--scatter');
linker.setDirective('OutputFlag', '-o');
linker.setDirective('Debug', '--debug');
linker.setFileExtension('Executable', '.elf');
linker.setFileExtension('Shared Library', '.so');
% linker.Libraries = {'-lm'};

% -----------------------------
% C++ Linker
% -----------------------------
linker = tc.getBuildTool('C++ Linker');
linker.setName('AC6 C++ Linker');
linker.setPath('$(PATH_TO_AC6_BIN_DIR)');
linker.setCommand('armlink');
linker.setDirective('Library', '-l');
linker.setDirective('LibrarySearchPath', '-L');
% linker.addDirective('LinkerFile', {''});
% linker.setDirective('LinkerFile', '--scatter');
linker.setDirective('OutputFlag', '-o');
linker.setDirective('Debug', '-g');
linker.setFileExtension('Executable', '.elf');
linker.setFileExtension('Shared Library', '.so');
% linker.Libraries = {'-lm'};

% -----------------------------
% Archiver
% -----------------------------
archiver = tc.getBuildTool('Archiver');
archiver.setName('AC6 Archiver');
archiver.setPath('$(PATH_TO_AC6_BIN_DIR)');
archiver.setCommand('armar');
archiver.setDirective('OutputFlag', '');
archiver.setFileExtension('Static Library', '.lib');

% -----------------------------
% ELF to binary converter 
% -----------------------------
postbuildToolName = 'ELF To Binary Converter';
postbuild = tc.addPostbuildTool(postbuildToolName); 
postbuild.setCommand('ELF_TO_BIN', '$(PATH_TO_AC6_BIN_DIR)/fromelf');     % Command macro & value
postbuild.OptionsRegistry = {postbuildToolName, 'OBJCOPYFLAGS_BIN'}; % The tool鈥檚 options
postbuild.SupportedOutputs = {coder.make.enum.BuildOutput.EXECUTABLE}; % Output type from the tool
tc.addBuildConfigurationOption(postbuildToolName, postbuild);  
tc.setBuildConfigurationOption('all', postbuildToolName, '--bin --output $(PRODUCT_BIN) $(PRODUCT)'); 

% -----------------------------
% ELF to hex converter 
% -----------------------------
postbuildToolName = 'ELF To Hex Converter';
postbuild = tc.addPostbuildTool(postbuildToolName);       
postbuild.setCommand('ELF_TO_HEX', '$(PATH_TO_AC6_BIN_DIR)/fromelf');     % Command macro & value
postbuild.OptionsRegistry = {postbuildToolName, 'OBJCOPYFLAGS_HEX'}; % The tool鈥檚 options
postbuild.SupportedOutputs = {coder.make.enum.BuildOutput.EXECUTABLE}; % Output type from the tool
tc.addBuildConfigurationOption(postbuildToolName, postbuild);  
tc.setBuildConfigurationOption('all', postbuildToolName, '--i32 --output $(PRODUCT_HEX) $(PRODUCT)'); 

% -----------------------------
% Size of ELF
% -----------------------------
postbuildToolName = 'Executable Size';
postbuild = tc.addPostbuildTool(postbuildToolName);            
postbuild.setCommand('EXESIZE', '$(PATH_TO_AC6_BIN_DIR)/fromelf');     % Command macro & value
postbuild.OptionsRegistry = {postbuildToolName, 'EXESIZE_FLAGS'}; % The tool鈥檚 options
postbuild.SupportedOutputs = {coder.make.enum.BuildOutput.EXECUTABLE}; % Output type from tool
tc.addBuildConfigurationOption(postbuildToolName, postbuild);  
tc.setBuildConfigurationOption('all', postbuildToolName, '-z $(PRODUCT)');


%% Flags

% ------------------------
% C / C++ Compiler Flags
% ------------------------
cCompilerOpts = {};
cppCompilerOpts = {'-std=c++98 -fno-rtti -fno-exceptions'};

optimsOffOpts = {'-O1'};
optimsOnOpts = {'-O3'};
compilerOpts = {'--target=arm-arm-none-eabi -Wall -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@" -c'};

% -----------------
% Archiver Flags
% -----------------
% r[ab][f][u]  - replace existing or insert new file(s) into the archive 
% [v]          - be verbose 
% [s]          - create an archive index (cf. ranlib)
archiverOpts = {'-ruvs'}; 

% -----------------
% Assembly Flags
% -----------------
assemblerOpts = {...
	'--md', ...
    '$(ASFLAGS_ADDITIONAL)', ...
    };

% -----------------
% Linker Flags
% -----------------
linkerOpts = { ...
    '--list $(PRODUCT_NAME).map', ...
    '--strict', ...
    '--summary_stderr', ...
	'--info summarysizes', ... 
	'--map --xref', ...
	'--symbols', ...
	'--info sizes', ... 
	'--info totals', ... 
	'--info unused', ... 
	'--info veneers', ... 
    };%'--callgraph', ...
    %};

% ---------------------------------
% Debug Flags for each build tool
% ---------------------------------
debugFlag.CCompiler   = '-g';  
debugFlag.Linker      = '--debug'; 
debugFlag.Archiver    = ''; 


%% Build Configurations

% --------------
% Faster Builds
% --------------
cfg = tc.getBuildConfiguration('Faster Builds');
cfg.setOption('Assembler',  	horzcat(assemblerOpts));
cfg.setOption('C Compiler', 	horzcat(cCompilerOpts, compilerOpts, optimsOffOpts));
cfg.setOption('Linker',     	linkerOpts);
cfg.setOption('C++ Compiler', 	horzcat(cppCompilerOpts, compilerOpts, optimsOffOpts));
cfg.setOption('C++ Linker',     linkerOpts);
cfg.setOption('Archiver',   	archiverOpts);

% --------------
% Faster Runs
% --------------
cfg = tc.getBuildConfiguration('Faster Runs');
cfg.setOption('Assembler',  	horzcat(assemblerOpts));
cfg.setOption('C Compiler', 	horzcat(cCompilerOpts, compilerOpts, optimsOnOpts));
cfg.setOption('Linker',     	linkerOpts);
cfg.setOption('C++ Compiler', 	horzcat(cppCompilerOpts, compilerOpts, optimsOnOpts));
cfg.setOption('C++ Linker',     linkerOpts);
cfg.setOption('Archiver',   	archiverOpts);

% --------------
% Debug
% --------------
cfg = tc.getBuildConfiguration('Debug');
cfg.setOption('Assembler',  	horzcat(assemblerOpts, debugFlag.CCompiler));
cfg.setOption('C Compiler', horzcat(cCompilerOpts, compilerOpts, optimsOffOpts, debugFlag.CCompiler));
cfg.setOption('Linker',     horzcat(linkerOpts, debugFlag.Linker));
cfg.setOption('C++ Compiler', 	horzcat(cCompilerOpts, compilerOpts, optimsOffOpts, debugFlag.CCompiler));
cfg.setOption('C++ Linker',     horzcat(linkerOpts, debugFlag.Linker));
cfg.setOption('Archiver',   horzcat(archiverOpts, debugFlag.Archiver));

% --------------
% Set Make tool
% --------------
tc.setBuildConfigurationOption('all', 'Make Tool', '-f $(MAKEFILE)');
makeTool = tc.BuilderApplication;
if isequal(platform, 'win64')
makeTool.setDirective('DeleteCommand', '@del /f/q');
else
makeTool.setDirective('DeleteCommand', '@rm -rf');
end
end


