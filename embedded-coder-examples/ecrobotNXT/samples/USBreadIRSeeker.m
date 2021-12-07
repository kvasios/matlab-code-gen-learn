%   Copyright 2010 The MathWorks, Inc.

function USBreadIRSeeker()

NUM_OF_CYCLE = 100;
PERIOD = 0.1;

disp('Note: The new nxtusb API requires LEGO MINDSTORMS NXT Driver(Fantom) to make it work.');
Data1 = zeros(1, NUM_OF_CYCLE);
Data2 = zeros(1, NUM_OF_CYCLE);
Data3 = zeros(1, NUM_OF_CYCLE);
Data4 = zeros(1, NUM_OF_CYCLE);
Data5 = zeros(1, NUM_OF_CYCLE);
Data6 = zeros(1, NUM_OF_CYCLE);
disp('Start the program in the NXT, wait for 10 seconds...');
nu = nxtusb;
if nu.CurrentState == 3 % NXT_CONNECT
    % NXT-USB interface has already been opened
    disp(['Connection Information: Id: ', num2str(nu.Id)]);
    disp(['Connection Information: Name: ', nu.Name]);
    for i = 1:NUM_OF_CYCLE
        [len, packet] = read(nu, 'uint8', 64);
        if len == 64
            Data1(i) = packet(1);
            Data2(i) = packet(2);
            Data3(i) = packet(3);
            Data4(i) = packet(4);
            Data5(i) = packet(5);
            Data6(i) = packet(6);
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

assignin('base', 'Data1', Data1);
assignin('base', 'Data2', Data2);
assignin('base', 'Data3', Data3);
assignin('base', 'Data4', Data4);
assignin('base', 'Data5', Data5);
assignin('base', 'Data6', Data6);

plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, Data1(1:NUM_OF_CYCLE));
title('Data1(Direction)'); 
figure;
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, Data2(1:NUM_OF_CYCLE));
title('Data2(Intensity1)'); 
figure;
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, Data3(1:NUM_OF_CYCLE));
title('Data3(Intensity2)'); 
figure;
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, Data4(1:NUM_OF_CYCLE));
title('Data4(Intensity3)'); 
figure;
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, Data5(1:NUM_OF_CYCLE));
title('Data5(Intensity4)'); 
figure;
plot(PERIOD:PERIOD:NUM_OF_CYCLE*PERIOD, Data6(1:NUM_OF_CYCLE));
title('Data6(Intensity5)'); 
% -------------------------------------------------------------------------
