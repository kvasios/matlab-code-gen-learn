% iGetBluetoothDeviceMode
%   gets Bluetooth device mode (Master/Slave)

%   Copyright 2010 The MathWorks, Inc.

function ret = iGetBluetoothDeviceMode(model)

blk = iGetExportedFcnCallsScheduler(model);
ret = get_param(blk, 'bd_mode');
% End of function
