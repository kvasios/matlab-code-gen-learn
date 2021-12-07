% nxtconfig
%   sets configuration parameters to be optimised for
%   controller simulation and code generation for LEGO Mindstorms NXT.
%   By default, controller should contain only non-floating point data
%   types for RTW-EC code generation. 
%   To support floating point data typed code generation, it needs to
%   set 'float' as the second argument.
%
%   nxtconfig('model')
%   nxtconfig('model', 'float')

%   Copyright 2010 The MathWorks, Inc.

function nxtconfig(varargin)

cs = getActiveConfigSet(varargin{1});
cgen = 'integer';

switch nargin
    case 1
        cgen = 'integer';
    case 2
        if isequal(lower(varargin{2}), 'float')
            cgen = 'float';
        end
    otherwise
        error('NXTConfig:requires 1 or 2 arguments.');
end

switchTarget(cs,'ert.tlc',[]);
%--------------------------------------------------------------------------
% Solver
set_param(cs,'StartTime', '0');
set_param(cs,'StopTime', 'inf');
set_param(cs,'SimulationMode', 'normal');
set_param(cs,'SolverType', 'Fixed-step');
set_param(cs,'Solver',     'FixedStepDiscrete');
set_param(cs,'FixedStep',   '0.001');
set_param(cs,'SampleTimeConstraint', 'Unconstrained');
set_param(cs,'SolverMode', 'SingleTasking');
set_param(cs,'AutoInsertRateTranBlk', 'off');
set_param(cs,'SolverMode', 'SingleTasking');

%--------------------------------------------------------------------------
% DataIO
set_param(cs,'SaveTime', 'off');
set_param(cs,'SaveOutput', 'off');
set_param(cs,'SignalLogging', 'off');

%--------------------------------------------------------------------------
% Optimization
set_param(cs,'BlockReduction','on');
set_param(cs,'BooleanDataType', 'on');
set_param(cs,'ConditionallyExecuteInputs','on');
set_param(cs,'InlineParams', 'on');
set_param(cs,'InlineInvariantSignals','on');
set_param(cs,'OptimizeBlockIOStorage', 'on');
set_param(cs,'BufferReuse',      'on');
%set_param(cs,'EnforceIntegerDowncast','off'); 
set_param(cs,'EnforceIntegerDowncast','on'); 
% 10/03/26 R2010a generates an waring for the the privious configuration. 
set_param(cs,'ExpressionFolding','on');
set_param(cs,'FoldNonRolledExpr', 'on');
set_param(cs,'LocalBlockOutputs','on');
set_param(cs,'ParameterPooling',  'on');
set_param(cs,'RollThreshold', 2);
set_param(cs,'StateBitsets','on');
set_param(cs,'DataBitsets', 'on');
set_param(cs,'UseTempVars', 'on');
set_param(cs,'ZeroExternalMemoryAtStartup','on');
set_param(cs,'ZeroInternalMemoryAtStartup','on');
set_param(cs,'InitFltsAndDblsToZero',   'off');
set_param(cs,'NoFixptDivByZeroProtection','on');
set_param(cs,'EfficientFloat2IntCast','on');
set_param(cs,'LifeSpan', '1');
set_param(cs,'InlinedParameterPlacement', 'NonHierarchical');
set_param(cs,'OptimizeModelRefInitCode','on');

%--------------------------------------------------------------------------
% Diagnostics
set_param(cs,'AlgebraicLoopMsg',             'error');
set_param(cs,'ArtificialAlgebraicLoopMsg',   'warning');
set_param(cs,'BlockPriorityViolationMsg',    'warning');
set_param(cs,'MinStepSizeMsg',               'warning');
set_param(cs,'UnknownTsInhSupMsg',           'warning');
set_param(cs,'ConsistencyChecking',          'warning');
set_param(cs,'SolverPrmCheckMsg',            'none');
set_param(cs,'InheritedTsInSrcMsg',          'warning');
set_param(cs,'DiscreteInheritContinuousMsg', 'warning');
set_param(cs,'MultiTaskRateTransMsg',        'error');
set_param(cs,'SingleTaskRateTransMsg',       'warning');
set_param(cs,'MultiTaskDSMMsg',              'warning');
set_param(cs,'TasksWithSamePriorityMsg',     'none');
set_param(cs,'SignalResolutionControl',      'TryResolveAllWithWarning');
set_param(cs,'CheckMatrixSingularityMsg',    'none');
set_param(cs,'Int32ToFloatConvMsg',          'warning');
set_param(cs,'ParameterDowncastMsg',         'error');
set_param(cs,'ParameterOverflowMsg',         'error');
set_param(cs,'ParameterPrecisionLossMsg',    'none');
set_param(cs,'UnderSpecifiedDataTypeMsg' ,   'none');
set_param(cs,'UniqueDataStoreMsg',           'error');
% R2007b Model Ref Normal mode requires ArrayBoundsChecking to be 'none'
set_param(cs,'ArrayBoundsChecking',          'none');
set_param(cs,'IntegerOverflowMsg',           'error');
set_param(cs,'SignalInfNanChecking',         'warning');
set_param(cs,'AssertControl',                'UseLocalSettings');
set_param(cs,'RTPrefix',                     'error');
set_param(cs,'ReadBeforeWriteMsg',           'DisableAll');
set_param(cs,'WriteAfterWriteMsg',           'DisableAll');
set_param(cs,'WriteAfterReadMsg',            'DisableAll');
set_param(cs,'UnnecessaryDatatypeConvMsg',   'none');
set_param(cs,'VectorMatrixConversionMsg',    'none');
set_param(cs,'SignalLabelMismatchMsg',       'none' );
set_param(cs,'UnconnectedInputMsg',          'error');
set_param(cs,'UnconnectedOutputMsg',         'error');
set_param(cs,'UnconnectedLineMsg',           'error');
set_param(cs,'RootOutportRequireBusObject',  'error');
set_param(cs,'BusObjectLabelMismatch',       'error');
set_param(cs,'InvalidFcnCallConnMsg',        'error');
set_param(cs,'FcnCallInpInsideContextMsg',   'Use local settings');
set_param(cs,'SFcnCompatibilityMsg',         'none');
set_param(cs,'CheckSSInitialOutputMsg',      'on');
set_param(cs,'CheckExecutionContextPreStartOutputMsg', 'on');
set_param(cs,'CheckExecutionContextRuntimeOutputMsg', 'on');
set_param(cs,'ModelReferenceVersionMismatchMessage','warning');
set_param(cs,'ModelReferenceIOMismatchMessage',     'warning');
set_param(cs,'ModelReferenceCSMismatchMessage',     'none');
set_param(cs,'ModelReferenceIOMsg',                 'warning');
set_param(cs,'ModelReferenceDataLoggingMessage',    'warning');

%--------------------------------------------------------------------------
% Hardware Implementation
set_param(cs,'ProdHWDeviceType','ARM7');
set_param(cs,'ProdIntDivRoundTo', 'Zero');
set_param(cs,'ProdShiftRightIntArith','on');
set_param(cs,'ProdEndianess','LittleEndian');
set_param(cs,'ProdEqTarget','on');

%--------------------------------------------------------------------------
% Model Reference
set_param(cs,'UpdateModelReferenceTargets', 'IfOutOfDateOrStructuralChange')
set_param(cs,'ModelReferenceNumInstancesAllowed', 'Single');
set_param(cs,'ModelReferencePassRootInputsByReference', 'on');
set_param(cs,'ModelReferenceMinAlgLoopOccurrences', 'off');

%--------------------------------------------------------------------------
% Real-Time Workshop
% pure integer cgen/floating point cgen can be configred
if isequal(cgen, 'integer')
    set_param(cs,'PurelyIntegerCode','on');
elseif isequal(cgen, 'float')
    set_param(cs,'PurelyIntegerCode','off');
end

set_param(cs, 'TargetLang', 'C');
set_param(cs,'TemplateMakefile', 'ert_default_tmf');
set_param(cs,'MakeCommand', 'make_rtw');
set_param(cs,'GenerateMakefile', 'off');
set_param(cs,'IgnoreCustomStorageClasses','off');
set_param(cs,'GenCodeOnly','on');
set_param(cs,'GenerateReport','on');
set_param(cs,'IncludeHyperlinkInReport','on');
set_param(cs,'LaunchReport','on');
set_param(cs,'GenerateComments','on');
set_param(cs,'SimulinkBlockComments','on');
set_param(cs,'ShowEliminatedStatement','off');
set_param(cs,'ForceParamTrailComments','on');
set_param(cs,'InsertBlockDesc','on');
set_param(cs,'SimulinkDataObjDesc','off');
set_param(cs,'EnableCustomComments','off');
set_param(cs,'CustomCommentsFcn','');
set_param(cs,'SFDataObjDesc','on');
set_param(cs,'ReqsInCode','off');
set_param(cs,'MaxIdLength',31);
set_param(cs,'MangleLength',1);
set_param(cs,'CustomSymbolStrGlobalVar','rt$N$M');
set_param(cs,'CustomSymbolStrType','$N$M');
set_param(cs,'CustomSymbolStrField','$N$M');
set_param(cs,'CustomSymbolStrFcn','$N$M$F');
set_param(cs,'CustomSymbolStrTmpVar','$N$M');
set_param(cs,'CustomSymbolStrBlkIO','rtb_$N$M');
set_param(cs,'CustomSymbolStrMacro','$N$M');
set_param(cs,'InlinedPrmAccess','Literals');
set_param(cs,'DefineNamingRule','None');
set_param(cs,'ParamNamingRule','None');
set_param(cs,'SignalNamingRule','None');
set_param(cs,'RTWVerbose',   'off');
set_param(cs,'RetainRTWFile','off');
set_param(cs,'ProfileTLC',   'off');
set_param(cs,'TLCDebug',     'off');
set_param(cs,'TLCCoverage',  'off');
set_param(cs,'TLCAssert',    'off');
set_param(cs,'GenFloatMathFcnCalls','GNU');
set_param(cs,'TargetFcnLib','ansi_tfl_tmw.mat');
set_param(cs,'UtilityFuncGeneration','Auto');
set_param(cs,'SupportNonFinite','off');
set_param(cs,'SupportAbsoluteTime','off');
set_param(cs,'SupportComplex','off');
set_param(cs,'SupportContinuousTime','off');
set_param(cs,'SupportNonInlinedSFcns','off');
set_param(cs,'IncludeMdlTerminateFcn','off');
set_param(cs,'MultiInstanceERTCode','off');
set_param(cs,'MultiInstanceErrorCode','Error');
set_param(cs,'RootIOFormat','Structure Reference');
set_param(cs,'SuppressErrorStatus','on');
set_param(cs,'GRTInterface','off');
set_param(cs,'CombineOutputUpdateFcns','on');
set_param(cs,'GenerateErtSFunction','off');
set_param(cs,'MatFileLogging','off');
set_param(cs,'RTWCAPIParams','off');
set_param(cs,'RTWCAPISignals','off');
set_param(cs,'GenerateASAP2','off');
set_param(cs,'ExtMode','off');
set_param(cs,'GenerateSampleERTMain', 'off');
set_param(cs,'TargetOS', 'BareBoardExample');
set_param(cs,'GlobalDataDefinition', 'Auto');
set_param(cs,'DataDefinitionFile', '');
set_param(cs,'GlobalDataReference', 'Auto');
set_param(cs,'DataReferenceFile', '');
set_param(cs,'IncludeFileDelimiter', 'Auto');
set_param(cs,'ModuleNamingRule', 'Unspecified');
set_param(cs,'ModuleName', '');
set_param(cs,'SignalDisplayLevel', 10);
set_param(cs,'ParamTuneLevel', 10);
set_param(cs,'InitialValueSource', 'Model');
set_param(cs,'EnableUserReplacementTypes', 'off');
set_param(cs,'CodeGenDirectory', '');
set_param(cs,'IncDataTypeInIds', 'off');
set_param(cs,'GenerateFullHeader', 'on');
set_param(cs,'IsPILTarget', 'off');
set_param(cs,'IncHierarchyInIds', 'off');
set_param(cs,'PrefixModelToSubsysFcnNames', 'off');

% End of function