%% Compute Slipstream blockage
function [eps_ss] = BAL_SlipstreamBlockage(C_T)
%% Constants
Dp = 0.2032 ;% [m]; Propeller Diameter
C = (1.80 * 1.25) - (4*0.5*0.3^2);% [m2]

Sp = (pi/4) * (Dp^2); %

%% Slipstream Blockage
eps_ss = - (C_T/(2*sqrt(1 + 2*C_T))) * (Sp / C);
end