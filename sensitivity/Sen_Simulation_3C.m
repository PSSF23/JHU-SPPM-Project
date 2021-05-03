function [T, Y, Cmax, AUC12W, Vtumor, Dtumor] = Sen_Simulation_3C(p, y0, TimeLen, Interval, q)

%% CALL SOLVER
T = [];
Y = [];
Balance = [];


options = odeset('MaxStep', 5e-2, 'AbsTol', 1e-5, 'RelTol', 1e-5, 'InitialStep', 1e-2);

%% Parameters
NumDose = TimeLen / Interval;

%% Simulation
for i = 1:NumDose
    TStart = (i - 1) * Interval;
    TEnd = i * Interval;
    [Ttemp, Ytemp] = ode15s(@pembrolizumab_3C_eqns, [TStart:0.1:TEnd], y0, options, p);
    T = [T(1:end-1); Ttemp];
    Y = [Y(1:end-1, :); Ytemp];
    y0 = Y(end, :) + [q / p.v1, 0, 0, 0, 0, 0, 0, 0, 0];
    
    
    % Mass balance
    DrugIn = q * i;
    InitialDrug = 0;
    CurrentDrug = Ytemp(:, 1) * p.v1 + Ytemp(:, 2) * p.v2 ...
        +Ytemp(:, 9);
    DrugOut = Ytemp(:, 3) * p.v1 ...
        +Ytemp(:, 8);% Assume v3 = v1
    Balance = [Balance; DrugIn + InitialDrug - CurrentDrug - DrugOut];
end

if mean(Balance) > 1e-6 disp('Mass imbalance possible: ');
    disp(Balance);
end

Cmax = max(Y(:, 1));
AUC12W = trapz(T, Y(:, 1));
Vtumor = log(Y(1, 7)) / log(Y(end, 7));
Dtumor = Y(end, 9);
