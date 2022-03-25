%% Compute Wake Blockage
function [eps_wake] = BAL_WakeBlockage(C_D_data)
%% Constants
S = 0.21272 ;% [m2]; Wing Area
C = (1.80 * 1.25) - (4*0.5*0.3^2);% [m2]
%% Input Data
C_D_unc = C_D_data(1);
C_D_i   = C_D_data(2);
C_D_0   = C_D_data(3);

C_D_S = C_D_unc - C_D_0 - C_D_i;

%% Wake Blockage
eps_wb_0 = (S/(4*C)) * C_D_0;
eps_wb_s = ((5*S)/(4*C))*C_D_S;

eps_wake = eps_wb_0 + eps_wb_s;
end