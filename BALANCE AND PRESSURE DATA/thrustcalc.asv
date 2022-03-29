clear 
close all
clc

load FULLMAT.mat;
propdata = csvread('PropData/wpd_datasets.csv',2,0);
v_20 = propdata(:,1:2);
v_40 = propdata(:,5:6);

Js = [1.6,2.0];

CT20 = interp1(v_20(:,1),v_20(:,2),Js);
CT40 = interp1(v_40(:,1),v_40(:,2),Js);

coeffs = polyfit([v_20(end,1), v_20(end-1,1)], [v_20(end,2), v_20(end-1,2)], 1);
a = coeffs(1);
b = coeffs(2);
CT20 = [CT20, a*2.4+b ];

coeffs = polyfit([v_40(end,1), v_40(end-1,1)], [v_40(end,2), v_40(end-1,2)], 1);
a = coeffs(1);
b = coeffs(2);
CT40 = [CT40, a*2.4+b ];

coeffs = polyfit([v_40(1,1), v_40(2,1)], [v_40(1,2), v_40(2,2)], 1);
a = coeffs(1);
b = coeffs(2);
CT40(1) = a*1.6+b;
CTs = [20, CT20;40, CT40];

save('CTs.mat','CTs')