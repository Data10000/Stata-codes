insheet using "C:\Users\\`c(username)'\Desktop\dofiles\Stata-codes\example.csv",names comma clear
keep personid visitdate maritalstatus
gen new_var = string(personid) +"." + maritalstatus
replace visitdate = substr(visitdate, 1, 11)
gen visitdate_ = date(visitdate, "YMD")
format visitdate_  %td
gsort -visitdate_

bysort new_var (visitdate): gen lower_date = visitdate[1]
bysort new_var (visitdate): gen upper_d = visitdate[_N]

gen group_var = "(" + lower_date +") "+ "- (" + upper_d +")"

drop lower_date upper_d visitdate visitdate_ new_var
duplicates drop