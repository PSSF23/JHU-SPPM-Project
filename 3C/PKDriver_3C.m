clear all;
close all;

%% PREPARE　POPULATIONS

load('PatientSims_100.mat')

%% RUN SIMULATIONS

Male = 1;
Female = 2;

SCENARIO = 1;
INPUT = "Weight";

switch INPUT
    case "Weight"
        for i = 1:length(Params)
            % 12W AUC, 4W AUC & C max
            [auc1(2*(i - 1)+Male), auc2(2*(i - 1)+Male), ...
                auc4w1(2*(i - 1)+Male), auc4w2(2*(i - 1)+Male), ...
                cmax1(2*(i - 1)+Male), cmax2(2*(i - 1)+Male)] = ...
                PKDrive_3C(Params(i, 1), 39.6, Male, SCENARIO);
            [auc1(2*(i - 1)+Female), auc2(2*(i - 1)+Female), ...
                auc4w1(2*(i - 1)+Female), auc4w2(2*(i - 1)+Female), ...
                cmax1(2*(i - 1)+Female), cmax2(2*(i - 1)+Female)] = ...
                PKDrive_3C(Params(i, 1), 39.6, Female, SCENARIO);
        end
        
    case "Albumin"
        for i = 1:length(Params)
            % 12W AUC, 4W AUC & C max
            [auc1(2*(i - 1)+Male), auc2(2*(i - 1)+Male), ...
                auc4w1(2*(i - 1)+Male), auc4w2(2*(i - 1)+Male), ...
                cmax1(2*(i - 1)+Male), cmax2(2*(i - 1)+Male)] = ...
                PKDrive_3C(76.8, Params(i, 2), Male, SCENARIO);
            [auc1(2*(i - 1)+Female), auc2(2*(i - 1)+Female), ...
                auc4w1(2*(i - 1)+Female), auc4w2(2*(i - 1)+Female), ...
                cmax1(2*(i - 1)+Female), cmax2(2*(i - 1)+Female)] = ...
                PKDrive_3C(76.8, Params(i, 2), Female, SCENARIO);
        end
end

auc1 = auc1';
auc2 = auc2';
auc4w1 = auc4w1';
auc4w2 = auc4w2';
cmax1 = cmax1';
cmax2 = cmax2';
name = sprintf('data/PKSen%d%s.mat', SCENARIO, INPUT);
save(name, 'auc1', 'auc2', 'auc4w1', 'auc4w2', 'cmax1', 'cmax2')
