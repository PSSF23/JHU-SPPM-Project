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
            % 12W AUC, C max, tumor volume change ratio & complex C max
            [auc(2*(i - 1)+Male), cmax(2*(i - 1)+Male), ...
                tvcr(2*(i - 1)+Male), ccmax(2*(i - 1)+Male)] = ...
                PKDrive_3C(Params(i, 1), 39.6, Male, SCENARIO);
            [auc(2*(i - 1)+Female), cmax(2*(i - 1)+Female), ...
                tvcr(2*(i - 1)+Female), ccmax(2*(i - 1)+Female)] = ...
                PKDrive_3C(Params(i, 1), 39.6, Female, SCENARIO);
        end
        
    case "Albumin"
        for i = 1:length(Params)
            % 12W AUC, C max, tumor volume change ratio & complex C max
            [auc(2*(i - 1)+Male), cmax(2*(i - 1)+Male), ...
                tvcr(2*(i - 1)+Male), ccmax(2*(i - 1)+Male)] = ...
                PKDrive_3C(76.8, Params(i, 2), Male, SCENARIO);
            [auc(2*(i - 1)+Female), cmax(2*(i - 1)+Female), ...
                tvcr(2*(i - 1)+Female), ccmax(2*(i - 1)+Female)] = ...
                PKDrive_3C(76.8, Params(i, 2), Female, SCENARIO);
        end
end

auc = auc';
cmax = cmax';
tvcr = tvcr';
ccmax = ccmax';
name = sprintf('data/PKSen%d%s.mat', SCENARIO, INPUT);
save(name, 'auc', 'cmax', 'tvcr', 'ccmax')
