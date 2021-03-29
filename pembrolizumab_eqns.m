function dydt = pembrolizumab_eqns(t, y, p)

% Define normal distributions
nd1 = makedist('Normal', 0, 0.134);
nd2 = makedist('Normal', 0, 0.0417);

% Calculate partial pre-parameters
cl = 0.202 * (p.weight / 76.8)^0.595 * (p.BSLD / 89.6)^0.0872 ...
    * (p.eGFR / 88.47)^0.135 * (p.ALB / 39.6)^-0.907 ...
    * exp(random(nd1));% L
v1 = 3.48 * (p.weight / 76.8)^0.489 * (p.ALB / 39.6)^-208 ...
    * exp(random(nd2));% L
v2 = 4.06 * (p.weight / 76.8)^0.489 * exp(random(nd2)); % L
q = 0.795 * (p.weight / 76.8)^0.595 * exp(random(nd1)); % L/hr

% Complete pre-parameters by conditions
if p.sex == 2
    cl = cl * (1 - 0.152);
    v1 = v1 * (1 - 0.134);
end

if p.NSCLC == 1
    cl = cl * (1 + 0.145);
end

if p.ECOGPS == 0
    cl = cl * (1 - 0.0739);
end

if p.IPI == 1
    cl = cl * (1 + 0.140);
    v1 = v1 * (1 + 0.0737);
end

% Calculate parameters
kcl = cl / v1; % 1/hr
k12 = q / v1; % 1/hr
k21 = q / v2; % 1/hr


dydt = zeros(3, 1);

% 1 = pembrolizumab in central (mg/L);
% 2 = pembrolizumab in peripheral (mg/L);
% 3 = pembrolizumab in clearance (mg/L)

dydt(1) = k21 * y(2) / v1 * v2 - k12 * y(1) - kcl * y(1);
dydt(2) = -k21 * y(2) + k12 * y(1) / v2 * v1;
dydt(3) = kcl * y(1);
