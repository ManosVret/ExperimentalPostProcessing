%function [BIGGIE_Corr_TO] = BAL_ModelOff_Correction(BIGGIE)
%% Uncomment function and pass BIGGIE as array
%% Called BIGGIE for test. 
BIGGIE = readtable('FULLMAT.txt'); %Comment when in use !!!
BIGGIE_head = fieldnames(BIGGIE)';
BAL_array = table2array(BIGGIE); %Comment when in use !!!
%%

Corr_mat = readtable("TAILOFF DATA\raw_tailOff_alfa5_betaSweep.txt");

%% Output Tail-Off-Corrected BIGGIE Array:
%BIGGIE_Corr_TO = array2table(BAL_array,"VariableNames",BIGGIE_head(1:end-3));
%end