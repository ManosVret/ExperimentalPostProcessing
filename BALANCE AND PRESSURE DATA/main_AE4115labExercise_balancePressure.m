%% Main processing file LTT data AE4115 lab exercise 2021-2022
% T Sinnige
% 25 February 2022

%% Initialization
% clear workspace, figures, command window
clear 
close all
clc

%% Inputs

% define root path on disk where data is stored
diskPath = './DATA';

% get indices balance and pressure data files
% [idxB,idxP] = SUP_getIdx;
% 
% % filename(s) of the raw balance files - DEFINE AS STRUCTURE WITH AS MANY FILENAMES AS DESIRED 
% % The name of the file must start with "raw_". If the filename starts with
% % a character that is not a letter, a plus sign, or a minus sign, the code
% % will throw an error in BALprocess.m and you will have to add some code 
% % there to handle the exception. (the filenames are used as fields in a 
% % structure and these must start with a letter, so you will need to replace
% % the first character with a letter. For the + and - signs this has already
% % been implemented.
% fn_BAL = {'BAL/raw_zero_rudder.txt',...
%           'BAL/raw_pos20_rudder.txt',...
%           'BAL/raw_neg20_rudder.txt'};
% % fn_BAL = {'BAL/raw_edef0.txt',...
% %           'BAL/raw_edef10.txt'};
%     
% % filename(s) of the zero-measurement (tare) data files. Define an entry
% % per raw data files. In case multiple zero-measurements are available for
% % a datapoint, then add a structure with the filenames of the zero 
% % measurements at the index of that datapoint.
% fn0 = {'BAL/zer_20220223-152010.txt',...
%        'BAL/zer_20220223-152010.txt',...
%        'BAL/zer_20220223-152010.txt'};
% % fn0 = {'BAL/zer_20220217-152643.txt',...
% %        'BAL/zer_20220217-152643.txt'};
% 
% % filenames of the pressure data files (same comments apply as for balance 
% % data files)
% fn_PRS = {'PRESSURE/raw_BEO_0rudder.txt',...
%           'PRESSURE/raw_pos20_rudder.txt',...
%           'PRESSURE/raw_neg20_rudder.txt'};
% % fn_PRS = {'PRESSURE/raw_edef0.txt',...
% %           'PRESSURE/raw_edef10.txt'};
% % wing geometry
% b     = 1.4*cosd(4); % span [m]
% cR    = 0.222; % root chord [m]
% cT    = 0.089; % tip chord [m]
% S     = b/2*(cT+cR);   % reference area [m^2]
% taper = cT/cR; % taper ratio
% c     = 2*cR/3*(1+taper+taper^2)/(1+taper); % mean aerodynamic chord [m]
% 
% prop geometry
D        = 0.2032; % propeller diameter [m]
R        = D/2;   % propeller radius [m]
% 
% % moment reference points
% XmRefB    = [0,0,0.0465/c]; % moment reference points (x,y,z coordinates) in balance reference system [1/c] 
% XmRefM    = [0.25,0,0];     % moment reference points (x,y,z coordinates) in model reference system [1/c] 
% 
% % incidence angle settings
% dAoA      = 0.0; % angle of attack offset (subtracted from measured values)   
% dAoS      = 0.0; % angle of sideslip offset (subtracted from measured values)
% modelType = 'aircraft'; % options: aircraft, 3dwing, halfwing
% modelPos  = 'inverted'; % options: normal, inverted
% testSec   = 5;    % test-section number   
% 
% %% Run the processing code to get balance and pressure data
% BAL = BAL_process(diskPath,fn_BAL,fn0,idxB,D,S,b,c,XmRefB,XmRefM,dAoA,dAoS,modelType,modelPos,testSec);
% PRS = PRS_process(diskPath,fn_PRS,idxP);
% 
% 
% %writetable(struct2table(BAL.windOn.zero_rudder,'AsArray',true),  'BAL.xlsx')
% 
% 
% %% Loop through Structure:
% 
% % Layers of BAL structure
% layer1 = fieldnames(BAL);
% 
% A0 = []; % Zero Rudder
% A20 = []; % 20 deg rudder
% Am20 = []; % -20deg rudder
% 
% for i=3:numel(layer1)
%     windOn = fieldnames(BAL.(string(layer1(i))));
%     for j=1:numel(windOn)
%         Rudder = fieldnames(BAL.(string(layer1(i))).(string(windOn(j))));
%         if j==1
%             rud = 0;
%         elseif j==2
%             rud = 20;
%         elseif j==3
%             rud = -20;
%         end
%         for k=5:(numel(Rudder)-3)
%             Data = BAL.(string(layer1(i))).(string(windOn(j))).(string(Rudder(k)));
%             if rud==0
%                 A0 = [A0,Data];
%             elseif rud==20
%                 A20 = [A20, Data];
%             elseif rud==-20
%                 Am20 = [Am20, Data];
%             end
%         end
%     end
% end
% n0 = size(A0,1);
% rud0 = zeros(n0,1);
% A0 = [A0,rud0];
% 
% n20 = size(A20,1);
% rud20 = 20*ones(n20,1);
% A20 = [A20, rud20];
% 
% nm20 = size(Am20,1);
% rudm20 = -20*ones(nm20,1);
% Am20 = [Am20, rudm20];
% 
% BIGGIE = cat(1,A0,A20,Am20);
% save('FULLMAT.mat','BIGGIE');
% 
% %%Writing struct for parsing BIGA
% structsize = 60;
% fields = struct();
% 
% fid = fopen('fields.csv');
% fnames = fscanf(fid,'%s');
% fnames = split(fnames,',');
% 
% BIGGIE = array2table(BIGGIE, 'VariableNames', fnames);
% 
% BIGGIE.iM2(1:9)=0.2;
% BIGGIE.iM1(5)=0.2;
% 
% writetable(BIGGIE,'FULLMAT');


BIGGIE = readtable('FULLMAT.txt');
% load CTs.mat;
% 
% % BIGGIE = addvars(BIGGIE,Thrust,'After','rudder');
% 
% for i = 1:127
%     
%     j = round(BIGGIE.J_M2(i),1); 
%     
%     if round(BIGGIE.V(i)) == 20
%         if j == 1.6
%             CT = CTs(1,2);
%         elseif j == 2.0
%             CT = CTs(1,3);
%         elseif j == 2.4
%             CT = CTs(1,4);
%         end
%         
%     elseif round(BIGGIE.V(i)) == 40
%         if j == 1.6
%             CT = CTs(2,2);
%         elseif j == 2.0
%             CT = CTs(2,3);
%         elseif j == 2.4
%             CT = CTs(2,4);
%         end
%         
%     end
%     
%     BIGGIE.CT_actual(i) = CT;
%         
%     if round(BIGGIE.rpsM1(i),1) == round(BIGGIE.rpsM2(i),1)
%         BIGGIE.Thrust(i) = 2 * CT * BIGGIE.rho(i) * BIGGIE.rpsM2(i)^2 * D^4;  
%         
%     else
%         BIGGIE.Thrust(i) = CT * BIGGIE.rho(i) * BIGGIE.rpsM2(i)^2 * D^4;
%       
%     end
%     
%     BIGGIE.Drag_unc(i) = BIGGIE.FX(i) + BIGGIE.Thrust(i) * cos(BIGGIE.AoA(i)) * cos(BIGGIE.AoS(i));
%     
%     BIGGIE.CD_unc(i) = BIGGIE.Drag_unc(i)/BIGGIE.q(i);
%     
% end
% 
% 
% for i = 1:127
%     BIGGIE_1 = BIGGIE(BIGGIE.rudder == BIGGIE.rudder(i), :);
%     BIGGIE_1 = BIGGIE_1(round(BIGGIE_1.V,1) == round(BIGGIE.V(i),1), :);
%     BIGGIE_1 = BIGGIE_1(round(BIGGIE_1.J_M2,1) == round(BIGGIE.J_M2(i),1), :);
%     
%     if round(BIGGIE.J_M1(i),1) == round(BIGGIE.J_M2(i),1)
%         BIGGIE_1 = BIGGIE_1(round(BIGGIE_1.J_M1,1) == round(BIGGIE_1.J_M2,1),:);
%     elseif round(BIGGIE.J_M1(i),1) ~= round(BIGGIE.J_M2(i),1)
%         BIGGIE_1 = BIGGIE_1(round(BIGGIE_1.J_M1,1) ~= round(BIGGIE_1.J_M2,1),:);
%     end
% 
%     CD_0 = min(BIGGIE_1.CD);
%     
%     BIGGIE.CD_0(i) = CD_0;
%     
% end
% %% Start of corrections
% % model-off -> blockages -> lift interf.
% BIGGIE_init = BIGGIE;
% 
% %% Model-off
% BIGGIE_Corr_MO = BAL_ModelOff_Correction(BIGGIE);
% BIGGIE = BIGGIE_Corr_MO;
% 
% %% Adding all epsilons
% for i = 1:127
%     eps_wake = BAL_WakeBlockage(BIGGIE.CD_0(i));
%     
%     eps_slip = BAL_SlipstreamBlockage(BIGGIE.CT_actual(i));
%     
%     eps_solid = BAL_SolidBlockage();
%     
%     BIGGIE.epsilon(i) = eps_wake + eps_slip + eps_solid;
% end
% 
% %% Creating table for all corrected values 
% BIGGIE_CORRECTED_BLOCK = BIGGIE;
% 
% BIGGIE_CORRECTED_BLOCK.V = BIGGIE.V .* (1+BIGGIE.epsilon);
% BIGGIE_CORRECTED_BLOCK.q = BIGGIE.q .* (1+BIGGIE.epsilon).^2;
% BIGGIE_CORRECTED_BLOCK.CL = BIGGIE.CL .* (BIGGIE.q ./ BIGGIE_CORRECTED_BLOCK.q);
% BIGGIE_CORRECTED_BLOCK.CD = BIGGIE.CD .* (BIGGIE.q ./ BIGGIE_CORRECTED_BLOCK.q);
% BIGGIE_CORRECTED_BLOCK.CYaw = BIGGIE.CYaw .* (BIGGIE.q ./ BIGGIE_CORRECTED_BLOCK.q);
% BIGGIE_CORRECTED_BLOCK.CMyaw = BIGGIE.CMyaw .* (BIGGIE.q ./ BIGGIE_CORRECTED_BLOCK.q);
% 
% BIGGIE_CORRECTED_BLOCK.CY = BIGGIE.CY .* (BIGGIE.q ./ BIGGIE_CORRECTED_BLOCK.q);
% BIGGIE_CORRECTED_BLOCK.CMY = BIGGIE.CMY .* (BIGGIE.q ./ BIGGIE_CORRECTED_BLOCK.q);
% BIGGIE_CORRECTED_BLOCK.CMZ = BIGGIE.CMZ .* (BIGGIE.q ./ BIGGIE_CORRECTED_BLOCK.q);
% 
% BIGGIE_CORRECTED_BLOCK.J_M1 = BIGGIE.J_M1 .* (BIGGIE.V ./ BIGGIE_CORRECTED_BLOCK.V);
% BIGGIE_CORRECTED_BLOCK.J_M2 = BIGGIE.J_M2 .* (BIGGIE.V ./ BIGGIE_CORRECTED_BLOCK.V);
% 
% BIGGIE = BIGGIE_CORRECTED_BLOCK;
% 
% %% Lift correction
% BIGGIE_Corr_lift = BAL_Lift_Correct(BIGGIE);
% BIGGIE_CORRECTED = BIGGIE_Corr_lift;
% 
% writetable(BIGGIE_CORRECTED,'FULLMAT_CORRECTED');

BIGGIE_CORRECTED = readtable('FULLMAT_CORRECTED.txt');


%% Plotting CN vs rudder deflection

BIGGIE_CORRECTED = BIGGIE_CORRECTED(round(BIGGIE_CORRECTED.J_M1,1) ~= round(BIGGIE_CORRECTED.J_M2,1),:); % OEI
BIGGIE_CORRECTED = BIGGIE_CORRECTED(BIGGIE_CORRECTED.V > 23,:);
BIGGIE_CORRECTED = BIGGIE_CORRECTED(BIGGIE_CORRECTED.J_M2 > 2.05 & BIGGIE_CORRECTED.J_M2 < 2.6,:);
% BIGGIE_CORRECTED = BIGGIE_CORRECTED(BIGGIE_CORRECTED.rudder == 0,:);

BIGGIE_CORRECTED = sortrows(BIGGIE_CORRECTED,'rudder'); 

% CN0 = interp1(BIGGIE_CORRECTED.CMZ(round(BIGGIE_CORRECTED.AoS,1) == 0,:),BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == 0,:),0)
% CN5 = interp1(BIGGIE_CORRECTED.CMZ(round(BIGGIE_CORRECTED.AoS,1) == 5,:),BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == 5,:),0)

figure,plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == -10,:),BIGGIE_CORRECTED.CMZ(round(BIGGIE_CORRECTED.AoS,1) == -10,:),'-*')

hold on

plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == -5,:),BIGGIE_CORRECTED.CMZ(round(BIGGIE_CORRECTED.AoS,1) == -5,:),'-o')

plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == 0,:),BIGGIE_CORRECTED.CMZ(round(BIGGIE_CORRECTED.AoS,1) == 0,:),'-v')

plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == 5,:),BIGGIE_CORRECTED.CMZ(round(BIGGIE_CORRECTED.AoS,1) == 5,:),'-s')

plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == 10,:),BIGGIE_CORRECTED.CMZ(round(BIGGIE_CORRECTED.AoS,1) == 10,:),'-+')


hold off

title('CN vs Rudder Deflection - OEI case; V=40m/s; J=2.4')
xlabel('Rudder Deflection δr [deg]') 
ylabel('Yaw Moment Coefficient CN [-]') 
legend('β = -10°','β = -5°','β = 0°','β = 5°','β = 10°')

%% Plotting CY vs rudder deflection 


figure,plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == -10,:),BIGGIE_CORRECTED.CY(round(BIGGIE_CORRECTED.AoS,1) == -10,:),'-*')

hold on

plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == -5,:),BIGGIE_CORRECTED.CY(round(BIGGIE_CORRECTED.AoS,1) == -5,:),'-o')

plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == 0,:),BIGGIE_CORRECTED.CY(round(BIGGIE_CORRECTED.AoS,1) == 0,:),'-v')

plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == 5,:),BIGGIE_CORRECTED.CY(round(BIGGIE_CORRECTED.AoS,1) == 5,:),'-s')

plot(BIGGIE_CORRECTED.rudder(round(BIGGIE_CORRECTED.AoS,1) == 10,:),BIGGIE_CORRECTED.CY(round(BIGGIE_CORRECTED.AoS,1) == 10,:),'-+')

hold off

title('CY vs Rudder Deflection - OEI case; V=40m/s; J=2.4')
xlabel('Rudder Deflection δr [deg]') 
ylabel('Side Force Coefficient CY [-]') 
legend('β = -10°','β = -5°','β = 0°','β = 5°','β = 10°')