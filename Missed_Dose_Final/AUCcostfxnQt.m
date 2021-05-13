function AUCcostout = AUCcostfxnQt(x1,texp,yexp,p,TimeLen,Interval,fixed,Dose)
% Calculate partial pre-parameters
p.Qt = x1;

[~,~,~,~,~,t,y] = full_dose_driver_3C(p,TimeLen,Interval,fixed,Dose);
y = y(:,1);

        for j=1:length(texp)
            teval = abs(t-texp(j));
            [~, tindex] = min(teval);
            AUCcostout(j) = y(tindex) - yexp(j);
        end

end