%   Copyright 2010 The MathWorks, Inc.

function USBread()

NUM_OF_CYCLE = 100;
PERIOD = 0.1;

disp('Note: nxtusb API requires LEGO MINDSTORMS NXT Driver(Fantom) to make it work.');
LightSensorDAQ = zeros(1, NUM_OF_CYCLE);
UltrasonicSensorDAQ = zeros(1, NUM_OF_CYCLE);
disp('Start the program in the NXT, wait for 10 seconds...');
nu = nxtusb;
if nu.CurrentState == 3 % NXT_CONNECT
    % NXT-USB interface has already been opened
    disp(['Connection Information: Id: ', num2str(nu.Id)]);
    disp(['Connection Information: Name: ', nu.Name]);
    for i = 1:NUM_OF_CYCLE
        [len, packet] = read(nu, 'uint8', 64);
        if len == 64
            LightSensorDAQ(i) = packet(2)*256+packet(1);
            UltrasonicSensorDAQ(i) = packet(3);
        else
            delete(nu);
            error('Cannot read data from NXT.')
        end
    end
else
    disp(['CurrentState: ', num2str(nu.CurrentState)]);
    error('Cannot connect to NXT. Check the NXT-USB connection.')
end
close(nu);
delete(nu);
disp('Finished. It needs to press ENTER button on the NXT to retry this program.')

assignin('base', 'LightSensorDAQ', LightSensorDAQ);
assignin('base', 'UltrasonicSensorDAQ', UltrasonicSensorDAQ);
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, LightSensorDAQ(1:NUM_OF_CYCLE));
title('Light Sensor A/D value'); 
figure;
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, UltrasonicSensorDAQ(1:NUM_OF_CYCLE));
title('Ultrasonic Sensor measurement data [cm]'); 
% -------------------------------------------------------------------------
