import excel using "C:\Users\\`c(username)'\Desktop\replace_cols.xlsx", firstrow clear

format correct_compound_id idx200b_compd_id %25.0g
foreach strvar in correct_compound_id idx200b_compd_id {
	gen `strvar'_ = string(`strvar', "%25.0g")
	order `strvar'_, after(`strvar')
	drop `strvar'
	rename `strvar'_  `strvar'
}

foreach var of varlist idx200b_compd_id {
	gen `var'_ = substr(`var', 1, 5)
	gen `var'_e =substr(`var', 6, 6+5)
	replace `var'_ = substr(correct_compound_id, 1,5)
	replace `var' = `var'_ + `var'_e 
	drop `var'_e `var'_
}
