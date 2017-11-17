								*Appending Many Data Files
set more off							
global wkdir 	"C:\Users\\`c(username)'\Desktop\dofiles\Stata-codes\Data"	
cd "$wkdir"	
*List files in the directory				
local fils: dir "$wkdir" files "*.csv"	
*save empty stata file
save full_data, emptyok replace
foreach dat_file of local fils {
	*Import files
	insheet using `dat_file', clear 
		foreach var of varlist * {
		*check for string vars
		cap confirm string var `var'
		if _rc {
			*rename rest of variables if not string
			local first_char = `var'[1]
			local new_name rain`first_char'
			ren `var' `new_name'
		}
	}
	drop in 1
	rename v1 month_day
	reshape long rain , i(month_day) j(year)
	gen date_var = month_day + "-" + string(year)
	drop month_day year
	
	gen date_var_ =date(date_var, "DMY")
	format date_var_ %td
	drop date_var
	rename date_var_ date_var
	gen day_of_year = doy(date_var)
	order 	date_var day_of_year
	append using full_data, force
}			
						