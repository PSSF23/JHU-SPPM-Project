function p_post = PatientParam_2C(p)
%Update cl,v1,v2 and Q based on basic statistics: weight, sex, etc.
p_post = p;

% Define normal distributions
nd1 = makedist('Normal', 0, sqrt(0.134));
nd2 = makedist('Normal', 0, sqrt(0.0417));

% Calculate partial pre-parameters
cl = 0.202 * (p.weight / 76.8)^0.595 * (p.BSLD / 89.6)^0.0872 ...
    * (p.eGFR / 88.47)^0.135 * (p.ALB / 39.6)^-0.907 ...
    * exp(random(nd1));% L
v1 = 3.48 * (p.weight / 76.8)^0.489 * (p.ALB / 39.6)^-2.08 ...
    * exp(random(nd2));% L
v2 = 4.06 * (p.weight / 76.8)^0.489 * exp(random(nd2)); % L
Q = 0.795 * (p.weight / 76.8)^0.595 * exp(random(nd1)); % L/day

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

end
