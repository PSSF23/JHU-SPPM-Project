clear all;
close all;

%% PREPARE　POPULATIONS

load('2C/data/PatientSims.mat')

%% RUN SIMULATIONS

Male = 1;
Female = 2;

SCENARIO = 5;
INPUT = "Weight";

switch INPUT
    case "Weight"
        for i = 1:length(Params)
            [auc1(2*(i - 1)+Male), auc2(2*(i - 1)+Male)] = ...
                PKDrive_2C(Params(i, 1), 39.6, Male, SCENARIO);
            [auc1(2*(i - 1)+Female), auc2(2*(i - 1)+Female)] = ...
                PKDrive_2C(Params(i, 1), 39.6, Female, SCENARIO);
        end
        
    case "Albumin"
        for i = 1:length(Params)
            [auc1(2*(i - 1)+Male), auc2(2*(i - 1)+Male)] = ...
                PKDrive_2C(76.8, Params(i, 2), Male, SCENARIO);
            [auc1(2*(i - 1)+Female), auc2(2*(i - 1)+Female)] = ...
                PKDrive_2C(76.8, Params(i, 2), Female, SCENARIO);
        end
end

auc1 = auc1';
auc2 = auc2';
name = sprintf('2C/data/AUC12WSen%d%s.mat', SCENARIO, INPUT);
save(name, 'auc1', 'auc2')
