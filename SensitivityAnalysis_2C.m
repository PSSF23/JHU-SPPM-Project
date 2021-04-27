clear all
close all
clc


%% KEY SIMULATION PARAMETERS
flag=3;
% 1 = local univariate sensitivity analysis 
% 2 = local paramter vs global albumin and weight 
% 3 = 2 dimensional global sensitivity analysis 


% In this sensitivity analysis for our 2-compartment model, we want look at
% 8 different parameters and 5 dosing methods 
% 
%% Average Patient statistics

% Model parameters for array p base values 
p.weight = 76.8;
p.sex = 1;
p.NSCLC = 0;
p.ECOGPS = 0;
p.IPI = 1;
p.eGFR = 88.47; %estimated glomerular filtration rate 
p.ALB = 39.6;%albumin concentration 
p.BSLD = 89.6; %Baseline tumor burden 

%percent change of parameter
ParamDelta = 0.1;


% 2mg Q3W, weight-based dose every 3 weeks 
% 10mg Q2W, weight-based dose every 2 weeks
% 10mg Q3W, weight-based dose every 3 weeks
% 200mg Q3W, fixed dose every 3 weeks 
% 200mg Q6W, fixed dose every 6 weeks

TimeLen =12 * 7; % 12 weeks
% different dosing methods 
q = [(2*p.weight) (10*p.weight) (10*p.weight) 200 400]; % [2mg weight based; 10mg weight based; 200mg fixed dose]
% different doing frequencies

Interval = [3*7 2*7 3*7 3*7 6*7]; % Once every 2 or 3 weeks
p = PatientParam_2C_Sen(p); %Update Patient PK parameters.
params = {'cl','v1','v2','Q','weight','eGFR','ALB','BSLD'}; 
dosing = {'2mg Q3W', '10mg Q2W', '10mg Q3W','200mg Q3W','400mg Q6W'};


switch flag
    case 1
%% 1. SENSITIVITY - LOCAL UNIVARIATE

t = [];
y = [];

%% Calculate the base case 

for j = 1:5 %loop through 3 dosing methods  
    y0 = [q(j) / p.v1 0 0];
    [T,Ytemp, AUC4Wb(j), AUC12Wb(j), Cmaxb(j)] = Sen_Simulation(p,y0,TimeLen,Interval(j),q(j));
    y = [y Ytemp(:,1)];

end

t = [t T];


column_names = [];

for i=1:numel(params)
    for m = 1:5 % three dosing methods 
        pnew = p;
        pnew.(params{i})= p.(params{i}) * (1 + ParamDelta);
        if strcmp(params {i}, 'weight') || strcmp(params {i}, 'eGFR') || strcmp(params {i},'ALB')|| strcmp(params {i}, 'BSLD')     
            pnew = PatientParam_2C_Sen(pnew); %Update Patient PK parameters.
        end
        qnew = [(2*pnew.weight) (10*pnew.weight) (10*pnew.weight) 200 400];% [2mg weight based; 10mg weight based; 200mg fixed dose]
        y0 = [qnew(m) / pnew.v1 0 0];
        [ttemp, ytemp, AUC4W(i,m), AUC12W(i,m), Cmax(i,m)] = Sen_Simulation(pnew,y0,TimeLen,Interval(m),qnew(m));
        y = [y ytemp(:,1)];
        Sens_AUC4W(i,m) = ((AUC4W(i,m)-AUC4Wb(m))/AUC4Wb(m))/ ParamDelta ; 
        Sens_AUC12W(i,m) = ((AUC12W(i,m)-AUC12Wb(m))/AUC12Wb(m))/ ParamDelta ;
        Sens_Cmax(i,m) = ((Cmax(i,m)-Cmaxb(m))/Cmaxb(m))/ ParamDelta ;
        column_names =[column_names strcat(params{i}, ", ", dosing{m})];
    end
 end
      
  
%save the sensitivity for AUC in first 4 weeks  
save Sens_AUC4W.mat Sens_AUC4W
%save the sensitivity for AUC in first 12 weeks     
save Sens_AUC12W.mat Sens_AUC12W
% save the sensitivity for Cmax
save Sens_Cmax.mat Sens_Cmax
% save all the data points 
save Sens_expdata.mat t y

   
    case 2
   %% 2. local paramter vs global Albumin and Weight
   
   Albumin = round(linspace(12,59,21),0); %define the range of albumin 
   Weight = round(linspace(40,90,21),0);
   Sensg_AUC4W_A = [];
   Sensg_AUC12W_A = [];
   Sensg_Cmax_A = [];
   column_names = [];
   ParamDelta = 0.05;
   
   
for j = 1:5   % loop through 5 different methods 
% Local parameter VS Albumin   
    for i = 1: length(Albumin) %21 values
        %base case 
        pnew = p;
        pnew.ALB = Albumin(i);
        pnew = PatientParam_2C_Sen(pnew);
        y0 = [q(j) / pnew.v1 0 0];
        [~,~, AUC4Wb(i), AUC12Wb(i), Cmaxb(i)] = Sen_Simulation(pnew,y0,TimeLen,Interval(j),q(j));
        %change the parameterss with 5%
        for k = 1: numel(params) % 8 parameters 
            pnew.(params{k})= p.(params{k}) * (1 + ParamDelta);
            if strcmp(params {k}, 'weight') || strcmp(params {k}, 'eGFR') || strcmp(params {k},'ALB')|| strcmp(params {k}, 'BSLD')     
                pnew = PatientParam_2C_Sen(pnew); %Update Patient PK parameters.
            end
        qnew = [(2*pnew.weight) (10*pnew.weight) (10*pnew.weight) 200 400];% [2mg weight based; 10mg weight based; 200mg fixed dose]
        y0 = [qnew(j) / pnew.v1 0 0];
        [~, ~, AUC4W(i,k), AUC12W(i,k), Cmax(i,k)] = Sen_Simulation(pnew,y0,TimeLen,Interval(j),qnew(j)); 
        Senst_AUC4W(i,k) = ((AUC4W(i,k)-AUC4Wb(i))/AUC4Wb(i))/ ParamDelta ; 
        Senst_AUC12W(i,k) = ((AUC12W(i,k)-AUC12Wb(i))/AUC12Wb(i))/ ParamDelta ;
        Senst_Cmax(i,k) = ((Cmax(i,k)-Cmaxb(i))/Cmaxb(i))/ ParamDelta ;
        column_namest(k) =[strcat(string(params{k}), ", ", dosing{j})];
        end
    end
   column_names = [column_names column_namest]
   Sensg_AUC4W_A = [Sensg_AUC4W_A Senst_AUC4W];
   Sensg_AUC12W_A = [Sensg_AUC12W_A Senst_AUC12W];
   Sensg_Cmax_A = [Sensg_Cmax_A Senst_Cmax];
   

end 
% 
Sensg_AUC4W_W = [];
Sensg_AUC12W_W = [];
Sensg_Cmax_W = [];
for j = 1:5   % loop through 5 different methods 
% Local parameter VS weight 
    for i = 1: length(Weight) %21 values
        %base case 
        pnew = p;
        pnew.weight = Weight(i);
        pnew = PatientParam_2C_Sen(pnew);
        y0 = [q(j) / pnew.v1 0 0];
        [~,~, AUC4Wb(i), AUC12Wb(i), Cmaxb(i)] = Sen_Simulation(pnew,y0,TimeLen,Interval(j),q(j));
        %change the parameterss with 10%
        for k = 1: numel(params) % 8 parameters 
            pnew.(params{k})= p.(params{k}) * (1 + ParamDelta);
            if strcmp(params {k}, 'weight') || strcmp(params {k}, 'eGFR') || strcmp(params {k},'ALB')|| strcmp(params {k}, 'BSLD')     
                pnew = PatientParam_2C_Sen(pnew); %Update Patient PK parameters.
            end
        qnew = [(2*pnew.weight) (10*pnew.weight) (10*pnew.weight) 200 400];% [2mg weight based; 10mg weight based; 200mg fixed dose]
        y0 = [qnew(j) / pnew.v1 0 0];
        [~, ~, AUC4W(i,k), AUC12W(i,k), Cmax(i,k)] = Sen_Simulation(pnew,y0,TimeLen,Interval(j),qnew(j)); 
        Senst_AUC4W(i,k) = ((AUC4W(i,k)-AUC4Wb(i))/AUC4Wb(i))/ ParamDelta ; 
        Senst_AUC12W(i,k) = ((AUC12W(i,k)-AUC12Wb(i))/AUC12Wb(i))/ ParamDelta ;
        Senst_Cmax(i,k) = ((Cmax(i,k)-Cmaxb(i))/Cmaxb(i))/ ParamDelta ;
        end    
    end
   
   Sensg_AUC4W_W = [Sensg_AUC4W_W Senst_AUC4W];
   Sensg_AUC12W_W = [Sensg_AUC12W_W Senst_AUC12W];
   Sensg_Cmax_W = [Sensg_Cmax_W Senst_Cmax];
   

end 

%save the sensitivity for AUC in first 4 weeks  
save Sensg_AUC4W_A.mat Sensg_AUC4W_A
%save the sensitivity for AUC in first 12 weeks     
save Sensg_AUC12W_A.mat Sensg_AUC12W_A
% save the sensitivity for Cmax
save Sensg_Cmax_A.mat Sensg_Cmax_A

%save the sensitivity for AUC in first 4 weeks  
save Sensg_AUC4W_W.mat Sensg_AUC4W_W
%save the sensitivity for AUC in first 12 weeks     
save Sensg_AUC12W_W.mat Sensg_AUC12W_W
% save the sensitivity for Cmax
save Sensg_Cmax_W.mat Sensg_Cmax_W

    case 3
        
%% 3. two-dimensional global sensitivity analysis for Albumin X Weight 

Albumin = round(linspace(12,59,21),0); %define the range of albumin g/L
Weight = round(linspace(40,90,21),0); %define the range of weight kg
AUC4W_g = [];
AUC12W_g = [];
Cmax_g = [];
column_names = [];

for j = 1:5   % loop through 5 different methods 
% Local parameter VS Albumin   
    for i = 1: length(Albumin) %loop with 21 values of albumin 
        %loop with 21 values of weight 
        for k = 1 : length (Weight)
            pnew = p;
            pnew.ALB = Albumin(i);
            pnew.weight = Weight(k);
            pnew = PatientParam_2C_Sen(pnew);
            qnew = [(2*pnew.weight) (10*pnew.weight) (10*pnew.weight) 200 400];% [2mg weight based; 10mg weight based; 200mg fixed dose]
            y0 = [qnew(j) / pnew.v1 0 0];
            [~, ~, AUC4Wgt(k,i), AUC12Wgt(k,i), Cmaxgt(k,i)] = Sen_Simulation(pnew,y0,TimeLen,Interval(j),qnew(j)); 
        end
        column_names = [column_names strcat(string(Albumin(i)), ", ", dosing{j})];
    end
   
   AUC4W_g = [AUC4W_g AUC4Wgt];
   AUC12W_g = [AUC12W_g AUC12Wgt];
   Cmax_g = [Cmax_g  Cmaxgt];
   

end 


%save global sensitivity outcome for AUC in first 4 weeks  
save AUC4W_g.mat AUC4W_g
%save global sensitivity outcome for AUC in first 12 weeks     
save AUC12W_g.mat AUC12W_g
%save global sensitivity for Cmax 
save Cmax_g.mat  Cmax_g




end