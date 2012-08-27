%% Script Compare MORSE and Simulation Live Plot
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% This script communicate with MORSE in order to recive live sensor and
% reference data during MORSE simulation. Parallel is executed simulation
% on a model with reference from MORSE. Plots are generated during
% simulation.

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

%simSampleTime = 1/20;

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

%% Prepare plots
xlimValues = [0 simTime];
ylimValues = [-0.05 0.05
              -0.2  0.2
              -Inf  Inf
              -0.7  0.7
              -3.15 3.15
              -0.7  0.7];
stateFigureHandles = zeros(statesNum/2, 1);
statePlotHandles = zeros(3, 2, statesNum/2);

listOfTitles = {'Inclination angle and speed';
                'Position and speed';
                'Steering angle and speed'};
            
listOfyLables = {'x_{1}=phi [rad]';
                 'x_{2}=phi\_dot [rad/s]';
                 'x_{3}=x [m]';
                 'x_{4}=x\_dot [m/s]';
                 'x_{5}=psi [rad]';
                 'x_{6}=psi\_dot [rad/s]';};
             
listOfLegends = {'Setpoint', 'Simulation', 'MORSE', 'Location', 'NorthEast';
                 'Setpoint', 'Simulation', 'MORSE', 'Location', 'NorthEast';
                 'Setpoint', 'Simulation', 'MORSE', 'Location', 'NorthEast';
                 'Setpoint', 'Simulation', 'MORSE', 'Location', 'NorthEast';
                 'Setpoint', 'Simulation', 'MORSE', 'Location', 'NorthEast';
                 'Setpoint', 'Simulation', 'MORSE', 'Location', 'NorthEast'};
           
% plot figure for states             
for i = 1:2:statesNum
    
    data = zeros(1, 2*(size(listOfLegends, 2)-2), 2);
    data(:, :, 1) = [ref.time(1), ref.values(1, i), states_sim.time(1), states_sim.values(1,i), states_morse.time(1), states_morse.values(1,i)];
    data(:, :, 2) = [ref.time(1), ref.values(1, i+1), states_sim.time(1), states_sim.values(1,i+1), states_morse.time(1), states_morse.values(1,i+1)];
    
    [stateFigureHandles(ceil(i/2)), statePlotHandles(:, :, ceil(i/2))] = plotSubplot(data, listOfTitles{ceil(i/2)}, listOfLegends(i:i+1, :), 't [s]', listOfyLables(i:i+1), xlimValues, ylimValues(i:i+1, :));
    
    optimizeFigure(stateFigureHandles(ceil(i/2)));
%     legend off; % left only one legend on plot
end

% plot figure for moments
momentFigureHandle = figure;
hold on;
momentPlotHandles = zeros(1, 4);
momentPlotHandles(1) = plot(u_sim.time(1), u_sim.values(1, 1), 'r');
momentPlotHandles(2) = plot(u_sim.time(1), u_sim.values(1, 2), 'g');
momentPlotHandles(3) = plot(u_morse.time(1), u_morse.values(1, 1), 'b');
momentPlotHandles(4) = plot(u_morse.time(1), u_morse.values(1, 2), 'm');

grid on;
title('Moments on left/right wheel');
legendHandle = legend('Simulation left', 'Simulation right', 'MORSE left', 'MORSE right');
set(legendHandle);
legend off;
ylabel('u=M [Nm]');
xlabel('t [s]');
optimizeFigure(momentFigureHandle, xlimValues, [-0.8 0.8]);

%% Initialize communication with MORSE
initialize_communication;


mainTic = tic;
%% Simulation
for i = 2:iterations
    
    intic = tic;
    time = i*simSampleTime;
    
%%%%%%%%% MORSE %%%%%%%%%%%%%%%%%%%%%%%%%%
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
    
%%%%%%%%% PLOT %%%%%%%%%%%%%%%%%%%%%%
    if mod(i, 100) == 2
        for j = 1:2:statesNum
            set(statePlotHandles(1, 1, ceil(j/2)), 'xdata', ref.time(1:i), 'ydata', ref.values(1:i, j));
            set(statePlotHandles(2, 1, ceil(j/2)), 'xdata', states_sim.time(1:i), 'ydata', states_sim.values(1:i, j));
            set(statePlotHandles(3, 1, ceil(j/2)), 'xdata', states_morse.time(1:i), 'ydata', states_morse.values(1:i, j));

            set(statePlotHandles(1, 2, ceil(j/2)), 'xdata', ref.time(1:i), 'ydata', ref.values(1:i, j+1));
            set(statePlotHandles(2, 2, ceil(j/2)), 'xdata', states_sim.time(1:i), 'ydata', states_sim.values(1:i, j+1));
            set(statePlotHandles(3, 2, ceil(j/2)), 'xdata', states_morse.time(1:i), 'ydata', states_morse.values(1:i, j+1));
            drawnow;
        end
        
        set(momentPlotHandles(1), 'xdata', u_sim.time(1:i), 'ydata', u_sim.values(1:i, 1));
        set(momentPlotHandles(2), 'xdata', u_sim.time(1:i), 'ydata', u_sim.values(1:i, 2));
        set(momentPlotHandles(3), 'xdata', u_morse.time(1:i), 'ydata', u_morse.values(1:i, 1));
        set(momentPlotHandles(4), 'xdata', u_morse.time(1:i), 'ydata', u_morse.values(1:i, 2));
    end    
    
    iterTime = toc(intic);
    timeSum = timeSum + iterTime;    
    fprintf('Iteration Nr. %d Iteration last: %.6f \n', i, iterTime);
end

toc(mainTic)
fprintf('Average iteration time: %.6f \n', timeSum/iterations)

% exit simulation and delete connections
fprintf(supervisionComm, 'end simulation quit');
fscanf(supervisionComm);
deleteConnection([supervisionComm, imuComm, gyrComm, propComm]);