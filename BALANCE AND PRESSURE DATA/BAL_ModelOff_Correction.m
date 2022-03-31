function [BIGGIE_Corr_MO] = BAL_ModelOff_Correction(BIGGIE)
%% Uncomment function and pass BIGGIE as array
%% Called BIGGIE for test. 
%BIGGIE = readtable('FULLMAT.txt'); %Comment when in use !!!
BIGGIE_head = fieldnames(BIGGIE)';
BAL_array = table2array(BIGGIE); %Comment when in use !!!
%% Data in Corr_mat for AoA = 0 deg
%% CL replaced by CL at AoA = 4 deg at 40 m/s
%%          AoS    CY      CL      CD     CMroll   CMpitch    CMyaw
Corr_MO = [-10	-0.0111	 0.0087	 0.0277	  0.0061   -0.0399	 0.0079;
            -5	-0.0369	 0.0087	 0.009	  0.0105   -0.0035	 0.017;
             0	-0.0015	 0.0087	 0.0076	 -0.0004   -0.0062	 0.0038;
             5	 0.0132	 0.0087	 0.0057	 -0.0083	0.0015	-0.0086;
            10	 0.0619	 0.0087	 0.0058	 -0.0189	0.0177	-0.0197];
        % Reorderd like BIGGIE
tol = 1;
Corr_headers = ["AoS", "CY", "CL", "CD", "CMroll", "CMpitch", "CMyaw"];
for i=1:height(BIGGIE)
    for col=2:length(Corr_headers)
        var = Corr_headers(col);
        col_idx = find(string(fieldnames(BIGGIE))==var);
        corr_idx = find(contains(Corr_headers,var));
        
        if abs(BAL_array(i,2)-(-10))<tol %Correction at Beta = -10
            BAL_array(i,col_idx) = BAL_array(i,col_idx) - Corr_MO(1,corr_idx);
            
        elseif abs(BAL_array(i,2)-(-5))<tol %Correction at Beta = -5
            BAL_array(i,col_idx) = BAL_array(i,col_idx) - Corr_MO(2,corr_idx);
            
        elseif abs(BAL_array(i,2)-(0))<tol %Correction at Beta = 0
            BAL_array(i,col_idx) = BAL_array(i,col_idx) - Corr_MO(3,corr_idx);
            
        elseif abs(BAL_array(i,2)-(5))<tol %Correction at Beta = 5
            BAL_array(i,col_idx) = BAL_array(i,col_idx) - Corr_MO(4,corr_idx);
            
        elseif abs(BAL_array(i,2)-(10))<tol %Correction at Beta = 10
            BAL_array(i,col_idx) = BAL_array(i,col_idx) - Corr_MO(5,corr_idx); 
        else
            disp("Beta Outlier")
            disp(string([i,col_idx]))
        end
    end
end
%% IGNORE; just for notes
% BAL_array(i,52) = BAL_array(i,52) - Corr_Mat(1,2); % CY Correction
% BAL_array(i,53) = BAL_array(i,53) - Corr_Mat(1,3); % CL Correction
% BAL_array(i,54) = BAL_array(i,54) - Corr_Mat(1,4); % CD Correction
% BAL_array(i,56) = BAL_array(i,56) - Corr_Mat(1,5); % CMroll Correction
% BAL_array(i,57) = BAL_array(i,57) - Corr_Mat(1,6); % CMpitch Correction
% BAL_array(i,59) = BAL_array(i,59) - Corr_Mat(1,7); % CMyaw Correction
%% Output Model-Off-Corrected BIGGIE Array:
BIGGIE_Corr_MO = array2table(BAL_array,"VariableNames",BIGGIE_head(1:end-3))
end