function [AUC1, AUC2, AUC4W1, AUC4W2, Cmax1, Cmax2] = PKDrive_2C(weight, albumin, sex, scenario)

%% PARAMETERS
p.weight = weight; % kg
p.sex = sex; % Male: 1; Female: 2
p.NSCLC = 0;
p.ECOGPS = 0;
p.IPI = 1;
p.eGFR = 88.47;
p.ALB = albumin;
p.BSLD = 89.6;
p = PatientParam_2C(p); % Update Patient PK parameters.

%% SIMULATIONS
TimeLen = 24 * 7; % 12 weeks

SCENARIO = scenario;
switch SCENARIO
    case 1
        % 2mg/kg Q3W
        Interval = 3 * 7; % Once every 3 weeks
        NumDose = TimeLen / Interval; % Q3W
        q = 2 * p.weight; % mg/kg
    case 2
        % 10mg/kg Q2W
        Interval = 2 * 7; % Once every 2 weeks
        NumDose = TimeLen / Interval; % Q2W
        q = 10 * p.weight; % mg/kg
    case 3
        % 10mg/kg Q3W
        Interval = 3 * 7; % Once every 3 weeks
        NumDose = TimeLen / Interval; % Q3W
        q = 10 * p.weight; % mg/kg
    case 4
        % 200mg Q3W
        Interval = 3 * 7; % Once every 3 weeks
        NumDose = TimeLen / Interval; % Q3W
        q = 200; % mg
    case 5
        % 400mg Q6W
        Interval = 6 * 7; % Once every 6 weeks
        NumDose = TimeLen / Interval; % Q6W
        q = 400; % mg
end
T = [];
Y = [];
Balance = [];
y0 = [q / p.v1, 0, 0];

options = odeset('MaxStep', 5e-2, 'AbsTol', 1e-5, 'RelTol', 1e-5, 'InitialStep', 1e-2);
for i = 1:NumDose
    TStart = (i - 1) * Interval;
    TEnd = i * Interval;
    [Ttemp, Ytemp] = ode45(@pembrolizumab_2C_eqns, [TStart:0.1:TEnd], y0, options, p);
    T = [T(1:end-1); Ttemp];
    Y = [Y(1:end-1, :); Ytemp];
    y0 = Y(end, :) + [q / p.v1, 0, 0];
    
    % Mass balance
    DrugIn = q * i;
    InitialDrug = 0;
    CurrentDrug = Ytemp(:, 1) * p.v1 + Ytemp(:, 2) * p.v2;
    DrugOut = Ytemp(:, 3) * p.v1; % Assume v3 = v1
    Balance = [Balance; DrugIn + InitialDrug - CurrentDrug - DrugOut];
end

% 12W AUC
AUC1 = trapz(T, Y(:, 1));
AUC2 = trapz(T, Y(:, 2));

% 4W AUC
AUC4W1 = trapz(T(1:673), Y(1:673, 1));
AUC4W2 = trapz(T(1:673), Y(1:673, 2));

% C max
Cmax1 = max(Y(:, 1));
Cmax2 = max(Y(:, 2));
