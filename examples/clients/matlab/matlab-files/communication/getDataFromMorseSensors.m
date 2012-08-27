%% Function Get Data From Morse Sensors
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Definition: [reference, states, u] = getDataFromMorseSensors(propData, gyrData, imuData)
%
% This function extract System Space-Data and reference from MORSE sensors
% data.
%
% Input:
%       propData - data from Game_property sensor
%       imuData - data from IMU sensor
%       gyroscopeDta - data form Gyroscope sensor
%
% Output:
%    reference - reference for System states (see down)
%    states - System states:
%       phi - roll angle
%       phi_dot - roll angular velocity
%       distance - distance from start point
%       velocity - linear velocity
%       psi - yaw angle
%       psi_dot - yaw angular velocity
%   u - input Moments on Fuchs wheels

function [reference, states, u] = getDataFromMorseSensors(propData, gyrData, imuData)

    % references
    phi_ref = 0;
    phi_dot_ref = 0;

    data = separateData(propData);
    velocity_ref = extractData(data, 'velocity_ref');
    distance_ref = extractData(data, 'distance_ref');
    
    psi_dot_ref = extractData(data, 'steering_velocity_ref');    
    psi_ref = extractData(data, 'steering_ref');    
      
    reference = [phi_ref, phi_dot_ref, distance_ref, velocity_ref, psi_ref, psi_dot_ref];
    
    % input moments
    u_left = -extractData(data, 'torque_left');
    u_right = -extractData(data, 'torque_right');
    
    u = [u_left, u_right];
    
    % states
    distance = extractData(data, 'distance');
    velocity = extractData(data, 'velocity');
       
    data = separateData(imuData);
    velocityAll = extractData(data, 'angular_velocity');
    phi_dot = velocityAll(1);
    psi_dot = velocityAll(3);  
    
    data = separateData(gyrData);
    psi = extractData(data, 'yaw');
    phi = extractData(data, 'roll');
    
    states = [phi, phi_dot, distance, velocity, psi, psi_dot];