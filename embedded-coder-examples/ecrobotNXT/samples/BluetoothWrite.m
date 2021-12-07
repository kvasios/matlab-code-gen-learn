%   Copyright 2010 The MathWorks, Inc.

function BluetoothWrite(port)
% Byte structure of Bluetooth data packet for ECRobot NXT
% Byte 1, number of bytes in the message, message starts on 3rd byte
% Byte 2, 0x00 format byte, never changes
% Byte 3-34, actual data from/to NXT. Size of data packet is 32 bytes

PACKET_SIZE = 34;  % should not be changed

try
    s = w32serial(port, 'BaudRate', 128000);
    fopen(s);
catch
    fclose(s);
    disp(['Failed to connect with: ' port]);
end

while(1)
    pwm = input('Set motor PWM value [0-100]: ');
    if isempty(pwm),  break;
    elseif pwm < 0,   pwm = 0;
    elseif pwm > 100, pwm = 100;
    end

    packet = zeros(1,PACKET_SIZE);
    packet(1) = length(packet)-2;
    packet(3) = pwm;
    fwrite(s, packet, 'uint8', PACKET_SIZE);
end
 
fclose(s);
