*notes: .m =missing .o= other .d= dont know
	 notes : TS : .m =missing .o= other .d= dont know
	foreach var of varlist * {
		cap confirm str# var `var'
		if !_rc {
			replace `var' = "999" if `var' =="" |`var' =="."
			replace `var' = subinstr(`var', "-996", "other", .) 
			replace `var' = regexr(`var',"-999|999|-997|998|997|-998", "")
		}	
		else {
			replace `var'=999 if missing(`var')
			mvdecode `var', mv(999=.m \ -999=.m \ -997=.m \ 997=.m \ -996=.o \ 996=.o \ -998=.d \ 998=.d )
		} 
	} 