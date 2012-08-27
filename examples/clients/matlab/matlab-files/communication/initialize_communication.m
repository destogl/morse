%% Script Initialize communication
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% This script initialize communicaition with MORSE in few steps:
%       1. Wait for start of MORSE (BGE)
%       2. Suspend dynamic and deactivate components
%       3. Readout stream ports for sensors and actuators
%       4. Resume dynamic and activate components

% Wait for MORSE
while true
    try
        supervisionComm = createConnection(server, 4000);        
        break;
    catch lasterr
        if mod(j, 500) == 0
            disp('Waiting for MORSE...');
        end
        j = j+1;
        if j == 2500
            return;
        end
    end
end

% Suspend MORSE to post messages because of filling the buffer
fprintf(supervisionComm, 'sus1 simulation suspend_dynamics');
disp(fscanf(supervisionComm));
fprintf(supervisionComm, 'sus2 simulation deactivate_all');
disp(fscanf(supervisionComm));

% Create other communication object based
fprintf(supervisionComm, 'dat1 simulation get_all_stream_ports');
readsomething = fscanf(supervisionComm);
streams = separateData(readsomething(14:length(readsomething)));
imuComm = createConnection(server, extractData(streams, 'IMU'));
gyrComm = createConnection(server, extractData(streams, 'Gyroscope'));
propComm = createConnection(server, extractData(streams, 'Property'));

% Resume MORSE to post messages
fprintf(supervisionComm, 'res1 simulation activate_all');
disp(fscanf(supervisionComm));
fprintf(supervisionComm, 'res2 simulation restore_dynamics');
disp(fscanf(supervisionComm));

disp('Simulation execution...');