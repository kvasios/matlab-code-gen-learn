%   Copyright 2010 The MathWorks, Inc.

function USBwrite()

disp('Note: nxtusb API requires LEGO MINDSTORMS NXT Driver(Fantom) to make it work.');
disp('Start the prgoram in the NXT.');
nu = nxtusb;
if nu.CurrentState == 3 % NXT_CONNECT
    % NXT-USB interface has already been opened
    disp(['Connection Information: Id: ', num2str(nu.Id)]);
    disp(['Connection Information: Name: ', nu.Name]);
    while 1
        pwm = input('Set motor PWM value [0-100]: ');
        if isempty(pwm),  break;
        elseif pwm < 0,   pwm = 0;
        elseif pwm > 100, pwm = 100;
        end
        
        packet = zeros(1, 64);
        packet(1) = pwm;
        len = write(nu, uint8(packet), 'uint8', 64);
        if len ~= 64
            delete(nu);
            error('Cannot write data to NXT.')
        end
    end
else
    disp(['CurrentState: ', num2str(nu.CurrentState)]);
    error('Cannot connect to NXT. Check the NXT-USB connection.')
end
close(nu);
delete(nu);
disp('Finished. It needs to press ENTER button on the NXT to retry this program.')
% -------------------------------------------------------------------------
