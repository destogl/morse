%% Script Compare MORSE and Simulation
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% This script communicate with MORSE in order to recive live sensor and
% reference data during MORSE simulation. Parallel is executed simulation
% on a model with reference from MORSE.

set(0,'DefaultFigureWindowStyle','docked');
addpath(fullfile(pwd, 'communication'));
addpath(fullfile(pwd, 'general'));

close all;
clear;
clc;

%% Prepare variables for simulation
load('system_data');
statesNum = size(SYSd.a, 1);
inputsNum = size(SYSd.b, 2);

[num, den] = tfdata(tfControllerD);
simTime = 60; % Simulation time in seconds
server = 'localhost';

iterations = simTime/simSampleTime+1;

states_sim.time = zeros(iterations, 1);
states_sim.values = zeros(iterations, statesNum);
u_sim.time = zeros(iterations, 1);
u_sim.values = zeros(iterations, inputsNum);

states_morse.time = zeros(iterations, 1);
states_morse.values = zeros(iterations, statesNum);
u_morse.time = zeros(iterations, 1);
u_morse.values = zeros(iterations, inputsNum);

ref.time = zeros(iterations, 1);
ref.values = zeros(iterations, statesNum); 

e_prev_sim = zeros(6, 1);
e_prev_prev_sim = zeros(6, 1);
u_prev_sim = zeros(6, 1);
u_prev_prev_sim = zeros(6, 1);
pid_output_sim = zeros(6, 1);

j = 0;
timeSum = 0;

%% Initialize communication with MORSE
initialize_communication;

mainTic = tic;
%% Simulation
for i = 2:iterations
    
    intic = tic;
    time = i*simSampleTime;
    
%%%%%%%%%%%%%%%%% MORSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % read sensors
    propData = fscanf(propComm);
    gyrData = fscanf(gyrComm);
    imuData = fscanf(imuComm);
    ref.time(i) = time;
    states_morse.time(i) = time;
    u_morse.time(i) = time;
    [ref.values(i, :), states_morse.values(i, :), u_morse.values(i, :)] = getDataFromMorseSensors(propData, gyrData, imuData);
 
%%%%%%%%% SIMULATION %%%%%%%%%%%%%%%%%%%%%%        
    % checking if sign of steering is a different (needed because in
    % blender is limited on [-pi, pi) values)
    if (states_sim.values(i-1, 5)*ref.values(i, 5) < -pi)
        states_sim.values(i-1, 5) = states_sim.values(i-1, 5) - sign(states_sim.values(i-1, 5))*2*pi;
    end

    % calculate PID output - difference equation
    [pid_output_sim, u_prev_prev_sim, e_prev_sim, e_prev_prev_sim] = pidDifferenceEquationController(num{1}, den{1}, (ref.values(i, :) - states_sim.values(i-1, :))', e_prev_sim, e_prev_prev_sim, pid_output_sim, u_prev_prev_sim);
    pid_output_sim(5:6) = ref.values(i, 5:6)';
    % calculate of LQG output
    u_sim.time(i) = time;
    u_sim.values(i, :) = (KRd*(pid_output_sim - states_sim.values(i-1, :)'))';
    % calculate System
    states_sim.time(i) = time;
    states_sim.values(i, :) = stateSpaceStep(SYSd, states_sim.values(i-1, :)', u_sim.values(i, :)');

    iterTime = toc(intic);
    timeSum = timeSum + iterTime;    
    %fprintf('Iteration Nr. %d Iteration last: %.6f \n', i, iterTime);
end

toc(mainTic)
fprintf('Average iteration time: %.6f \n', timeSum/iterations)

% exit simulation and delete connections
fprintf(supervisionComm, 'end simulation quit');
fscanf(supervisionComm);
deleteConnection([supervisionComm, imuComm, gyrComm, propComm]);

%% Plot
xlimValues = [0 simTime];

listOfTitles = {'Inclination angle and speed';
                'Position and speed';
                'Steering angle and speed'};
            
listOfyLables = {'x_{1}=phi (rad)';
                 'x_{2}=phi\_dot (rad/s)';
                 'x_{3}=x (m)';
                 'x_{4}=x\_dot (m/s)';
                 'x_{5}=psi (rad)';
                 'x_{6}=psi\_dot (rad/s)';};
             
listOfLegends = {'Setpoint x_{1}', 'x_{1} Simulation', 'x_{1} MORSE';
                 'Setpoint x_{2}', 'x_{2} Simulation', 'x_{2} MORSE';
                 'Setpoint x_{3}', 'x_{3} Simulation', 'x_{3} MORSE';
                 'Setpoint x_{4}', 'x_{4} Simulation', 'x_{4} MORSE';
                 'Setpoint x_{5}', 'x_{5} Simulation', 'x_{5} MORSE';
                 'Setpoint x_{6}', 'x_{6} Simulation', 'x_{6} MORSE'};

% plot system states                          
for i = 1:2:size(SYSd.a, 2)
    
    data = zeros(iterations, 2*size(listOfLegends, 2), 2);
    data(:, :, 1) = [ref.time, ref.values(:, i), states_sim.time, states_sim.values(:,i), states_morse.time, states_morse.values(:,i)];
    data(:, :, 2) = [ref.time, ref.values(:, i+1), states_sim.time, states_sim.values(:,i+1), states_morse.time, states_morse.values(:,i+1)];
    
    plotSubplot(data, listOfTitles{ceil(i/2)}, listOfLegends(i:i+1, :), 't [s]', listOfyLables(i:i+1), xlimValues);

end

% plot moments
figure;
plot(u_sim.time, u_sim.values(:, 1), 'r', u_sim.time, u_sim.values(:, 2), 'g', u_morse.time, u_morse.values(:, 1), 'b', u_morse.time, u_morse.values(:, 2), 'm');
grid on;
title('Moments on wheels');
legend('Simulation left', 'Simulation right', 'MORSE left', 'MORSE right');
ylabel('u=M [Nm]');
xlabel('t [s]');
xlim(xlimValues);