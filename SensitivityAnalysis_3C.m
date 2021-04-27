clear all
close all
clc

flag=1;
% 1 = local univariate sensitivity analysis 
% run basecase for AUC and tumor volume 

% Model parameters for array p base values 
p.weight = 76.8; %1
p.sex = 1;
p.NSCLC = 0; 
p.ECOGPS = 0;
p.IPI = 1;
p.eGFR = 88.47; %2
p.ALB = 39.6; %3
p.BSLD = 89.6; %4
p.Qt = 0.384; % L/day %5
% Drug binding
p.kdegD = 42.9 * 24; % Drug degradation in transporting to tumor 1/day %6
p.kon = 2.88 * 24; % 1/nM-day %7
p.koff = 0.144 * 24; % 1/day %8
p.Emaxtp = 94.7; %9
p.EC50tp = 1.46; % nM %10
% T cell specs
p.NTc = 1500; % cells/uL %11
p.PD1Tc = 10000; % PD1/T cell %12
p.PercT_PD1 = 0.3; % Percent of T cells expressing PD1 %13
% Tumor specs
p.Tmulti = 4.3; % Ratio of PD1 in tumor vs blood %14
p.L0Type = 'f'; % f for fast, i for intermediate and s for slow.
p.gamma = 2; % 2.28; % Drug effect term %15
p.SLtgScale = 'weight'; % weight scale or L0 scale

p = PatientParam_3C_Sen(p); % Update Patient PK parameters.

%percent change of parameter
ParamDelta = 0.05;

%Different doing methods 
TimeLen =12 * 7; % 12 weeks
% different dosing methods 
q = [(2*p.weight) (10*p.weight) (10*p.weight) 200 400]; % [2mg weight based; 10mg weight based; 200mg fixed dose]
% different doing frequencies

Interval = [3*7 2*7 3*7 3*7 6*7]; % Once every 2 or 3 weeks

params = {'weight','eGFR','ALB','BSLD', 'Qt', 'kdegD', 'kon','koff', 'Emaxtp', ...
    'EC50tp', 'NTc', 'PD1Tc', 'PercT_PD1', 'Tmulti','gamma' }; 
dosing = {'2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W'};

% 1 = pembrolizumab in central (mg/L);
% 2 = pembrolizumab in peripheral (mg/L);
% 3 = pembrolizumab in clearance (mg/L);
% 4 = pembrolizumab in tumor interstitial volume (Note: nM);
% 5 = complex of pembrolizumab:PD1 in tumor interstitial volume (nM);
% 6 = PD1 in tumor interstitial volume (nM);
% 7 = Tumor volume (mm^3);
% 8 = pembrolizumab in tumor clearance (mg) (complex degradation is also included);
% 9 = current Drug in tumor compartment (mg) (pembrolizumab + pembrolizumab:PD1 complex)


switch flag 
    case 1   
t = [];
y1 = [];
y5 = [];
y7 = [];
y9 = [];

%calculate the base case

for j = 1:5 %loop through 3 dosing methods  
    y0 = [q(j) / p.v1, 0, 0, 0, 0, p.P0, p.vt0, 0, 0];
    [T, Ytemp, Cmaxb(j), AUC12Wb(j), Vtumorb(j), Dtumorb(j)] = ...
    Sen_Simulation_3C(p,y0,TimeLen,Interval(j),q(j));
    y1 = [y1 Ytemp(:,1)];
    y5 = [y5 Ytemp(:,5)];
    y7 = [y7 Ytemp(:,7)];
    y9 = [y9 Ytemp(:,9)];

end

t = [t T];

column_names = [];

for i=1:numel(params)
    for m = 1:5 % three dosing methods 
        pnew = p;
        pnew.(params{i})= p.(params{i}) * (1 + ParamDelta)
        if strcmp(params {i}, 'weight') || strcmp(params {i}, 'eGFR') || ...
            strcmp(params {i},'ALB')|| strcmp(params {i}, 'BSLD') || strcmp (params {i}, 'NTc') ||...
            strcmp(params {i}, 'PD1Tc') || strcmp(params {i}, 'PercT_PD1')
            pnew = PatientParam_3C_Sen(pnew); %Update Patient PK parameters.
        end
        % [2mg weight based; 10mg weight based; 200mg fixed dose]
        qnew = [(2*pnew.weight) (10*pnew.weight) (10*pnew.weight) 200 400];
        y0 = [qnew(m) / pnew.v1, 0, 0, 0, 0, p.P0, p.vt0, 0, 0];
        [ttemp, ytemp, Cmax(i,m), AUC12W(i,m), Vtumor(i,m), Dtumor(i,m)] = ...
        Sen_Simulation_3C(pnew,y0,TimeLen,Interval(m),qnew(m));
        y1 = [y1 ytemp(:,1)];
        y5 = [y5 ytemp(:,5)];
        y7 = [y7 ytemp(:,7)];
        y9 = [y9 ytemp(:,9)];
        Cmax3C(i,m) = ((Cmax(i,m)-Cmaxb(m))/Cmaxb(m))/ ParamDelta ; 
        AUC12W3C(i,m) = ((AUC12W(i,m)-AUC12Wb(m))/AUC12Wb(m))/ ParamDelta ;
        Vtumor3C(i,m) = ((Vtumor(i,m)-Vtumorb(m))/Vtumorb(m))/ ParamDelta ;
        Dtumor3C(i,m) = ((Dtumor(i,m)-Dtumorb(m))/Dtumorb(m))/ ParamDelta ;
        column_names =[column_names strcat(params{i}, ", ", dosing{m})]; 
        
    end
end 



%save the sensitivity for AUC in first 4 weeks  
save Cmax3C.mat Cmax3C
%save the sensitivity for AUC in first 12 weeks     
save AUC12W3C.mat AUC12W3C
% save the sensitivity for Cmax
save Vtumor3C.mat Vtumor3C
% save the sensitivity for Cmax
save Dtumor3C.mat Dtumor3C
% save all the data points for pembrolizumab in central (mg/L)
save y1.mat t y1
% save all the data points for complex of pembrolizumab:PD1 in tumor interstitial volume (nM);
save y5.mat t y5
% save all the data points for Tumor volume (mm^3);
save y7.mat t y7
% save all the data points for pembrolizumab in central (mg/L)
save y9.mat t y9

end

