*Extracting the last character of string
	sysuse auto, clear
	rename * =_ml_ // for suffix but this can be achieved by  	rename * _ml_= for prefix
	tempfile auto_data
	save `auto_data'
*Using  regexr
	foreach var of varlist *{
		local new_name = regexr("`var'", "_$", "")
		rename `var' `new_name'
	}

*Using regexm	
foreach var of varlist * {
	if regexm("`var'", "_ml$"){
		local new_name = subinstr( "`var'", "_ml","", 1)
	    rename `var' `new_name'
	}
}

use `auto_data', clear

*Extracting upto second last character
foreach var of varlist * {
	local new_var = substr("`var'", 1,length("`var'")-1)
	rename `var' `new_var'
	
} 

*Using regexs

foreach var of varlist * {
	gen `var'_ = regexs(0) if regexm("`var'", ".*[^\_ml$]") 
	local new_name =`var'_[1]
	rename `var' `new_name' 
	drop `var'_ 
}

*Group renaming
ren *1 *2

