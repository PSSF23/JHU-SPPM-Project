function patientDist = PatientDistSim(NumberOfSubjects)
%Generate a distribution of 1000 patients with varying weight, albumin, BSLD and
%eGFR.

%% Distribution Parameters

WEIGHT = 1;
ALB = 2;
BSLD = 3;
eGFR = 4;

Means(WEIGHT) = 76.8; % kg
Means(ALB) = 39.6; % g/L
Means(BSLD) = 89.6; % mm
Means(eGFR) = 88.47; % mL/min/1.73 m^2

SD(WEIGHT) = 10;
SD(ALB) = 3.3;
SD(BSLD) = 14.87;
SD(eGFR) = 9.7;

LowCutoff(WEIGHT) = 56.8;
LowCutoff(ALB) = 15;
LowCutoff(BSLD) = 10;
LowCutoff(eGFR) = 25.4;

HighCutoff(WEIGHT) = 96.8;
HighCutoff(ALB) = 59;
HighCutoff(BSLD) = 895;
HighCutoff(eGFR) = 403;

%% Generate Simulations

% Initiate Random Numbers
rng(0, 'twister');

% Generate Subpopulations
for i = 1:4 % 4 params
    xtemp = SD(i) .* randn(NumberOfSubjects, 1) + Means(i);
    a = length(xtemp(xtemp < LowCutoff(i))) + length(xtemp(xtemp > HighCutoff(i)));
    cycle = 1;
    while a > 0
        xtemp(xtemp < LowCutoff(i) | xtemp > HighCutoff(i)) = SD(i) .* randn(a, 1) + Means(i);
        a = length(xtemp(xtemp <= LowCutoff(i))) + length(xtemp(xtemp > HighCutoff(i)));
        cycle = cycle + 1;
    end
    xdist(i, :) = xtemp;
end

% Output the means, SDs of the simulated populations
SimMeans = mean(xdist, 2);
SimSDs = std(xdist, 0, 2);
fprintf('Weight distribution, input mean %4.1f, simulated mean %4.1f; input SD %4.1f, simulated SD %4.1f \n', ...
    Means(WEIGHT), SimMeans(WEIGHT), SD(WEIGHT), SimSDs(WEIGHT))
fprintf('Albumin distribution, input mean %4.1f, simulated mean %4.1f; input SD %4.1f, simulated SD %4.1f \n', ...
    Means(ALB), SimMeans(ALB), SD(ALB), SimSDs(ALB))
fprintf('Tumor burden distribution, input mean %4.1f, simulated mean %4.1f; input SD %4.1f, simulated SD %4.1f \n', ...
    Means(BSLD), SimMeans(BSLD), SD(BSLD), SimSDs(BSLD))
fprintf('Estimated glomerular filtration rate distribution, input mean %4.1f, simulated mean %4.1f; input SD %4.1f, simulated SD %4.1f \n', ...
    Means(eGFR), SimMeans(eGFR), SD(eGFR), SimSDs(eGFR))

patientID = (1:NumberOfSubjects)';
patientDist = xdist';
% Params = xdist';
% save('PatientSims.mat', 'patientID', 'Params');
end
