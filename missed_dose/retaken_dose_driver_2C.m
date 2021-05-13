function [AUC, Cmax, Ctrough, T, Y] = retaken_dose_driver_2C(p,TimeLen,Interval,fixed, dose, retake_time)
%% Simulation of missed dose at 2nd dose but then retaken at specific time point later
% retake_time should be 1, 2, 3, 4 or 5 fifths of dosing interval
% Returns AUC of central compartment at the end (Input should @12 weeks)
% Cmax and Ctrough of central compartment

% Parameters
TimeLen = TimeLen*7; %Convert to days
Interval = Interval*7; %Convert to days
NumDose = TimeLen/Interval; 
q = dose;
if fixed == true && (dose ~= 200 &&dose  ~=400)
    error('Fixed dose must have input 200mg or 400mg')
end
if ismember(retake_time, 1:5) == false
    error('retake_time should be 1, 2, 3, 4 or 5 fifths of dosing interval')
end
retake_time = Interval*retake_time/5; %Retake of 2nd dose after this interval


T = []; Y = []; Balance = [];
y0 = [q/p.v1 0 0];

options = odeset('MaxStep',5e-2, 'AbsTol', 1e-5,'RelTol', 1e-5,'InitialStep', 1e-2);
for i = 1:NumDose
    if i == 1
       TEnd = i*Interval+retake_time; 
    else 
       TEnd = i*Interval;
    end
    if i == 2
       TStart = (i-1)*Interval+retake_time;
    else
       TStart = (i-1)*Interval;
    end
    if retake_time==Interval %when 2nd and 3rd dose taken together, simulate as if 2nd is missed
       TStart = (i-1)*Interval;
       TEnd = i*Interval;
    end
    [Ttemp,Ytemp] = ode15s(@pembrolizumab_2C_eqns,[TStart:0.1:TEnd],y0,options,p);
    T = [T;Ttemp];
    Y = [Y;Ytemp];
    
    if retake_time==Interval && i == 1
        y0 = Y(end,:);
    elseif retake_time==Interval && i==2
        y0 = Y(end,:)+[2*q/p.v1 0 0];
    else
        y0 = Y(end,:)+[q/p.v1 0 0];
    end
%     %Mass balance
%     DrugIn = q*i;
%     InitialDrug = 0;
%     CurrentDrug = Ytemp(:,1)*p.v1+Ytemp(:,2)*p.v2;
%     DrugOut = Ytemp(:,3)*p.v1; %Assume v3 = v1
%     Balance =[Balance;DrugIn+InitialDrug-CurrentDrug-DrugOut];
end
%plot(T/7,Y(:,1)) %debug
AUC = trapz(T,Y(:,1));
Cmax = max(Y(:,1));
Ctrough= min(Y(10:end,1));


end