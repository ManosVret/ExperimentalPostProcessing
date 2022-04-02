close all
clear
clc

%% Inputs
% path to folder containing the measurement data
fnFolder = './DATA/MICS';


fn = {'BEO_0rudder.txt',...
    '20_rudder.txt',...
      'neg20_rudder.txt'};
% fn = {'test.txt'};
%       'test_run1_001.tdms',...
%       'test_run1_001.tdms_index',...
%       'test_run1_001.txt'}%,...
%       'test_run2_001.tdms',...
%       'test_run2_001.tdms_index',...
%       'test_run3_001.tdms',}; % structure of filenames to main txt file containing the averaged data - you can add multiple filenames here
  
% settings for spectral analysis (pwelch function)
nB       = 50;      % number of bins
nOverlap = 0;       % number of samples for overlap
fs       = 51200;   % sampling frequency [Hz]

% propeller geometry
D = 0.2032; % propeller diameter [m]

%% Load microphone calibration data
micCal = load('micCalData_AE4115labExercise');
%micCal.F_mics(4:5,:) = NaN;

%% Loop over all TDMS files of name "Measurement_i.tdms)" in the specified folder
for i=1:length(fn)
   
    % load data operating file
    AVGpath    = [fnFolder,'\',fn{i}];
    AVGdata{i} = load(AVGpath);
    
    opp{i}.DPN    = AVGdata{i}(:,1);
    opp{i}.vInf   = AVGdata{i}(:,7); % freestream velocity [m/s]
    opp{i}.AoA    = AVGdata{i}(:,13);  % angle of attack [deg]
    opp{i}.AoS    = AVGdata{i}(:,14);  % angle of sideslip [deg]
    opp{i}.RPS_M1 = AVGdata{i}(:,15);  % RPS motor 1 [Hz]
    opp{i}.RPS_M2 = AVGdata{i}(:,22);  % RPS motor 2 [Hz]
    opp{i}.J_M1   = opp{i}.vInf./(opp{i}.RPS_M1*D); % advance ratio motor 1
    opp{i}.J_M2   = opp{i}.vInf./(opp{i}.RPS_M2*D); % advance ratio motor 2
    if i==1
        opp{i}.rudder = zeros(size(opp{i}.DPN));
    elseif i==2
        opp{i}.rudder = 20*ones(size(opp{i}.DPN));
    elseif i==3
        opp{i}.rudder = -20*ones(size(opp{i}.DPN));
    end
    
    
    % load microphone data
    for j=1:length(opp{i}.DPN) % loop over all the datapoints for this configuration
        
        % Construct filename (required in case of duplicate files)
        runNo = 1;
        TDMSpath = [fnFolder '/' fn{i}(1:end-4) '_run',num2str(opp{i}.DPN(j)),'_',sprintf('%03.0f',runNo),'.tdms'];
        while exist(TDMSpath)==0 && runNo < 5
            runNo = runNo+1;
            TDMSpath = [TDMSpath(1:end-8),sprintf('%03.0f',runNo),'.tdms'];
        end
        
        % load data
        rawData = ReadFile_TDMS(TDMSpath);
        disp(['Loaded file ' TDMSpath])
        
       % Apply calibration
        for k=1:6 % loop over the microphones     
            [MIC{i}.pMic{j}(k,:),~,~] = apply_cal_curve(fs,rawData{1}(:,k)-mean(rawData{1}(:,k)),micCal.f_oct,micCal.F_mics(k,:));
        end     
                
        % perform spectral analysis
        w        = hann(length(MIC{i}.pMic{j})/nB); % window
        wOvrlp   = length(w)*nOverlap; % overlap window
        [MIC{i}.PXX{j},MIC{i}.SPL{j},MIC{i}.f{j}] = spectralAnalysis(MIC{i}.pMic{j}.',w,wOvrlp,fs,[]);         
    end
end % end while loop over files

%%LOGICAL ARRAYS FOR PARSING DATA FOR SPECIFIC CONDITIONS
%%Its pretty self explanatory what they are
%%OEIl0 stands for OEI-logical-0 (0 for 0 rudder), for +20 and -20, ive
%%used p and n for pos and neg
%%OEI-l(logical)-*(rudder=0,p20,n20)
OEIl0 = (round(opp{1}.RPS_M1,1)~=round(opp{1}.RPS_M2,1)); 
OEIlp = (round(opp{2}.RPS_M1,1)~=round(opp{2}.RPS_M2,1));
OEIln = (round(opp{3}.RPS_M1,1)~=round(opp{3}.RPS_M2,1));

%%vInf-l(logical)-*(rudder=0,p20,n20)
V20l0 = (round(opp{1}.vInf,1)==20);
V40l0 = (round(opp{1}.vInf,1)==40);
V20lp = (round(opp{2}.vInf,1)==20);
V40lp = (round(opp{2}.vInf,1)==40);
V20ln = (round(opp{3}.vInf,1)==20);
V40ln = (round(opp{3}.vInf,1)==40);

%%AoS-l(logical)-*(rudder=0,p20,n20)
Bn10l0 = (round(opp{1}.AoS,1)==-10);
Bn5l0 = (round(opp{1}.AoS,1)==-5);
B0l0 = (round(opp{1}.AoS,1)==0);
Bp5l0 = (round(opp{1}.AoS,1)==5);
Bp10l0 = (round(opp{1}.AoS,1)==10);

Bn10lp = (round(opp{2}.AoS,1)==-10);
Bn5lp = (round(opp{2}.AoS,1)==-5);
B0lp = (round(opp{2}.AoS,1)==0);
Bp5lp = (round(opp{2}.AoS,1)==5);
Bp10lp = (round(opp{2}.AoS,1)==10);

Bn10ln = (round(opp{3}.AoS,1)==-10);
Bn5ln = (round(opp{3}.AoS,1)==-5);
B0ln = (round(opp{3}.AoS,1)==0);
Bp5ln = (round(opp{3}.AoS,1)==5);
Bp10ln = (round(opp{3}.AoS,1)==10);

%%J_M2-l(logical)-*(rudder=0,p20,n20)
J16l0 = (round(opp{1}.J_M2,1)==1.6);
J20l0 = (round(opp{1}.J_M2,1)==2.0);
J24l0 = (round(opp{1}.J_M2,1)==2.4);
J16lp = (round(opp{2}.J_M2,1)==1.6);
J20lp = (round(opp{2}.J_M2,1)==2.0);
J24lp = (round(opp{2}.J_M2,1)==2.4);
J16ln = (round(opp{3}.J_M2,1)==1.6);
J20ln = (round(opp{3}.J_M2,1)==2.0);
J24ln = (round(opp{1}.J_M2,1)==2.4);


%%PLOTTING

%%plots for rudder 0, V=20
%%taking the combination of all the logical arrays returns the array that
%%corresponds to the points that we want: this is
%%δr=0,OEI,V=20,β=sweep,J=sweep
%%Unfortunately, for some reason if you look at the plots; they all have 2
%%datapoints at 0 OASPL idk why, maybe worth looking at the function OASPL,
%%since I've changed it a bit but yeah no clue.

%%Also it seems that β has almost no effect on the plots, since all 3 line
%%up exactly. Likely a parsing problem.

plt11 = OEIl0&V20l0&Bn10l0;
plt12 = OEIl0&V20l0&Bn5l0;
plt13 = OEIl0&V20l0&B0l0;
plt14 = OEIl0&V20l0&Bp5l0;
plt15 = OEIl0&V20l0&Bp10l0;

y1 = OASPL(opp,MIC,1,plt11);
x1 = opp{1}.J_M2(plt11);
y2 = OASPL(opp,MIC,1,plt12);
x2 = opp{1}.J_M2(plt12);
y3 = OASPL(opp,MIC,1,plt13);
x3 = opp{1}.J_M2(plt13);

plot(x1,y1);
hold on
plot(x2,y2);
plot(x3,y3);
hold off






%% figure('Name','Spectra')
% for i=1:6
%     subplot(2,3,i), box on, hold on
%     plot(MIC{1}.f{1}/opp{1}.RPS_M1(1),MIC{1}.SPL{1}(:,i),'b')
%     plot(MIC{1}.f{2}/opp{1}.RPS_M1(2),MIC{1}.SPL{2}(:,i),'r')
%     xlim([0 13])
%     xlabel('Frequency f/RPS [-]')
%     ylabel('SPL [dB]')
%     title(['Mic ',num2str(i)])
%     ylim([50 120])
% end

% OASPL: 
% for i=1:6
%     subplot(2,3,i), box on, hold on
%     plot(opp{1}.RPS_M1(1),OASPL(MIC{1}.f{:},MIC{1}.SPL{1}(:,:)),'b')
%     plot(opp{1}.RPS_M1(1),OASPL(MIC{1}.f{:},MIC{1}.SPL{2}(:,:)),'r')
%     %xlim([0 13])
%     xlabel('Engine Setting RPS [Hz]')
%     ylabel('OASPL [dB]')
%     title(['Mic ',num2str(i)])
%     %ylim([50 120])
% end
% oasplar= [];
% for i=1:length(MIC{1, 1}.SPL) %OASPL for mic 1 for all runs (3 in test file)
%     oasplar(i) = OASPL(MIC{1}.f{i},MIC{1}.SPL{i}(:,1));
% end

% scatter(opp{1}.RPS_M1(:),oasplar,'b');
% % plot(opp{1}.RPS_M1(1),OASPL(MIC{1}.f{:},MIC{1}.SPL{2}(:,:)),'r')
% %xlim([0 13])
% xlabel('Engine Setting RPS [Hz]')
% ylabel('OASPL [dB]')
% title(['Mic'])
%%ylim([50 120])