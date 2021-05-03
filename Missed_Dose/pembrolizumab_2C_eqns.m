function dydt = pembrolizumab_eqns(t, y, p)

% Pre-parameters
cl = p.cl;
v1 = p.v1;
v2 = p.v2;
Q = p.Q;

% Calculate parameters
kcl = cl / v1; % 1/day
k12 = Q / v1; % 1/day
k21 = Q / v2; % 1/day

dydt = zeros(3, 1);

% 1 = pembrolizumab in central (mg/L);
% 2 = pembrolizumab in peripheral (mg/L);
% 3 = pembrolizumab in clearance (mg/L)

dydt(1) = k21 * y(2) / v1 * v2 - k12 * y(1) - kcl * y(1);
dydt(2) = -k21 * y(2) + k12 * y(1) / v2 * v1;
dydt(3) = kcl * y(1);
