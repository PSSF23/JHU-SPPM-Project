function [Interval, dose, fixed, dose_name] = dose_regime(regime, patient)
switch regime
    case 1
        Interval = 3; %Q3 weeks
        dose = 2 * patient.weight;
        fixed = false;
        dose_name = '2mg_kg_Q3W';
    case 2
        Interval = 3;
        dose = 10 * patient.weight;
        fixed = false;
        dose_name = '10mg_kg_Q3W';
    case 3
        Interval = 2;
        dose = 10 * patient.weight;
        fixed = false;
        dose_name = '10mg_kg_Q2W';
    case 4
        Interval = 3;
        dose = 200;
        fixed = true;
        dose_name = '200mg_Q3W';
    case 5
        Interval = 6;
        dose = 400;
        fixed = true;
        dose_name = '400mg_Q6W';
end