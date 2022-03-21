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
[idxB,idxP] = SUP_getIdx;

% filename(s) of the raw balance files - DEFINE AS STRUCTURE WITH AS MANY FILENAMES AS DESIRED 
% The name of the file must start with "raw_". If the filename starts with
% a character that is not a letter, a plus sign, or a minus sign, the code
% will throw an error in BALprocess.m and you will have to add some code 
% there to handle the exception. (the filenames are used as fields in a 
% structure and these must start with a letter, so you will need to replace
% the first character with a letter. For the + and - signs this has already
% been implemented.
fn_BAL = {'BAL/raw_zero_rudder.txt',...
          'BAL/raw_pos20_rudder.txt',...
          'BAL/raw_neg20_rudder.txt'};
% fn_BAL = {'BAL/raw_edef0.txt',...
%           'BAL/raw_edef10.txt'};
    
% filename(s) of the zero-measurement (tare) data files. Define an entry
% per raw data files. In case multiple zero-measurements are available for
% a datapoint, then add a structure with the filenames of the zero 
% measurements at the index of that datapoint.
fn0 = {'BAL/zer_20220223-152010.txt',...
       'BAL/zer_20220223-152010.txt',...
       'BAL/zer_20220223-152010.txt'};
% fn0 = {'BAL/zer_20220217-152643.txt',...
%        'BAL/zer_20220217-152643.txt'};

% filenames of the pressure data files (same comments apply as for balance 
% data files)
fn_PRS = {'PRESSURE/raw_BEO_0rudder.txt',...
          'PRESSURE/raw_pos20_rudder.txt',...
          'PRESSURE/raw_neg20_rudder.txt'};
% fn_PRS = {'PRESSURE/raw_edef0.txt',...
%           'PRESSURE/raw_edef10.txt'};
% wing geometry
b     = 1.4*cosd(4); % span [m]
cR    = 0.222; % root chord [m]
cT    = 0.089; % tip chord [m]
S     = b/2*(cT+cR);   % reference area [m^2]
taper = cT/cR; % taper ratio
c     = 2*cR/3*(1+taper+taper^2)/(1+taper); % mean aerodynamic chord [m]

% prop geometry
D        = 0.2032; % propeller diameter [m]
R        = D/2;   % propeller radius [m]

% moment reference points
XmRefB    = [0,0,0.0465/c]; % moment reference points (x,y,z coordinates) in balance reference system [1/c] 
XmRefM    = [0.25,0,0];     % moment reference points (x,y,z coordinates) in model reference system [1/c] 

% incidence angle settings
dAoA      = 0.0; % angle of attack offset (subtracted from measured values)   
dAoS      = 0.0; % angle of sideslip offset (subtracted from measured values)
modelType = 'aircraft'; % options: aircraft, 3dwing, halfwing
modelPos  = 'inverted'; % options: normal, inverted
testSec   = 5;    % test-section number   

%% Run the processing code to get balance and pressure data
BAL = BAL_process(diskPath,fn_BAL,fn0,idxB,D,S,b,c,XmRefB,XmRefM,dAoA,dAoS,modelType,modelPos,testSec);
PRS = PRS_process(diskPath,fn_PRS,idxP);


%writetable(struct2table(BAL.windOn.zero_rudder,'AsArray',true),  'BAL.xlsx')


%% Loop through Structure:

% Layers of BAL structure
layer1 = fieldnames(BAL);

A0 = []; % Zero Rudder
A20 = []; % 20 deg rudder
Am20 = []; % -20deg rudder

for i=3:numel(layer1)
    windOn = fieldnames(BAL.(string(layer1(i))));
    for j=1:numel(windOn)
        Rudder = fieldnames(BAL.(string(layer1(i))).(string(windOn(j))));
        if j==1
            rud = 0;
        elseif j==2
            rud = 20;
        elseif j==3
            rud = -20;
        end
        for k=5:(numel(Rudder)-3)
            Data = BAL.(string(layer1(i))).(string(windOn(j))).(string(Rudder(k)));
            if rud==0
                A0 = [A0,Data];
            elseif rud==20
                A20 = [A20, Data];
            elseif rud==-20
                Am20 = [Am20, Data];
            end
        end
    end
end
n0 = size(A0,1);
rud0 = zeros(n0,1);
A0 = [A0,rud0];

n20 = size(A20,1);
rud20 = 20*ones(n20,1);
A20 = [A20, rud20];

nm20 = size(Am20,1);
rudm20 = -20*ones(nm20,1);
Am20 = [Am20, rudm20];

BIGGIE = cat(1,A0,A20,Am20);
save('FULLMAT.mat','BIGGIE');

%%Writing struct for parsing BIGA
structsize = 60;
fields = struct();

fid = fopen('fields.csv');
fnames = fscanf(fid,'%s');
fnames = split(fnames,',');

function l = name(string)
    l = find(fnames{:}==string)
end

% 
% for i=1:structsize-1
%     newf = fnames(i);
%     fields(1).newf = i;
% end


% example plot raw data
% figure,plot(BAL.windOn.edef0.AoA,BAL.windOn.edef0.CL,'*')
