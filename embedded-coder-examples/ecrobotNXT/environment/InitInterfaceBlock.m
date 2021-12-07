% InitInterfaceBlock
%   This function is invoked from InitFcn callback of Device Interface blocks
%   which consist of Data Store Memory blocks.

%   Copyright 2010 The MathWorks, Inc.

function InitInterfaceBlock(varargin)

switch nargin
    case 5
        model   = varargin{1};
        blk     = varargin{2};
        name    = varargin{3};
        get_set = varargin{4};
        param1  = varargin{5};
        param2  = '';
    case 6
        model   = varargin{1};
        blk     = varargin{2};
        name    = varargin{3};
        get_set = varargin{4};
        param1  = varargin{5};
        param2  = varargin{6};
    otherwise
        error('InitInterfaceBlock:requires 5 or 6 arguments.')
end

% Check simulation mode (stand alone/Model Reference)
if isequal(get_param(model, 'ModelReferenceTargetType'), 'SIM')
    block_id = [model name param1];
    createNXTSignalObject(model, [model name], param1);
else
    block_id = [name param1];
    createNXTSignalObject('', name, param1, param2);
end

if ~isequal(get_param([blk '/Data Store ' get_set], 'DataStoreName'), block_id)
  set_param([blk '/Data Store ' get_set], 'DataStoreName', block_id);         
end

set_param([gcb '/Saturation'],'UpperLimit', [block_id '.Max']);             
set_param([gcb '/Saturation'],'LowerLimit', [block_id '.Min']);             
% End of function                                                                                               