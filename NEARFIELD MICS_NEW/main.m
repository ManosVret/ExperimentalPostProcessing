close all
clear
clc

%% Inputs
% path to folder containing the measurement data
fnFolder = './DATA/MICS';

fn = {'20_rudder.txt'}%,...
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

%%% WITE OUT DATA YOU BITCH

figure('Name','Spectra')
for i=1:6
    subplot(2,3,i), box on, hold on
    plot(MIC{1}.f{1}/opp{1}.RPS_M1(1),MIC{1}.SPL{1}(:,i),'b')
    plot(MIC{1}.f{2}/opp{1}.RPS_M1(2),MIC{1}.SPL{2}(:,i),'r')
    xlim([0 13])
    xlabel('Frequency f/RPS [-]')
    ylabel('SPL [dB]')
    title(['Mic ',num2str(i)])
    ylim([50 120])
end

%% OASPL: 
for i=1:6
    subplot(2,3,i), box on, hold on
    plot(opp{i}.RPS_M1(1),OASPL(MIC{1}.f{1}(:,i),MIC{1}.SPL{1}(:,i)),'b')
    plot(opp{i}.RPS_M1(2),OASPL(MIC{1}.f{2}(:,i),MIC{1}.SPL{2}(:,i)),'r')
    %xlim([0 13])
    xlabel('Engine Setting RPS [Hz]')
    ylabel('OASPL [dB]')
    title(['Mic ',num2str(i)])
    %ylim([50 120])
end

% OASPL = [[1400,-10];[1600,-5];[2000,0];[2400,5];[3000,10]];
% RPM = linspace(0,1400,length(OASPL));
% for i=1:length(OASPL)
%     plot(RPM(i),OASPL(i,1))
%     hold on
%     plot(RPM(i),OASPL(i,1))
%     hold off
%     xlabel("RPM [-]") % J
%     ylabel("OASPL [dB]")
%     title("OASPL for \delta_{r}=" + str())
% end