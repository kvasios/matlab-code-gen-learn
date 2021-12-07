% set_fcncallname
%   adds signal name to the outputs of a DEMUX block that is connected to 
%   the outport of Export Function-Call Scheduler block. This signal
%   naming is required to specify name of the generated C functions from a 
%   Function-Call Subsystem by using Exported Function code generation
% 
%   SETFCNCALLNAME(BLK, 'clear'): An optional usage of the API. delete added
%   signal name
%

%   Copyright 2010 The MathWorks, Inc.

function set_fcncallname(varargin)

switch nargin
    case 1
        blk = varargin{1};
        cmd = [];
    case 2
        blk = varargin{1};
        cmd = varargin{2};
    otherwise
        error('Requires 1 or 2 arguments')
end

% get line handles of a ExpFcnCallsScheduler block
lh = get_param(blk, 'LineHandles');

if lh.Outport ~= -1
    % get block handle of a block that is connected to outport of a
    % ExpFcnCallsScheduler block
    bh = get_param(lh.Outport, 'DstBlockHandle');
else
    error('No line connected to the Outport of ExpFcnCallsScheduler');
end

if bh ~= -1
    % assume this block should be a DEMUX block
    if isequal(get_param(bh, 'BlockType'), 'Demux')
        % In case of ExpFcnCallsScheduler block is connected to a DEMUX as
        % expected
        lh = get_param(bh, 'LineHandles');
        if lh.Outport ~= -1
            fcname = eval(['{' get_param(blk, 'fcname') '}']);
            if length(lh.Outport) == length(fcname)
                % Use Function-Call name as C function name
                if isequal(cmd, 'clear')
                    for k = 1:length(lh.Outport)
                        set_param(lh.Outport(k), 'Name', '')
                    end
                else
                    for k = 1:length(lh.Outport)
                        set_param(lh.Outport(k), 'Name', fcname{k})
                    end
                end
            else
                error('Function-Call name list and Function-Call source list are unmatch');
            end
        else
            error('No line connected to the Outport of the Demux block');
        end
    else
        error('No Demux block connected to the ExpFcnCallsScheduler');
    end
else
    error('No block connected to the line from ExpFcnCallsScheduler');
end
