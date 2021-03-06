clear all;

%% Five dosing regimens:
% 2mg/kg Q3W
% 10mg/kg Q3W
% 10mg/kg Q2W
% 200mg Q3W
% 400mg Q6W

%% Two missed dose regimens with a length of 12 weeks
% 1. Missed dose at 2nd dose
% 2. Missed dose at 2nd dose but retaken 1/5, 2/5, 3/5, 4/5 or 1 dosing
% intervals later.
TimeLen = 12;

%% Part 1-2C. Missed dose at 2nd dose for 2C
% Read patient data for 2C
load('Patients_2C.mat');
for dosing_method = 1:5
    AUC_miss = zeros(1, length(patient_weight_ALB));
    AUC_full = AUC_miss;
    Cmax_miss = zeros(1, length(patient_weight_ALB));
    Cmax_full = Cmax_miss;
    Ctrough_miss = zeros(1, length(patient_weight_ALB));
    Ctrough_full = Ctrough_miss;
    WAIT = waitbar(0, strcat('Now progress dosing method ', int2str(dosing_method), '...'));
    for pID = 1:length(patient_weight_ALB)
        patient = patient_weight_ALB(pID);
        % Dose regimen
        [Interval, Dose, fixed, dose_name] = dose_regime(dosing_method, patient);
        % Full dose for 2C
        [AUC_full(pID), Cmax_full(pID), Ctrough_full(pID), ~, ~] = full_dose_driver_2C(patient, TimeLen, Interval, fixed, Dose);
        % Missed dose for 2C
        [AUC_miss(pID), Cmax_miss(pID), Ctrough_miss(pID), ~, ~] = missed_dose_driver_2C(patient, TimeLen, Interval, fixed, Dose);
        waitbar(pID/length(patient_weight_ALB), WAIT)
    end
    save(strcat('data/Missed_2C_', dose_name, '.mat'), 'AUC_miss', 'Cmax_miss', 'Ctrough_miss');
    save(strcat('data/Full_2C_', dose_name, '.mat'), 'AUC_full', 'Cmax_full', 'Ctrough_full');
    close(WAIT)
end

%% Part 2-2C. Retaken 2nd dose for 2C
for dosing_method = 1:5
    AUC_retake = zeros(5, length(patient_weight_ALB));
    Cmax_retake = zeros(5, length(patient_weight_ALB));
    Ctrough_retake = zeros(5, length(patient_weight_ALB));
    for retake_time = 1:5
        WAIT = waitbar(0, strcat('Now progress dosing method ', int2str(dosing_method), ...
            ' retake time ', int2str(retake_time), '...'));
        for pID = 1:2 %length(patient_weight_ALB)
            patient = patient_weight_ALB(pID);
            % Dose regimen
            [Interval, Dose, fixed, dose_name] = dose_regime(dosing_method, patient);
            % Retaken dose
            [AUC_retake(retake_time, pID), Cmax_retake(retake_time, pID), Ctrough_retake(retake_time, pID), ~, ~] = ...
                retaken_dose_driver_2C(patient, TimeLen, Interval, fixed, Dose, retake_time);
            waitbar(pID/length(patient_weight_ALB), WAIT)
        end
        close(WAIT)
    end
    save(strcat('data/Retake_2C_', dose_name, '.mat'), 'AUC_retake', 'Cmax_retake', 'Ctrough_retake');
end

%% Part 1-3C Missed dose at 2nd dose for 3C
% Read patient data for 3C
load('Patients_3C.mat');
tic
for dosing_method = 1:5
    AUC_miss = zeros(1, length(patient_weight_ALB));
    AUC_full = AUC_miss;
    Cmax_miss = zeros(1, length(patient_weight_ALB));
    Cmax_full = Cmax_miss;
    Ctrough_miss = zeros(1, length(patient_weight_ALB));
    Ctrough_full = Ctrough_miss;
    Tumor_ratio_miss = zeros(1, length(patient_weight_ALB));
    Tumor_ratio_full = Tumor_ratio_miss;
    Dcomplex_min_miss = zeros(1, length(patient_weight_ALB));
    Dcomplex_min_full = Dcomplex_min_miss;
    WAIT = waitbar(0, strcat('Now progress dosing method ', int2str(dosing_method), '...'));
    for pID = 1:length(patient_weight_ALB)
        patient = patient_weight_ALB(pID);
        % Dose regimen
        [Interval, Dose, fixed, dose_name] = dose_regime(dosing_method, patient);
        % Full dose for 3C
        [AUC_full(pID), Cmax_full(pID), Ctrough_full(pID), Tumor_ratio_full(pID), Dcomplex_min_full(pID), ...
            ~, ~] = full_dose_driver_3C(patient, TimeLen, Interval, fixed, Dose);
        % Missed dose for 3C
        [AUC_miss(pID), Cmax_miss(pID), Ctrough_miss(pID), Tumor_ratio_miss(pID), Dcomplex_min_miss(pID), ...
            ~, ~] = missed_dose_driver_3C(patient, TimeLen, Interval, fixed, Dose);
        waitbar(pID/length(patient_weight_ALB), WAIT)
    end
    save(strcat('data/Missed_3C_', dose_name, '.mat'), 'AUC_miss', 'Cmax_miss', 'Ctrough_miss', ...
        'Tumor_ratio_miss', 'Dcomplex_min_miss');
    save(strcat('data/Full_3C_', dose_name, '.mat'), 'AUC_full', 'Cmax_full', 'Ctrough_full', ...
        'Tumor_ratio_full', 'Dcomplex_min_full');
    close(WAIT)
end
toc

%% Part 2-3C. Retaken 2nd dose for 3C
for dosing_method = 1:5
    AUC_retake = zeros(5, length(patient_weight_ALB));
    Cmax_retake = zeros(5, length(patient_weight_ALB));
    Ctrough_retake = zeros(5, length(patient_weight_ALB));
    Tumor_ratio_retake = zeros(5, length(patient_weight_ALB));
    Dcomplex_min_retake = zeros(5, length(patient_weight_ALB));
    for retake_time = 1:5
        WAIT = waitbar(0, strcat('Now progress dosing method ', int2str(dosing_method), ...
            ' retake time ', int2str(retake_time), '...'));
        for pID = 1:length(patient_weight_ALB)
            patient = patient_weight_ALB(pID);
            % Dose regimen
            [Interval, Dose, fixed, dose_name] = dose_regime(dosing_method, patient);
            % Retaken dose
            [AUC_retake(retake_time, pID), Cmax_retake(retake_time, pID), Ctrough_retake(retake_time, pID), ...
                Tumor_ratio_retake(retake_time, pID), Dcomplex_min_retake(retake_time, pID), ~, ~] = ...
                retaken_dose_driver_3C(patient, TimeLen, Interval, fixed, Dose, retake_time);
            waitbar(pID/length(patient_weight_ALB), WAIT)
        end
        close(WAIT)
    end
    save(strcat('data/Retake_3C_', dose_name, '.mat'), 'AUC_retake', 'Cmax_retake', 'Ctrough_retake', ...
        'Tumor_ratio_retake', 'Dcomplex_min_retake');
end

%% Comparison of 2C and 3C models
dosing_method = 2;
TimeLen = 24;
[Interval, Dose, fixed, dose_name] = dose_regime(dosing_method, patient);
[~, ~, ~, T_2c, Y_2c] = full_dose_driver_2C(patient, TimeLen, Interval, fixed, Dose);
[~, ~, ~, ~, ~, T_3c, Y_3c] = full_dose_driver_3C(patient, TimeLen, Interval, fixed, Dose);
figure
plot(T_2c/7, Y_2c(:, 1), T_3c/7, Y_3c(:, 1))
legend('2C model', '3C model')
title('Comparison of Response with 10mg/kg Dosing Method')
xlabel('Time, weeks')
ylabel('Concentration, mg/L')

%% Typical profile for 2C models--10mg/kg Q3W
% Generate Time-Concentration profile of central compartment for 2C models with 7 schemes: 5
% retake, 1 miss and 1 full
load('Patients_2C.mat');
pID = round(rand(1)*1000);
patient = patient_weight_ALB(pID);
dosing_method = 2;
[Interval, Dose, fixed, dose_name] = dose_regime(dosing_method, patient);
%Drivers
[~, ~, ~, T_full_2C, Y_full_2C] = full_dose_driver_2C(patient, TimeLen, Interval, fixed, Dose);
[~, ~, ~, T_miss_2C, Y_miss_2C] = missed_dose_driver_2C(patient, TimeLen, Interval, fixed, Dose);
Y_full_2C = Y_full_2C(:, 1);
Y_miss_2C = Y_miss_2C(:, 1);
T_retake_2C = [];
Y_retake_2C = [];
for retake_time = 1:5
    [~, ~, ~, T_temp, Y_temp] = retaken_dose_driver_2C(patient, TimeLen, Interval, fixed, Dose, retake_time);
    T_retake_2C = [T_retake_2C, T_temp(:, 1)];
    Y_retake_2C = [Y_retake_2C, Y_temp(:, 1)];
end
save('data/2C_T.mat', 'T_full_2C', 'T_miss_2C', 'T_retake_2C');
save('data/2C_Y.mat', 'Y_full_2C', 'Y_miss_2C', 'Y_retake_2C');

%% Typical profile for 3C models--10mg/kg Q3W
% Generate Time-Concentration profile of central compartment for 2C models with 7 schemes: 5
% retake, 1 miss and 1 full
load('Patients_3C.mat');
patient = patient_weight_ALB(pID); %Same pID as 2C
dosing_method = 2;
[Interval, Dose, fixed, dose_name] = dose_regime(dosing_method, patient);
[~, ~, ~, ~, ~, T_full_3C, Y_full_3C] = full_dose_driver_3C(patient, TimeLen, Interval, fixed, Dose);
[~, ~, ~, ~, ~, T_miss_3C, Y_miss_3C] = missed_dose_driver_3C(patient, TimeLen, Interval, fixed, Dose);
Y_full_3C = [Y_full_3C(:, 1), Y_full_3C(:, 5) ./ (Y_full_3C(:, 5) + Y_full_3C(:, 6)) * 100, Y_full_3C(:, 7)];
Y_miss_3C = [Y_miss_3C(:, 1), Y_miss_3C(:, 5) ./ (Y_miss_3C(:, 5) + Y_miss_3C(:, 6)) * 100, Y_miss_3C(:, 7)];
T_retake_3C = [];
Y_retake_3C = [];
for retake_time = 1:5
    [~, ~, ~, ~, ~, T_temp, Y_temp] = retaken_dose_driver_3C(patient, TimeLen, Interval, fixed, Dose, retake_time);
    T_retake_3C = [T_retake_3C, T_temp(:, 1)];
    Y_retake_3C = [Y_retake_3C, Y_temp(:, 1), Y_temp(:, 5) ./ (Y_temp(:, 5) + Y_temp(:, 6)) * 100, Y_temp(:, 7)];
end
save('data/3C_T.mat', 'T_full_3C', 'T_miss_3C', 'T_retake_3C');
save('data/3C_Y.mat', 'Y_full_3C', 'Y_miss_3C', 'Y_retake_3C');
