% sfunxymap2
%   S-function that acts as an X-Y scope with bit map image display

%   Copyright 2010 The MathWorks, Inc.

function [sys, x0, str, ts] = sfunxymap2(t,x,u,flag,ax,map)

% Store the block handle and check if it's valid
blockHandle = gcbh;
IsValidBlock(blockHandle, flag);

switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0
    [sys,x0,str,ts] = mdlInitializeSizes(ax);
    SetBlockCallbacks(blockHandle);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2
    sys = mdlUpdate(t,x,u,flag,ax,map,blockHandle);

  %%%%%%%%%
  % Start %
  %%%%%%%%%
  case 'Start'
    LocalBlockStartFcn(blockHandle)

  %%%%%%%%
  % Stop %
  %%%%%%%%
  case 'Stop'
    LocalBlockStopFcn(blockHandle)

  %%%%%%%%%%%%%%
  % NameChange %
  %%%%%%%%%%%%%%
  case 'NameChange'
    LocalBlockNameChangeFcn(blockHandle)

  %%%%%%%%%%%%%%%%%%%%%%%%
  % CopyBlock, LoadBlock %
  %%%%%%%%%%%%%%%%%%%%%%%%
  case { 'CopyBlock', 'LoadBlock' }
    LocalBlockLoadCopyFcn(blockHandle)

  %%%%%%%%%%%%%%%
  % DeleteBlock %
  %%%%%%%%%%%%%%%
  case 'DeleteBlock'
    LocalBlockDeleteFcn(blockHandle)

  %%%%%%%%%%%%%%%%
  % DeleteFigure %
  %%%%%%%%%%%%%%%%
  case 'DeleteFigure'
    LocalFigureDeleteFcn

  %%%%%%%%%%%%%%%%
  % Unused flags %
  %%%%%%%%%%%%%%%%
  case { 3, 9 }
    sys = [];

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    if ischar(flag),
      errmsg=sprintf('Unhandled flag: ''%s''', flag);
    else
      errmsg=sprintf('Unhandled flag: %d', flag);
    end

    error(errmsg);

end

% end sfunxy

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(ax)

if length (ax)~=4
  error(['Axes limits must be defined.'])
end

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0 = [];

str = [];

ts = [-1 0];

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,flag,ax,map,block)

%
% always return empty, there are no states...
%
sys = [];

%
% Locate the figure window associated with this block.  If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=GetSfunXYFigure(block);
if ~ishandle(FigHandle),
   return
end

%
% Get UserData of the figure.
%
ud = get(FigHandle,'UserData');
if isempty(ud.XData),
  x_data = [u(1) u(1)];
  y_data = [u(2) u(2)];
else
  x_data = [ud.XData(end) u(1)];
  y_data = [ud.YData(end) u(2)];
end

% plot the input lines
set(ud.XYAxes, ...
    'Xlim', ax(1:2),...
    'Ylim', ax(3:4));

set(ud.XYLine(1),...
    'Xdata',x_data,...
    'Ydata',y_data);

set(ud.XYTitle,'String','X Y Plot');
set(FigHandle,'Color',get(FigHandle,'Color'));

% Draw track map
DrawTrackMap(block, map); 

%
% update the X/Y stored data points
%
ud.XData(end+1) = u(1);
ud.YData(end+1) = u(2);
set(FigHandle,'UserData',ud);
drawnow

% end mdlUpdate

%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% XY Graph scope figure.
%=============================================================================
%
function LocalBlockStartFcn(block)

%
% get the figure associated with this block, create a figure if it doesn't
% exist
%
FigHandle = GetSfunXYFigure(block);
if ~ishandle(FigHandle),
  FigHandle = CreateSfunXYFigure(block);
end

ud = get(FigHandle,'UserData');
set(ud.XYLine(1),'Erasemode','normal');
set(ud.XYLine(1),'XData',[],'YData',[]);
set(ud.XYLine(1),'XData',0,'YData',0,'Erasemode','none');
set(ud.XYLine(1),'Color', [1 0.5 0.25]); % Line color is orange
set(ud.XYLine(1),'LineWidth', 1.5);

ud.XData = [];
ud.YData = [];

set(FigHandle,'UserData',ud);

% end LocalBlockStartFcn

%
%=============================================================================
% DrawTrackMap
%=============================================================================
%
function DrawTrackMap(block,map)

FigHandle=GetSfunXYFigure(block);

if ishandle(FigHandle)
  %
  % Get UserData of the figure.
  %
  ud = get(FigHandle,'UserData');

  numOfRow = size(map,1);
  for i=1:numOfRow
      map1(numOfRow+1-i,:) = map(i,:);
  end

  % draw line
%   [MapY, MapX] = find(~map1);
%   set(ud.XYLine(2),'Erasemode','normal');
%   set(ud.XYLine(2),'XData',MapX,'YData',MapY);
%   set(ud.XYLine(2),'Marker','s');
%   set(ud.XYLine(2),'MarkerSize',1.5);
%   set(ud.XYLine(2),'MarkerEdgeColor','k'); % Marker color is black
%   set(ud.XYLine(2),'MarkerFaceColor','k'); % Marker color is black
%   set(ud.XYLine(2),'Color','w');
%   set(ud.XYLine(2),'LineWidth', 0.001);

  % draw wall
  [MapY1, MapX1] = find(~(uint8(map1)-128)); 
%   [MapY1, MapX1] = find(~(map1-128)); 
  set(ud.XYLine(3),'Erasemode','normal');
  set(ud.XYLine(3),'XData',MapX1,'YData',MapY1);
  set(ud.XYLine(3),'Marker','s');
  set(ud.XYLine(3),'MarkerSize',1.5);
  set(ud.XYLine(3),'MarkerEdgeColor',[0.5 0.5 0.5]); % Marker color is gray
  set(ud.XYLine(3),'MarkerFaceColor',[0.5 0.5 0.5]); % Marker color is gray
  set(ud.XYLine(3),'Color','w');
  set(ud.XYLine(3),'LineWidth', 0.001);

  set(FigHandle,'UserData',ud);
  
end
% end DrawTrackMap

%
%=============================================================================
% LocalBlockStopFcn
% At the end of the simulation, set the line's X and Y data to contain
% the complete set of points that were acquire during the simulation.
% Recall that during the simulation, the lines are only small segments from
% the last time step to the current one.
%=============================================================================
%
function LocalBlockStopFcn(block)

FigHandle=GetSfunXYFigure(block);
if ishandle(FigHandle),
  %
  % Get UserData of the figure.
  %
  ud = get(FigHandle,'UserData');
  set(ud.XYLine(1),...
      'Xdata',ud.XData,...
      'Ydata',ud.YData,...
      'LineStyle','-',...
      'LineWidth', 2);

end

% end LocalBlockStopFcn

%
%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the Graph scope block.
%=============================================================================
%
function LocalBlockNameChangeFcn(block)

%
% get the figure associated with this block, if it's valid, change
% the name of the figure
%
FigHandle = GetSfunXYFigure(block);
if ishandle(FigHandle),
  set(FigHandle,'Name',BlockFigureTitle(block));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% This is the XYGraph block's LoadFcn and CopyFcn.  Initialize the block's
% UserData such that a figure is not associated with the block.
%=============================================================================
%
function LocalBlockLoadCopyFcn(block)

SetSfunXYFigure(block,-1);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% This is the XY Graph block'DeleteFcn.  Delete the block's figure window,
% if present, upon deletion of the block.
%=============================================================================
%
function LocalBlockDeleteFcn(block)

%
% Get the figure handle associated with the block, if it exists, delete
% the figure.
%
FigHandle=GetSfunXYFigure(block);
if ishandle(FigHandle),
  delete(FigHandle);
  SetSfunXYFigure(block,-1);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% LocalFigureDeleteFcn
% This is the XY Graph figure window's DeleteFcn.  The figure window is
% being deleted, update the XY Graph block's UserData to reflect the change.
%=============================================================================
%
function LocalFigureDeleteFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunXYFigure(ud.Block,-1)

% end LocalFigureDeleteFcn

%
%=============================================================================
% GetSfunXYFigure
% Retrieves the figure window associated with this S-function XY Graph block
% from the block's parent subsystem's UserData.
%=============================================================================
%
function FigHandle=GetSfunXYFigure(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
  FigHandle=-1;
end

% end GetSfunXYFigure

%
%=============================================================================
% SetSfunXYFigure
% Stores the figure window associated with this S-function XY Graph block
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetSfunXYFigure(block,FigHandle)

if strcmp(get_param(bdroot,'BlockDiagramType'),'model'),
  if strcmp(get_param(block,'BlockType'),'S-Function'),
    block=get_param(block,'Parent');
  end

  set_param(block,'UserData',FigHandle);
end

% end SetSfunXYFigure

%
%=============================================================================
% CreateSfunXYFigure
% Creates the figure window associated with this S-function XY Graph block.
%=============================================================================
%
function FigHandle=CreateSfunXYFigure(block)

%
% the figure doesn't exist, create one
%
screenLoc = get(0,'ScreenSize');

if screenLoc(1) < 0
    left  = -screenLoc(1) + 10;
else
    left  = 10;
end

if screenLoc(2) < 0
    bottom = -screenLoc(2) + 40;
else
    bottom = 40;
end

FigHandle = figure('Units',          'pixel',...
                   'Position',       [left bottom  400 350],...
                   'Name',           BlockFigureTitle(block),...
                   'Tag',            'SIMULINK_XYGRAPH_FIGURE',...
                   'NumberTitle',    'off',...
                   'IntegerHandle',  'off',...
                   'Toolbar',        'none',...
                   'Menubar',        'none',...
                   'DeleteFcn',      'sfunxymap2([],[],[],''DeleteFigure'')');
%
% store the block's handle in the figure's UserData
%
ud.Block=block;

%
% create various objects in the figure
%
ud.XYAxes   = axes;
ud.XYLine   = plot(0,0,0,0,0,0,'EraseMode','None');
ud.XYXlabel = xlabel('X Axis');
ud.XYYlabel = ylabel('Y Axis');
ud.XYTitle  = get(ud.XYAxes,'Title');
ud.XData    = [];
ud.YData    = [];

%
% Associate the figure with the block, and set the figure's UserData.
%
SetSfunXYFigure(block, FigHandle);
set(FigHandle,'HandleVisibility','callback','UserData',ud);

% end CreateSfunXYFigure

%
%=============================================================================
% BlockFigureTitle
% String to display for figure window title
%=============================================================================
%
function title = BlockFigureTitle(block)
  iotype = get_param(block,'iotype');
  if strcmp(iotype,'viewer')
    title = viewertitle(block,false);
  else
    title = get_param(block,'Name');
  end
%end BlockFigureTitle

%
%=============================================================================
% IsValidBlock
% Check if this is a valid block
%=============================================================================
%
function IsValidBlock(block, flag)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  thisBlock = get_param(block,'Parent');
else
  thisBlock = block;
end

if(~strcmp(flag,'DeleteFigure'))
  if(~strcmp(get_param(thisBlock,'MaskType'), 'XYMAP scope.'))
    error('Invalid block')
  end
end
%end IsValidBlock

%
%=============================================================================
% SetBlockCallbacks
% This sets the callbacks of the block if it is not a reference.
%=============================================================================
%
function SetBlockCallbacks(block)

%
% the actual source of the block is the parent subsystem
%
block=get_param(block,'Parent');

%
% if the block isn't linked, issue a warning, and then set the callbacks
% for the block so that it has the proper operation
%
if strcmp(get_param(block,'LinkStatus'),'none'),
  warnmsg=sprintf(['The XY Graph scope ''%s'' should be replaced with a ' ...
                   'new version from the Simulink block library'],...
                   block);
  warning(warnmsg);

  callbacks={
    'CopyFcn',       'sfunxymap2([],[],[],''CopyBlock'')' ;
    'DeleteFcn',     'sfunxymap2([],[],[],''DeleteBlock'')' ;
    'LoadFcn',       'sfunxymap2([],[],[],''LoadBlock'')' ;
    'StartFcn',      'sfunxymap2([],[],[],''Start'')' ;
    'StopFcn'        'sfunxymap2([],[],[],''Stop'')' 
    'NameChangeFcn', 'sfunxymap2([],[],[],''NameChange'')' ;
  };

  for i=1:length(callbacks),
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2}),
      set_param(block,callbacks{i,1},callbacks{i,2})
    end
  end
end

% end SetBlockCallbacks
