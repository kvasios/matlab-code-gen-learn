% InitAccessorBlock
%   This function is invoked from InitFcn callback of Device Accessor blocks
%   which consist of Data Store Memory blocks.

%   Copyright 2010 The MathWorks, Inc.

function InitAccessorBlock(varargin)

switch nargin
    case 5
        model   = varargin{1};
        blk     = varargin{2};
        name    = varargin{3};
        get_set = varargin{4};
        param1  = varargin{5};
    otherwise
        error('InitAccessorBlock:requires 5 arguments.')
end

% Check simulation mode (stand alone/Model Reference)
if isequal(get_param(model, 'ModelReferenceTargetType'), 'SIM')
    block_id = [model name param1];
else
    block_id = [name param1];
end

if ~isequal(get_param([blk '/Data Store ' get_set], 'DataStoreName'), block_id)
  set_param([blk '/Data Store ' get_set], 'DataStoreName', block_id);         
end
% End of function
                                                                                            