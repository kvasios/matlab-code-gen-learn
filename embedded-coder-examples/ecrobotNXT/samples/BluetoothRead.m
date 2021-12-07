%   Copyright 2010 The MathWorks, Inc.

function BluetoothRead(port)
% Byte structure of Bluetooth data packet for ECRobot NXT
% Byte 1, number of bytes in the message, message starts on 3rd byte
% Byte 2, 0x00 format byte, never changes
% Byte 3-34, actual data from/to NXT. Size of data packet is 32 bytes
NUM_OF_CYCLE = 100;
PERIOD = 0.1;
PACKET_SIZE = 34;  % should not be changed

try
    s = w32serial(port, 'BaudRate', 128000);
    fopen(s);
catch
    fclose(s);
    disp(['Failed to connect with: ' port]);
end

LightSensorDAQ = zeros(1, NUM_OF_CYCLE);
UltrasonicSensorDAQ = zeros(1, NUM_OF_CYCLE);
disp('Ready for DAQ via Bluetooth. Run your NXT!');
for i = 1:NUM_OF_CYCLE
    packet = fread(s, PACKET_SIZE, 'uint8');

    if length(packet) == PACKET_SIZE
        LightSensorDAQ(i) = packet(4)*256+packet(3);
        UltrasonicSensorDAQ(i) = packet(5);
    end
end

fclose(s);
disp('DAQ is finished.');
 
assignin('base', 'LightSensorDAQ', LightSensorDAQ);
assignin('base', 'UltrasonicSensorDAQ', UltrasonicSensorDAQ);
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, LightSensorDAQ(1:NUM_OF_CYCLE));
title('Light Sensor A/D value'); 
figure;
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, UltrasonicSensorDAQ(1:NUM_OF_CYCLE));
title('Ultrasonic Sensor measurement data [cm]'); 
