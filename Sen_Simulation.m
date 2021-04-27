function [T,Y,AUC4W,AUC12W,Cmax] = Sen_Simulation(p,y0,TimeLen, Interval, q)
%% CALL SOLVER
T = [];
Y = [];
Balance = [];


options = odeset('MaxStep',5e-2, 'AbsTol', 1e-5,'RelTol', 1e-5,'InitialStep', 1e-2);


%% Parameters
NumDose = TimeLen / Interval;  

%% Simulation
for i = 1:NumDose
    TStart = (i - 1) * Interval;
    TEnd = i * Interval;
    [Ttemp, Ytemp] = ode45(@pembrolizumab_2C_eqns, [TStart:0.1:TEnd], y0, options, p);
    T = [T(1:end-1); Ttemp]; 
    Y = [Y(1:end-1,:); Ytemp];
    y0 = Y(end, :) + [q / p.v1, 0, 0];
    
    % Mass balance
    DrugIn = q * i;
    InitialDrug = 0;
    CurrentDrug = Ytemp(:, 1) * p.v1 + Ytemp(:, 2) * p.v2;
    DrugOut = Ytemp(:, 3) * p.v1; % Assume v3 = v1
    Balance = [Balance; DrugIn + InitialDrug - CurrentDrug - DrugOut];
end

if mean(Balance)>1e-6 disp('Mass imbalance possible: '); 
    disp(Balance);
end

AUC4W = trapz(T(1:280),Y(1:280,1));
AUC12W = trapz(T,Y(:,1));
Cmax = max(Y(:,1));



