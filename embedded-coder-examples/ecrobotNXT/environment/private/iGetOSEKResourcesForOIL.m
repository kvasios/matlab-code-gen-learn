% iGetOSEKResourcesForOIL
%   retrieves used OSEK Resources in the Function-Call Subsystems which have 
%   the specified Function-Call name in Exported Function-Call Scheduler
%   block.

%   Copyright 2010 The MathWorks, Inc.

function resources = iGetOSEKResourcesForOIL(varargin)

switch nargin
    case 2
        blk = varargin{1};
        tsk = varargin{2};
    otherwise
        error('Requires 2 arguments')
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
                % Check all lines connected to destination ports of the Demux block
                for k = 1:length(lh.Outport)
                    % Compare the signal name with the second argument
                    if isequal(get_param(lh.Outport(k), 'Name'), tsk)
                        bh = get_param(lh.Outport(k), 'DstBlockHandle');
                        if bh ~= -1
                            if isequal(get_param(bh, 'BlockType'), 'SubSystem')
                                ph = get_param(lh.Outport(k), 'DstPortHandle');
                                pnum = get_param(ph, 'portnumber');
                                resources = track_fcncall_subsystem(bh, pnum);
                            else
                                error('No SubSystem connected to the Demux block');
                            end
                            break;
                        else
                            error(['No block connected to the line the line' tsk]);
                        end
                    elseif k == length(lh.Outport)
                        error(['Could not find a line with specified Function-Call name ' tsk]);
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

function reslist = track_fcncall_subsystem(sys, inportnum)
%TRACK_FCNCALL_SUBSYSTEM(INPORTNUM): finds a Function-Call Subsystem whose
%trigger port is connected to the Inport block with the port number INPORTNUM
%under SYS

inbh = find_system(sys, 'SearchDepth', 1, 'LookUnderMasks', 'none', ...
    'blocktype', 'Inport', 'Port', num2str(inportnum));
% get line handles of an Inport block
inportlh = get_param(inbh, 'LineHandles');

if inportlh.Outport ~= -1
    % get block handle of a block that is connected to the specified inport block
    atombh = get_param(inportlh.Outport, 'DstBlockHandle');
else
    error('No line connected to the specified inport block');
end

if atombh ~= -1
    atomlh = get_param(atombh, 'LineHandles');
    if atomlh.Trigger == inportlh.Outport
        % find the OSEK Resource block under the specified Function-Call Subsystem
        osek_resbh = find_system(atombh, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
            'FindAll', 'on', 'ReferenceBlock', 'ecrobot_nxt_lib/OSEK Resource');
        reslist = {};
        if ~isempty(osek_resbh)
            for k = 1:length(osek_resbh)
                resparam = get_param(osek_resbh(k), 'Resource');
                % do not add the same element in the list
                if ~ismember(resparam, reslist)
                    reslist{end + 1} = resparam;
                end
            end
        end
    else
        error('Input port is not connected to Trigger port');
    end
else
    error('No block connected to the line from the specified inport block');
end
% End of function
