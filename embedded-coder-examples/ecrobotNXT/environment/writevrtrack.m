% writevrtrack
%   generates a VRML track file from a bit map file

%   Copyright 2010 The MathWorks, Inc.

function writevrtrack(varargin)

switch nargin
    case 1
        bmpfile = varargin{1};
        wall_height = '10.0';
    case 2
        bmpfile = varargin{1};
        wall_height = num2str(varargin{2});
    otherwise
        error('Requires 1 or 2 arguments.')
end

% read bit map file
try
  rawdata = imread(bmpfile);
catch
  error(['Failed to read: '  bmpfile]);
end

% read track_template.wrl
try
fid = fopen('track_template.wrl', 'r');
ctext=[];
while 1
    str = fgetl(fid);
    if ~ischar(str)
        fclose(fid);
        break;
    else
        ctext = [ctext str sprintf('\r\n')];
    end
end
catch
  error(['Failed to read track_template.wrl']);
end

LINEFEED = sprintf('\r\n');
row_h = [  1 101   1 101];
row_e = [100 200 100 200];
col_h = [  1   1 101 101];
col_e = [100 100 200 200];
% generate VRML elevation grid data for NW/NE/SE/SW
for j=1:4
    dat = rawdata(row_h(j):row_e(j), col_h(j):col_e(j));
    pixels = reshape(dat', 1, size(dat,1)*size(dat,2));

    WALL  = '0.3 0.3 0.3,'; % gray
    LINE  = '0.0 0.0 0.0,'; % black
    FIELD = '0.7 0.7 0.7,'; % white
    map = 'color ';
    for i=1:length(pixels)
        if i == 1
            if pixels(i) == 0 % black
                map = [map '[' LINE];  
            elseif pixels(i) == 255 % white 
                map = [map '[' FIELD];
            else 
                map = [map '[' WALL]; % other colors
            end
        else
            if pixels(i) == 0
                map = [map LINEFEED LINE];
            elseif pixels(i) == 255
                map = [map LINEFEED FIELD];
            else
                map = [map LINEFEED WALL];
            end
        end
    end
    map = [map ']'];

    height = 'height [';
    for i=1:length(pixels)
        if pixels(i) == 0 || pixels(i) == 255
            height = [height '0'];    % line or field
        else 
            height = [height wall_height]; % wall height
        end

        if i ~= length(pixels)
            height = [height ', '];

            if mod(i,4) == 0
                height = [height LINEFEED];
            end
        end
    end
    height = [height ']'];
    
    if j == 1
        ctext = regexprep(ctext, 'NW_COLOR',  map);
        ctext = regexprep(ctext, 'NW_HEIGHT', height);
    elseif j == 2
        ctext = regexprep(ctext, 'SW_COLOR',  map);
        ctext = regexprep(ctext, 'SW_HEIGHT', height);
    elseif j == 3
        ctext = regexprep(ctext, 'NE_COLOR',  map);
        ctext = regexprep(ctext, 'NE_HEIGHT', height);
    elseif j == 4
        ctext = regexprep(ctext, 'SE_COLOR',  map);
        ctext = regexprep(ctext, 'SE_HEIGHT', height);
    end
end

VRMLfile = regexprep(bmpfile, '.bmp',  '.wrl');
try
    fid = fopen(VRMLfile, 'w');
    fprintf(fid, '%c', ctext);
    fclose(fid);
catch
  error(['Failed to write: ' VRMLfile]);
end
% End of function
