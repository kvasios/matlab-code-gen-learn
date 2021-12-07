% writenxtdisplay
%   generates C array definition for LCD graphic display on the NXT from a 
%   bit map file.

%   Copyright 2010 The MathWorks, Inc.

function writenxtdisplay(varargin)

switch nargin
    case 1
        bmpfile = varargin{1};
    otherwise
        error('Requires only 1 argument.')
end

% read a bit map file
try
  rawdata = imread(bmpfile);
catch
  error(['Failed to read: '  bmpfile]);
end

if (size(rawdata) == [64 100]) ~= [1 1]
    error('Size of the BMP file has to be 64x100 pixels.');
end
rawdata = ~rawdata;

% write a <bit map file name>.txt file to be included in 
% nxt_main.c
TXTfile = regexprep(bmpfile, '.bmp',  '.txt');
fid = fopen(TXTfile, 'w');
fprintf(fid, ['const U8 ' ...
              regexprep(bmpfile, '.bmp', '') ...
              '[8*100] = \n']);
fprintf(fid, '{\n');
row_offset = 1;
while(row_offset <= 64)
    for col_idx = 1:100
        vertical8pixels = uint8(0);
        for row_idx = 0:7
            vertical8pixels = ...
                bitor(vertical8pixels, ...
                bitshift(uint8(rawdata(row_idx+row_offset, col_idx)), row_idx));
        end
        
        if vertical8pixels < 16
            fprintf(fid, ['0x0' dec2hex(vertical8pixels)]);
        else
            fprintf(fid, ['0x' dec2hex(vertical8pixels)]);
        end
        
        if((row_idx+row_offset)*col_idx ~= 64*100)
            fprintf(fid, ', ');
        end
    end
    fprintf(fid, '\n');
    row_offset = row_offset+8;
end
fprintf(fid, '};\n');
fclose(fid);

% End of function
