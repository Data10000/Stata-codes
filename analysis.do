				/*  Analysis Script
					John Lunalo
					14 Oct, 2017
				*/

*Setting up
set more off 
log using  "F:\stata_git\practice\Stata-codes\task\dofiles\analysis_12.log", text replace
clear all

**********************Declaring directories to work from****************************************************************************************************************************
	#delimit ;
	global wkdir "F:\stata_git\practice\Stata-codes\task" ; global dofil "$wkdir\dofiles" ; global rawdata "$wkdir\raw_data" ; global adm "$wkdir\adm" ; global output "$wkdir\output" ;
	#delimit cr
	
**************************************************************Loading datasets******************************************************************************************************	
	*Structured
	insheet using "$rawdata\drinking.csv", names comma clear 
	duplicates tag partid, gen(dupid)
	export excel using "$output\list_of_duplicatesxlsx" if dupid, replace sheet("drinking") firstrow(var)
	#delimit ; 
	drop if dupid ; drop dupid ; tempfile drinking ; save `drinking' ;
	#delimit cr
	
	insheet using "$rawdata\behaviour.csv", names comma clear
	duplicates tag partid, gen(dupid)
	export excel using "$output\list_of_duplicatesxlsx" if dupid, sheetreplace sheet("behaviour") firstrow(var)
	drop if dupid
	drop dupid
	tempfile behaviour 
	save `behaviour'
	
	insheet using "$adm\p2_names.csv", names comma clear 
	tempfile names
	save `names' 
	
	use "$rawdata\13_version13",clear 
	duplicates tag partid, gen(dupid)
	export excel using "$output\list_of_duplicatesxlsx" if dupid, sheetreplace sheet("economic") firstrow(var)
	drop if dupid
	drop dupid
	tempfile economic 
	save `economic'
	
******************************Merge three datasets************************************************************************************************************************************
	use `drinking'
	merge 1:1 partid using `behaviour', gen(merge1)
	merge 1:1 partid using `economic' , gen(merge2)
	drop merge1 merge2
	count
	tempfile merged_surveyed_dataset
	save `merged_surveyed_dataset'

********************************************Add P2_names through merging**************************************************************************************************************
	merge 1:1 partid using `names'
	count
	tempfile merged_full_dataset
	save `merged_full_dataset'
	
****************************************Export surveyd and unsurveyed ids*************************************************************************************************************
	export excel partid username timestamp regneighborhood using "$output\surveyed_unsurveyed_obs.xlsx" if _merge==1, firstrow(var) replace sheet("not_surveyed")
	export excel partid username timestamp regneighborhood using "$output\surveyed_unsurveyed_obs.xlsx" if _merge==2, firstrow(var) sheetreplace sheet("surveyed")
	keep if _merge==3
	count //388
***********************************Dates Formating************************************************************************************************************************************
	*Generate enrollment_date
	local year_pos= strpos(timestamp, "2011")+3
	gen enrollment_date = date(substr(timestamp, 1,`year_pos'), "MDY")
	format enrollment_date %td
	order enrollment_date, after(timestamp)
		
	*Generate enrolment time 
	gen enrollment_time = Clock(timestamp, "MDYhm")
	format enrollment_time %tC
	order enrollment_time, after(enrollment_date)
	drop timestamp _merge
	
********************************Transform string variables to categorical*************************************************************************************************************
	qui ds, has(type str#)
	foreach strvar of varlist `r(varlist)' {
	#delimit ;  
	encode `strvar', gen(`strvar'_) ; order `strvar'_, after(`strvar') ; 	drop `strvar' ; rename `strvar'_ `strvar';
	#delimit cr
	}
*Save clean Data
	save "$output\clean_data", replace
	
**************************Analysis****************************************************************************************************************************************************
	bysort enrollment_date: gen number_of_surveys=_N
	gen surveyed_dates = string(enrollment_date, "%td")
	graph hbar number_of_surveys, over(surveyed_dates) title("Number of surveys per Enrollment Date")  ytitle("Number of Surveys") bar(1, col(green))
	graph export "$output\no_of_surveyed.pdf", replace
	
	gen hour_of_survey= hh(enrollment_time)
	bysort hour_of_survey: gen number_of_surveys_per_hour=_N
	tempfile clean_data_1
	save `clean_data_1'
	
	
	collapse (count) number_of_surveys_per_hour , by(hour_of_survey)
	export excel using "$output\hourly_summary.xlsx", replace  firstrow(var)
	use `clean_data_1', clear	
	
*************************************Creating Poverty Wealth Index*********************************************************************************************************************
	*Variables to be used
	keep walls roof floor watersource toilet ownhouse
	summ _all
	codebook, detail
	pca _all

	
	log close
	