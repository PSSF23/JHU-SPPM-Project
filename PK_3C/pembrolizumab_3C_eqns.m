function dydt = pembrolizumab_3C_eqns(t, y, p)

% Pre-parameters
cl = p.cl;
v1 = p.v1;
v2 = p.v2;
Q = p.Q;
Qt = p.Qt;
kdeg = p.kdeg;
kon = p.kon; % /nM-day
koff = p.koff; % 1/day
Emaxtp = p.Emaxtp;
EC50tp = p.EC50tp;
P0 = p.P0; %nM
vis0 = p.vt0 * 0.55 / 10^6; % L
L0 = p.L0;
gamma = p.gamma; % Drug effect term
SLtg = p.SLtg; % Slope of drug on tumor growth rate 1/day
kdegD = p.kdegD; % Drug degradation to cross endosomal space into tumor

% Calculate parameters
kcl = cl / v1; % 1/day
k12 = Q / v1; % 1/day
k21 = Q / v2; % 1/day
k1t = Qt / v1; % 1/day
vis = 0.55 * y(7) / 10^6; % Interstitial volume L
kt1 = Qt / vis; % 1/day
kprod = kdeg * (1 + Emaxtp * (y(5) / (EC50tp + y(5))));
ROt = 100 * y(5) / (y(5) + y(6));
DE = SLtg * ROt;
if ROt > 0.01
    DE = SLtg * ROt^gamma; % Avoid too small DE
end

% Constants
MW = 149000 * 1000 / 10^9; % mg/nmol

dydt = zeros(9, 1);

% 1 = pembrolizumab in central (mg/L);
% 2 = pembrolizumab in peripheral (mg/L);
% 3 = pembrolizumab in clearance (mg/L);
% 4 = pembrolizumab in tumor interstitial volume (Note: nM);
% 5 = complex of pembrolizumab:PD1 in tumor interstitial volume (nM);
% 6 = PD1 in tumor interstitial volume (nM);
% 7 = Tumor volume (mm^3);
% 8 = pembrolizumab in tumor clearance (mg) (complex degradation is also included);
% 9 = current Drug in tumor compartment (mg) (pembrolizumab + pembrolizumab:PD1 complex)

dydt(1) = k21 * y(2) / v1 * v2 - k12 * y(1) - kcl * y(1) + ...
    kt1 * y(4) * MW * vis / v1 - k1t * y(1);
dydt(2) = -k21 * y(2) + k12 * y(1) / v2 * v1;
dydt(3) = kcl * y(1);
dydt(4) = k1t * y(1) / MW * v1 / vis - kt1 * y(4) - kon * y(4) * y(6) + ...
    koff * y(5) - kdegD * y(4);
dydt(5) = kon * y(4) * y(6) - koff * y(5) - kdeg * y(5);
dydt(6) = kprod * P0 * vis0 / vis - kdeg * y(6) - ...
    kon * y(4) * y(6) + koff * y(5);
dydt(7) = L0 * y(7) - DE * y(7);
dydt(8) = kdegD * y(4) * MW * vis + kdeg * y(5) * MW * vis;
dydt(9) = (dydt(4) + dydt(5)) * MW * vis;
