%% Description
% This code will fit the CL and Qt of 3C models to 2C models using several random
% patients, whose weight and albumin are varying. 10mg/kg Q3W will be used
% to fit the models.
% The cost function will be based on 
%% Global functions
TimeLen = 12;
%% Five dosing regimens:
% 2mg/kg Q3W
% 10mg/kg Q3W
% 10mg/kg Q2W
% 200mg Q3W
% 400mg Q6W
%% Generation of reference data using 2C model
load('Patients_3C.mat');
pID = round(rand(1)*1000);
patient = patient_weight_ALB(pID);
dosing_method = 2; %select from 1-5 the dosing method
[Interval, Dose, fixed,dose_name] = dose_regime(dosing_method,patient);
[~,~,~,T_full_2C,Y_full_2C] = full_dose_driver_2C(patient,TimeLen,Interval,fixed,Dose);
% Randomly select 100 points as experiment points
[texp,idt] = datasample(T_full_2C,20,'Replace',false);
yexp = Y_full_2C(idt,1);

%% Plot of 2C validation--Figure 3 (Optional)
% Change dosing methods at line 18 and run the codes:
% save data/[filename] T_full_2C Y_full_2C
% filename should be one of the three: 2mgQ3W.mat 10mgQ2W.mat 10mgQ3W.mat
%% Plot a comparison--Figure 4
[~,~,~,~,~,t,y] = full_dose_driver_3C(patient,TimeLen,Interval,fixed,Dose);
figure
plot(T_full_2C/7,Y_full_2C(:,1))
hold on
plot(t/7,y(:,1))
xlabel('Time, weeks')
ylabel('Concentration, mg/L')
title('Comparison of Response with 10mg/kg Dosing Method')
legend('2C Model', '3C Model')
%% Fit with lsqnonlin on CL
fun = @(x1)AUCcostfxnCL(x1,texp,yexp,patient,TimeLen,Interval,fixed,Dose);
x0 = 0.21; %Initial guess
optimal_CL = lsqnonlin(fun,x0,0,0.23);
%% Plot figures on CL fitting result
p = patient;
% p.cl = optimal_CL* (p.weight / 76.8)^0.595  ...
%     * (p.eGFR / 88.47)^0.135 * (p.ALB / 39.6)^-0.907;
p.cl = optimal_CL;
[~,~,~,~,~,t,y] = full_dose_driver_3C(p,TimeLen,Interval,fixed,Dose);
figure
plot(T_full_2C/7,Y_full_2C(:,1))
hold on
scatter(texp/7,yexp)
plot(t/7,y(:,1),'--')
xlabel('Time, weeks')
ylabel('Concentration, mg/L')
legend('2C','2C sampled','Optimized 3C')
title('Comparison of 3C (0 clearance) and 2C Models')
%% Fit with lsqnonlin on Qt
fun = @(x1)AUCcostfxnCL(x1,texp,yexp,patient,TimeLen,Interval,fixed,Dose);
x0 = 0.38; %Initial guess
optimal_Qt = lsqnonlin(fun,x0,0,0.38);
%% Plot figures on Qt fitting result
p = patient;
p.Qt = optimal_Qt;
[~,~,~,~,~,t,y] = full_dose_driver_3C(p,TimeLen,Interval,fixed,Dose);
figure
plot(T_full_2C/7,Y_full_2C(:,1),'LineWidth',1,'color','k')
hold on
scatter(texp/7,yexp)
plot(t/7,y(:,1),'--')
xlabel('Time, weeks')
ylabel('Concentration, mg/L')
legend('2C','2C sampled','Optimized 3C')
title('Comparison of 3C (0 Q_t) and 2C Models')