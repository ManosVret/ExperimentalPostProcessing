%% Compute Lift Interferrence
function [d_C_D_W] = BAL_Lift_Correct(C_L_W)
%% Constants
S = 0.21272 ;% [m2]; Wing Area
C = (1.80 * 1.25) - (4*0.5*0.3^2);% [m2]
%% Input Data
delta = 5; % Boundary Correction Factor
d_C_D_W = delta* (S/C) * C_L_W;
end