This is a readme for model validation/optimization and missed dose.

***Validation and Optimization***
The codes for this section is in the same folder as 'missed dose'.

1. First, we need to generate a patient population
	(1) Run patient_generator_2C.m and patient_generator_3C.m
2. To generate Figure 3
	(1) Skip this step if you don't want to tune the parameters. This Figure is mainly for debugging so not very user-friendly.
	Data is already generated in 'data' folder.
		a. Open Optimization_main.m, change dosing_method (line 18) to 2
		b. Change line 27 with correct filenames and run line 14-27.
		c. Repeat a and b with dosing_method = 1 or 3 (filename should be changed accordingly)
	(3) Run Typical_2C.R (remember to change working directory)
3. To generate Figure 4,5 and 6
	(1) Run Optimization_main.m with line 18: dosing_method  = 2


***Missed Dose Analysis***
Warning: the run time is around 2 hours for Step 2!!! The data is already generated in the 'data' folder.
All figures (31-36) or their alternatives can be found in the Shiny app (https://gary777.shinyapps.io/PKPD_FinalProject/ ).


1. Check that there is a folder named 'data' in the directory, and it contains only ~2.2MB data.
2. Run Main_missed_dose.m to generate data. (Please skip this if you don't want to spend more than 2 hours
	re-generating everything in the 'data' folder)
3. Open App.R and hit 'Run App' (remember to change working directory and make sure packages are installed)
4. To generate Figure 31
	(1) In Shiny app, choose 'Missed Dose 2C Results'--'Typical Concentration-Time Profile'
		then select '4/5 Interval' and 'miss'
5. Preparation for generating Figure 32-36
	(1) In App.R, run line 1-295
5. To generate Figure 32
	(1) In App.R, run line 65-74
6. To generate Figure 33
	(1) In App.R, run line 76-84
7. To generate Figure 34
	(1) In App.R, run line 86-94
8. To generate Figure 35
	(1) In App.R, run line 182-190
9. To generate Figure 36
	(1) In APp.R, run line 192-201
