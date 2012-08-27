%% Function PID Difference Equation Controller
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Definition: [u, u_prev, e, e_prev] = pidDifferenceEquationController(num, den, e, e_prev, e_prev_prev, u_prev, u_prev_prev)
%
% This function calculate output PID-controller in form of difference
% equation.
%
% Input:
%       num - numerator of discrete PID controller (size = 3)
%       den - denominator of discrete PID contorller (size = 3)
%       e - control error
%       e_prev - previous control error
%       e_prev_prev - 2 step in history control error
%       u_prev - previous controller output
%       u_prev_prev - 2 stap in history contoller output
%
% Output:
%       u - controller output
%       u_prev - previous controller output
%       e - control error
%       e_prev - previous control error

function [u, u_prev, e, e_prev] = pidDifferenceEquationController(num, den, e, e_prev, e_prev_prev, u_prev, u_prev_prev)

u = (num(1)*e + num(2)*e_prev + num(3)*e_prev_prev - den(2)*u_prev - den(3)*u_prev_prev)/den(1);