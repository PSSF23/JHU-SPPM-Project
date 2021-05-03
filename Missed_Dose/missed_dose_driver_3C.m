function [AUC, Cmax, Ctrough, Tumor_ratio, Dcomplex_min, T, Y] = missed_dose_driver_3C(p, TimeLen, Interval, fixed, dose)

%% Simulation of missed dose at 2nd dose
% Returns AUC of central compartment at the end (Input should @12 weeks)
% Cmax and Ctrough of central compartment

% Parameters
TimeLen = TimeLen * 7; %Convert to days
Interval = Interval * 7; %Convert to days
NumDose = TimeLen / Interval;
q = dose;

if fixed == true && (dose ~= 200 && dose ~= 400)
    error('Fixed dose must have input 200mg or 400mg')
end


T = [];
Y = [];
Balance = [];
y0 = [q / p.v1, 0, 0, 0, 0, p.P0, p.vt0, 0, 0];

options = odeset('MaxStep', 5e-2, 'AbsTol', 1e-5, 'RelTol', 1e-5, 'InitialStep', 1e-2);
for i = 1:NumDose
    TStart = (i - 1) * Interval;
    TEnd = i * Interval;
    [Ttemp, Ytemp] = ode15s(@pembrolizumab_3C_eqns, [TStart:0.2:TEnd], y0, options, p);
    T = [T; Ttemp];
    Y = [Y; Ytemp];
    if i == 1
        y0 = Y(end, :);
    else
        y0 = Y(end, :) + [q / p.v1, 0, 0, 0, 0, 0, 0, 0, 0];
    end
    %     %Mass balance
    %     if i == 1
    %         DrugIn = q*i;
    %     else
    %         DrugIn = q*(i-1);
    %     end
    %     InitialDrug = 0;
    %     CurrentDrug = Ytemp(:,1)*p.v1+Ytemp(:,2)*p.v2...
    %         + Ytemp(:,9);
    %     DrugOut = Ytemp(:,3)*p.v1...
    %         + Ytemp(:,8); %Assume v3 = v1
    %     Balance =[Balance;DrugIn+InitialDrug-CurrentDrug-DrugOut];
end
AUC = trapz(T, Y(:, 1));
Cmax = max(Y(:, 1));
Ctrough = min(Y(10:end, 1));
Tumor_ratio = Y(end, 7) / Y(1, 7) - 1;
Dcomplex_min = min(Y(10:end, 5)./(Y(10:end, 5) + Y(10:end, 6))*100);
%plot(T,Balance) %debug
end
