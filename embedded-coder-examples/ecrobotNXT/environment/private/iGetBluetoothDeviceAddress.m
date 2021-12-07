% iGetBluetoothDeviceAddress
%   gets Bluetooth device address for slave device
%   to be paired with the Master device

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetBluetoothDeviceAddress(model)

blk = iGetExportedFcnCallsScheduler(model);
ch = get_param(blk, 'bd_addr');
ret = eval([ '{',ch{1} , '}']);
% End of function
