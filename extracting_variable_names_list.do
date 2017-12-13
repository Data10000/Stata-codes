//Extracting variables names list
sysuse auto
local var_list
foreach var_name of varlist * {
	local var_list `var_list' `var_name'
}
display "`var_list'"
local var_count : word count `var_list'
dis `var_count'

drop *
set obs `var_count'
gen variable_names = ""
forval var_pos = 1/`var_count' {
	replace  variable_names = word("`var_list'", `var_pos') in `var_pos'
}