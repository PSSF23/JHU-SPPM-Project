function [AUC, Cmax, TVCR, CCmax] = PKDrive_3C(weight, albumin, sex, scenario)

%% PARAMETERS
p.weight = weight; % kg
p.sex = sex; % Male: 1; Female: 2
p.NSCLC = 0;
p.ECOGPS = 0;
p.IPI = 1;
p.eGFR = 88.47;
p.ALB = albumin;
p.BSLD = 89.6;
p.Qt = 0.384; % L/day

% Drug binding
p.kdegD = 42.9 * 24; % Drug degradation in transporting to tumor 1/day
p.kon = 2.88 * 24; % 1/nM-day
p.koff = 0.144 * 24; % 1/day
p.Emaxtp = 94.7;
p.EC50tp = 1.46; % nM

% T cell specs
p.NTc = 1500; % cells/uL
p.PD1Tc = 10000; % PD1/T cell
p.PercT_PD1 = 0.3; % Percent of T cells expressing PD1

% Tumor specs
p.Tmulti = 4.3; % Ratio of PD1 in tumor vs blood
p.L0Type = 'f'; % f for fast, i for intermediate and s for slow.
p.gamma = 2; % 2.28; % Drug effect term
p.SLtgScale = 'weight'; % weight scale or L0 scale
p = PatientParam_3C(p); % Update Patient PK parameters.

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
y0 = [q / p.v1, 0, 0, 0, 0, p.P0, p.vt0, 0, 0];

options = odeset('MaxStep', 5e-2, 'AbsTol', 1e-5, 'RelTol', 1e-5, 'InitialStep', 1e-2);
for i = 1:NumDose
    TStart = (i - 1) * Interval;
    TEnd = i * Interval;
    [Ttemp, Ytemp] = ode45(@pembrolizumab_3C_eqns, [TStart:0.1:TEnd], y0, options, p);
    T = [T(1:end-1); Ttemp];
    Y = [Y(1:end-1, :); Ytemp];
    y0 = Y(end, :) + [q / p.v1, 0, 0, 0, 0, 0, 0, 0, 0];
    
    % Mass balance
    DrugIn = q * i;
    InitialDrug = 0;
    CurrentDrug = Ytemp(:, 1) * p.v1 + Ytemp(:, 2) * p.v2;
    DrugOut = Ytemp(:, 3) * p.v1; % Assume v3 = v1
    Balance = [Balance; DrugIn + InitialDrug - CurrentDrug - DrugOut];
end

% 12W AUC
AUC = trapz(T, Y(:, 1));

% C max
Cmax = max(Y(:, 1));

% Tumor colume change ratio
TVCR = Y(end, 7) / Y(1, 7) - 1;

% Complex C max
CCmax = max(Y(:, 5));
