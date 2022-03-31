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

%% Import C_L_w for alpha=0 and =5 and linearly interpolate for alpha=4
C_L_Wa0 = [0.323, 0.3008, 0.2982, 0.2963, 0.3192];
C_L_Wa5 = [0.7632, 0.7448, 0.7413, 0.7410, 0.7622];

% Interpolated C_L value for a=4 and b=-10,-5,0,5,10
C_L_Wa4 = C_L_Wa0 + 4/5*(C_L_Wa5 - C_L_Wa0);


d_C_D_W = delta* (S/C) * C_L_W;
end