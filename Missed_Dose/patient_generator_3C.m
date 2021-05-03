%Generate a structure array of patient with varying weight and albumin for
%3C models
clear all;

%% Average Patient statistics
% 2 compartment parameters
p.NSCLC = 0;
p.ECOGPS = 0;
p.IPI = 1;
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
p.gamma = 1.8; %2.28; % Drug effect term
p.SLtgScale = 'weight'; % weight scale or L0 scale

%% Generate patient Distribution
NumberOfPatients = 1000
PatientDist = PatientDistSim(NumberOfPatients);
% WEIGHT = 1;
% ALB = 2;
% BSLD = 3;
% eGFR = 4;

%% Only weight varies among the population
%500 Male patients
for i = 1:NumberOfPatients / 2
    p.sex = 1;
    p.weight = PatientDist(i, 1);
    p.ALB = 39.6;
    p.eGFR = 88.47;
    p.BSLD = 89.6;
    patient_weight(i) = PatientParam_3C(p); %Update Patient PK parameters.
end
%500 Female
for i = (NumberOfPatients / 2 + 1):NumberOfPatients
    p.sex = 2;
    p.weight = PatientDist(i, 1);
    p.ALB = 39.6;
    p.eGFR = 88.47;
    p.BSLD = 89.6;
    patient_weight(i) = PatientParam_3C(p);
end

%% Only albumin varies among the population
%500 Male patients
for i = 1:NumberOfPatients / 2
    p.sex = 1;
    p.weight = 76.8;
    p.ALB = PatientDist(i, 2);
    p.eGFR = 88.47;
    p.BSLD = 89.6;
    patient_ALB(i) = PatientParam_3C(p); %Update Patient PK parameters.
end
%500 Female
for i = (NumberOfPatients / 2 + 1):NumberOfPatients
    p.sex = 2;
    p.weight = 76.8;
    p.ALB = PatientDist(i, 2);
    p.eGFR = 88.47;
    p.BSLD = 89.6;
    patient_ALB(i) = PatientParam_3C(p);
end

%% Both weight and albumin varies among the population
%500 Male patients
for i = 1:NumberOfPatients / 2
    p.sex = 1;
    p.weight = PatientDist(i, 1);
    p.ALB = PatientDist(i, 2);
    p.eGFR = 88.47;
    p.BSLD = 89.6;
    patient_weight_ALB(i) = PatientParam_3C(p); %Update Patient PK parameters.
end
%500 Female
for i = (NumberOfPatients / 2 + 1):NumberOfPatients
    p.sex = 2;
    p.weight = PatientDist(i, 1);
    p.ALB = PatientDist(i, 2);
    p.eGFR = 88.47;
    p.BSLD = 89.6;
    patient_weight_ALB(i) = PatientParam_3C(p);
end

%% Save data
save('Patients_3C.mat', 'patient_ALB', 'patient_weight', 'patient_weight_ALB');
