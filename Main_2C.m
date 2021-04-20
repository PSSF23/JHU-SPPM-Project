clear all;
close all;

%% Average Patient statistics
p.weight = 76.8;
p.sex = 1;
p.NSCLC = 0;
p.ECOGPS = 0;
p.IPI = 1;
p.eGFR = 88.47;
p.ALB = 39.6;
p.BSLD = 89.6;
p = PatientParam_2C(p); % Update Patient PK parameters.

%% Simulation
% Parameters
TimeLen = 24 * 7; % 12 weeks
Interval = 3 * 7; % Once every 3 weeks
NumDose = TimeLen / Interval; % Q3W
q = 2 * p.weight; % 2mg/kg Q3W
% Temp variables

T = [];
Y = [];
Balance = [];
y0 = [q / p.v1, 0, 0];

options = odeset('MaxStep', 5e-2, 'AbsTol', 1e-5, 'RelTol', 1e-5, 'InitialStep', 1e-2);
for i = 1:NumDose
    TStart = (i - 1) * Interval;
    TEnd = i * Interval;
    [Ttemp, Ytemp] = ode45(@pembrolizumab_2C_eqns, [TStart:0.1:TEnd], y0, options, p);
    T = [T; Ttemp];
    Y = [Y; Ytemp];
    y0 = Y(end, :) + [q / p.v1, 0, 0];
    
    % Mass balance
    DrugIn = q * i;
    InitialDrug = 0;
    CurrentDrug = Ytemp(:, 1) * p.v1 + Ytemp(:, 2) * p.v2;
    DrugOut = Ytemp(:, 3) * p.v1; % Assume v3 = v1
    Balance = [Balance; DrugIn + InitialDrug - CurrentDrug - DrugOut];
end

plot(T, Y(:, 1))
save 2mgQ3W.mat T Y
