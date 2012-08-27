%% Function State Space Step
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Definition: [Y, X] = stateSpaceStep(SYS, X0, U)
%
% Calculating next system states in respect to current state and input.
%
% Input:
%       SYS - State-space system
%       X0 - Current state
%       U - System input
%
% Output:
%       Y - System output
%       X - Next state

function [Y, X] = stateSpaceStep(SYS, X0, U)

X = SYS.a*X0 + SYS.b*U;
Y = SYS.c*X  + SYS.d*U;