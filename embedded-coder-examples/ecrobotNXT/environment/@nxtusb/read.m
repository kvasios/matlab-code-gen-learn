function [len, data] = read(obj, varargin)
%READ Read binary data from the USB device.
%
%   The NXTUSB object OBJ must be connected to the USB device with the OPEN
%   function before any data can be written to the USB device otherwise
%   an error will be returned.
% 
%   [LEN, BUF] = READ(OBJ) reads one element of the data to BUF
%   from the USB device indicated by OBJ. The data BUF will be translated
%   to the precision 'uchar'. LEN returns the number of bytes that have read.
%
%   [LEN, BUF] = READ(OBJ, COUNT) reads COUNT elements of the data to BUF
%   from the USB device indicated by OBJ. The data BUF will be translated
%   to the precision 'uchar'. LEN returns the number of bytes that have read.
%
%   [LEN, BUF] = READ(OBJ, PRECISION, COUNT) reads COUNT elements of the data to BUF
%   from the USB device indicated by OBJ. The data BUF will be translated
%   to the precision 'uchar'. LEN returns the number of bytes that have read.
%
%
%   The precision argument controls the number of bits read for each value
%   and the interpretation of those bits as character, integer or
%   floating point values. The supported PRECISION strings are defined below.
%   By default the 'uchar' PRECISION is used.
%   Numeric values are returned in double precision arrays.
%   
%      MATLAB           Description
%      'uchar'          unsigned character,  8 bits.
%      'schar'          signed character,    8 bits.
%      'int8'           integer,             8 bits.
%      'int16'          integer,             16 bits.
%      'int32'          integer,             32 bits.
%      'uint8'          unsigned integer,    8 bits.
%      'uint16'         unsigned integer,    16 bits.
%      'uint32'         unsigned integer,    32 bits.
%      'single'         floating point,      32 bits.
%      'float32'        floating point,      32 bits.
%      'double'         floating point,      64 bits.
%      'float64'        floating point,      64 bits.
%      'char'           character,           8 bits (signed or unsigned).
%      'short'          integer,             16 bits.
%      'int'            integer,             32 bits.
%      'long'           integer,             32 or 64 bits.
%      'ushort'         unsigned integer,    16 bits.
%      'uint'           unsigned integer,    32 bits.
%      'ulong'          unsigned integer,    32 bits or 64 bits.
%      'float'          floating point,      32 bits.
%
%   Example:
%       ret = nxtusb;
%       open(ret);
%       [len, buf] = read(ret, 'float', 5);
%       close(ret);
%       delete(ret);
%
%   See also NXTUSB/OPEN, NXTUSB/CLOSE, NXTUSB/WRITE, NXTUSB/DELETE

% Error checking.
if ~isa(obj, 'nxtusb')
    error('First input must be a NXTUSB object.')
end

if length(obj) > 1
    error('First input must be a 1-by-1 interface object.')
end

if isempty(inputname(1))
    % do not allow the syntax like close(nxtusb)
    error('No "NXTUSB" object found in this work space')
end

% do not work if the device is not opened
%% switch obj.CurrentState
%%     case {5, 10, 11, 12, 13}
%%     otherwise
%%         error('USB device is not opened')
%% end

% Parse the input.
switch nargin
case 1
   precision = 'uchar';
   count = 1;
case 2
   precision = 'uchar';
   count = deal(varargin{1});
case 3
   [precision, count] = deal(varargin{1:2});
otherwise
   error('Too many input arguments to NXTUSB/READ.')
end   

if ~ischar(precision)
	error('The input argument PRECISION must be a string.')
end

if ~isa(count, 'double')
	error('The input argument COUNT must be scalar double.')
end

% Convert the precision to the mxClassID.
switch (precision)
case {'uchar', 'char'}
    precision = 9;                  % mxUINT8_CLASS
case {'schar'}
    precision = 8;                  % mxINT8_CLASS
case {'int8'}
    precision = 8;                  % mxINT8_CLASS
case {'int16', 'short'}
    precision = 10;                 % mxINT16_CLASS
case {'int32', 'int', 'long'}
    precision = 12;                 % mxINT32_CLASS
case {'uint8'}
    precision = 9;                  % mxUINT8_CLASS
case {'uint16', 'ushort'}
    precision = 11;                 % mxUINT16_CLASS
case {'uint32', 'uint', 'ulong'}
    precision = 13;                 % mxUINT32_CLASS
case {'single', 'float32', 'float'}
    precision = 7;                  % mxSINGLE_CLASS
case {'double' ,'float64'}
    precision = 6;                  % mxDOUBLE_CLASS
otherwise
    error('Invalid PRECISION specified.')
end

try
    % call the private MEX function
    [len, data] = mexusb('usbread', obj.Id, precision, count);
catch ME
    rethrow(ME);
end

% update the properties
%% obj.CurrentState = nxterr;
% transfer the updated object to the caller workspace
% assignin('caller', inputname(1), obj);
