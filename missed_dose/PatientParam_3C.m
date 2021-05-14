function p_post = PatientParam_3C(p)
%Update cl,v1,v2 and Q based on basic statistics: weight, sex, etc.
p_post = p;

% Define normal distributions
nd1 = makedist('Normal', 0, sqrt(0.134));
nd2 = makedist('Normal', 0, sqrt(0.0417));
nd3 = makedist('Normal', 0, sqrt(0.05)); % L0 random

% Constants
AV = 6.0221415 * 10^23; % Avrogadro's number

% Calculate partial pre-parameters
cl = 0.202 * (p.weight / 76.8)^0.595 ...
    * (p.eGFR / 88.47)^0.135 * (p.ALB / 39.6)^-0.907 ...
    * exp(random(nd1));% L
v1 = 3.48 * (p.weight / 76.8)^0.489 * (p.ALB / 39.6)^-2.08 ...
    * exp(random(nd2));% L
v2 = 4.06 * (p.weight / 76.8)^0.489 * exp(random(nd2)); % L
Q = 0.795 * (p.weight / 76.8)^0.595 * exp(random(nd1)); % L/day
kdeg = 0.0194 * (p.weight * 1000 / 20)^-0.25 * 24; % 1/day
Tmulti = p.Tmulti * 1000 / (p.NTc * p.PercT_PD1);
P0 = Tmulti * (p.NTc * 10^6 * p.PercT_PD1 * p.PD1Tc) / AV * 10^9; % Inital PD1 Concentration nM
vt0 = 4 / 3 * pi * (p.BSLD / 6)^3; % mm^3
switch p.L0Type
    case 'f'
        L0 = 0.0088 * exp(random(nd3));
    case 'i'
        L0 = 0.0036 * exp(random(nd3));
    case 's'
        L0 = 0.0017 * exp(random(nd3));
end
switch p.SLtgScale
    case 'weight'
        SLtg = 1.98 * 10^-5 * (p.weight * 1000 / 20)^-0.25;
    case 'L0'
        SLtg = 1.98 * 10^-5 * (L0 / 0.113);
end
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

% Update p_post
p_post.cl = cl;
p_post.v1 = v1;
p_post.v2 = v2;
p_post.Q = Q;
p_post.kdeg = kdeg;
p_post.P0 = P0;
p_post.vt0 = vt0;
p_post.L0 = L0;
p_post.SLtg = SLtg;
end
