%% Average Patient statistics
p.weight = 76.8;
p.sex = 1;
p.NSCLC = 0;
p.ECOGPS = 0;
p.IPI = 1;
p.eGFR = 88.47;
p.ALB = 39.6;
p.BSLD = 89.6;
p.Qt = 0.384; % L/day
% Drug binding
p.kdegD = 42.9*24; % Drug degradation in transporting to tumor 1/day
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
p.gamma = 2;%2.28; % Drug effect term
p.SLtgScale = 'weight'; % weight scale or L0 scale

p = PatientParam_3C(p);%Update Patient PK parameters.

%% Simulation
% Drug specs
MW = 149000*1000/10^9; % (mg/nmol) 
% Parameters
TimeLen = 24*7; %24 weeks
Interval = 3*7; %Once every 3 weeks
NumDose = TimeLen/Interval; %Q3W
q = 2*p.weight; %10mg/kg Q3W
% Temp variables
T = []; Y = []; Balance = [];
y0 = [q/p.v1 0 0 0 0 p.P0 p.vt0 0 0];

options = odeset('MaxStep',5e-2, 'AbsTol', 1e-5,'RelTol', 1e-5,'InitialStep', 1e-2);
for i = 1:NumDose
    TStart = (i-1)*Interval; 
    TEnd = i*Interval;
    [Ttemp,Ytemp] = ode23s(@pembrolizumab_3C_eqns,[TStart:0.5:TEnd],y0,options,p);
    T = [T;Ttemp];
    Y = [Y;Ytemp];
    y0 = Y(end,:)+[q/p.v1 0 0 0 0 0 0 0 0];
    
    %Mass balance
    DrugIn = q*i;
    InitialDrug = 0;
    CurrentDrug = Ytemp(:,1)*p.v1+Ytemp(:,2)*p.v2...
        + Ytemp(:,9);
    DrugOut = Ytemp(:,3)*p.v1...
        + Ytemp(:,8); %Assume v3 = v1
    Balance =[Balance;DrugIn+InitialDrug-CurrentDrug-DrugOut];
end

plot(T,Y(:,1))
%save 2mgQ3W.mat T Y