%% Compute Lift Interferrence
function [d_C_D_W] = BAL_Lift_Correct(C_L_W)
%% Constants
S = 0.21272 ;% [m2]; Wing Area
C = (1.80 * 1.25) - (4*0.5*0.3^2);% [m2]
%% Input Data
A = 8.91; % Aspect ratio
taper_ratio = 0.4; % Taper ratio
span_ratio = 0.75; % b_e/b from graph [Barlow, Rae, and Pope, 1999]
b = 1.397; % Span [m]
b_e = b * span_ratio; % Effective span [m]
H = 1.25; % Height of tunnel cross-section
B = 1.8; % Width of tunnel dross-section
lambda = H/B; % Tunnel dimension ratio
k = b_e/B; % Effective span/Jet width

% Assuming elliptical cross-section (close to octagonal) using lambda and k
% we get delta from the graph [Barlow, Rae, and Pope, 1999]

delta = 0.104; % Boundary Correction Factor
d_C_D_W = delta* (S/C) * C_L_W;
end