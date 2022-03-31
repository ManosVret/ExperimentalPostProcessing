function [eps_solid] = BAL_SolidBlockage()

%% "wing"-type volumes [m3]

V_wing = 2 * 0.0003546;
V_strut = 0.0035296;
V_vert = 0.0003546;
V_horiz = 2 * (3.041e-4 + 1.305e-4 + 1.325e-5 + 3.975e-5);

%% "fuselage"-type volumes [m3]

V_fuselage = 2 * 0.008;
V_nacelle = 2 * 7.921e-4;


%% geometric parameters 
C = 1.8 * 1.25 - 2 * 0.3 * 0.3;  % [m2] wind tunnel cross-section 

k1_wing = 1.02;
k1_strut = k1_wing;

k3_fuselage = 0.91;
k3_nacelle = 0.925;

tau_1 = 0.88; % wind tunnel parameter


%% "wing"-type epsilons

epsilon_wing = (k1_wing * tau_1 * V_wing)/(C^(3/2));
epsilon_horiz = (k1_wing * tau_1 * V_horiz)/(C^(3/2));
epsilon_vert = (k1_wing * tau_1 * V_vert)/(C^(3/2));
epsilon_strut = (k1_strut * tau_1 * V_strut)/(C^(3/2));

%% "fuselage"-type epsilons

epsilon_fuselage = (k3_fuselage * tau_1 * V_fuselage)/(C^(3/2));
epsilon_nacelle = (k3_nacelle * tau_1 * V_nacelle)/(C^(3/2));

%% total 

eps_solid = epsilon_wing + epsilon_horiz + epsilon_vert + epsilon_strut + epsilon_fuselage + epsilon_nacelle;
end