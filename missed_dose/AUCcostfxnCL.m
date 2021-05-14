function AUCcostout = AUCcostfxnCL(x1, texp, yexp, p, TimeLen, Interval, fixed, Dose)
% Calculate partial pre-parameters
p.cl = x1 * (p.weight / 76.8)^0.595 ...
    * (p.eGFR / 88.47)^0.135 * (p.ALB / 39.6)^-0.907;

[~, ~, ~, ~, ~, t, y] = full_dose_driver_3C(p, TimeLen, Interval, fixed, Dose);
y = y(:, 1);

for j = 1:length(texp)
    teval = abs(t-texp(j));
    [~, tindex] = min(teval);
    AUCcostout(j) = y(tindex) - yexp(j);
end

end
