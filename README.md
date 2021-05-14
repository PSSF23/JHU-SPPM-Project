# JHU-SPPM-Project
Project archive for the Systems Pharmacology & Personalized Medicine course at JHU during Spring 2021 Semester

## Model Validation and Optimization:
The code validation and optimization is in the same folder as 'missed dose'. Run the codes under this ‘missed dose’ folder.
1. First, generate a patient population
   1. Run patient_generator_2C.m and patient_generator_3C.m
2. To generate Figure 3:
   1. (Skip this step if you don't want to tune the parameters. This Figure is mainly for debugging so not very user-friendly. Data is already generated in the 'data' folder under ‘missed dose’.)
      1. Open Optimization_main.m, change dosing_method (line 18) to 2
      2. Change line 27 with correct [filename] and run line 14-27.
      3. Repeat i and ii with dosing_method = 1 or 3 (filename should be changed accordingly)
   2. Run Typical_2C.R (remember to change working directory)
3. To generate Figure 4, 5 and 6
   1. Run Optimization_main.m with line 18: dosing_method  = 2


## Sensitivity Analysis:
- https://julialu49.shinyapps.io/Sensitivity_Analysis_2C/
1. For 2C: Run SensitivityAnalysis_2C.m for local and global sensitivity analysis (3 different cases)
   1. Case 1: Run and get the local sensitivity for 2C model
   2. Case 2: Run and get global VS local sensitivity for 2C model
   3. Case 3: Run and get global sensitivity for 2C model
2. For 3C: Run SensitivityAnalysis_3C.m for local and global sensitivity analysis (2 different cases)
   1. Case 1: Run and get local sensitivity for 3C model
   2. Case 2: Run and get global sensitivity for 3C model
3. After running all the files, all data will be generated.  We have already put the data into the data folder for the conveniences.
4. Run app.R in folder “sensitivity” for interactive visualizations.
        All the figures in the document can be generated through shiny by selecting the     corresponding options.


## PK:
- https://pssf23.shinyapps.io/Pem-2C/
- https://pssf23.shinyapps.io/Pem-3C/
1. Use PatientSims.m to generate patient simulations or use PatientSims_1000.mat directly.
2. For 2C: Run PKDriver_2C.m for all 5 scenarios and 2 variations: Weight and Albumin.
3. For 3C: Run PKDriver_3C.m for all 5 scenarios and 2 variations: Weight and Albumin.
4. Run app.R in each folder for interactive visualizations.


## Missed Dose:
- https://gary777.shinyapps.io/PKPD_FinalProject/
Warning: the run time is around 2 hours for Step 2! The data is already generated in the 'data' folder under ‘missed dose’. Run the codes under this folder.
All figures (31-36) or their alternatives can be found in the Shiny app. The facet arrangements in the report are different from Shiny App due to visualization concerns. The steps below will replicate the figures used in the report.
1. Check that there is a folder named 'data' in the directory, and it contains 2.2MB data.
2. Run Main_missed_dose.m to generate data. (Please skip this if you don't want to spend hours regenerating everything in the 'data' folder)
3. Open App.R and hit 'Run App' (remember to change working directory and make sure packages are installed)
4. To generate Figure 31
   1. Run App.R. In Shiny app, choose 'Missed Dose 2C Results'--'Typical Concentration-Time Profile', then select '4/5 Interval' and 'miss'
5. Preparation for generating Figure 32-36
   1. In App.R, run line 1-295
6. To generate Figure 32
   1. In App.R, run line 65-74
7. To generate Figure 33
   1.  In App.R, run line 76-84
8. To generate Figure 34
   1. In App.R, run line 86-94
9. To generate Figure 35
   1.  In App.R, run line 182-190
10. To generate Figure 36
   1. In APp.R, run line 192-201
