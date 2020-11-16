loc evanston 0

if "`c(username)'"=="nate3" {
	loc dir "C:/Users/nate3/Dropbox/Shopping" // Directory where stored
	loc name_disp "Nate" // Name exported
	loc name_sect nate // If sharing with someone, the order in the "section_guide" tab to sort on
}

if "`c(username)'"=="nate3" & "`evanston'"=="1" {	
	loc dir "C:/Users/nate3/Dropbox/Shopping"
	loc name_disp "Jill"
	loc name_sect jill
}


else if "`c(username)'"=="jillianjordan" {
	loc dir "/Users/jillianjordan/Dropbox/Shopping"
	loc name_disp "Jill"
	loc name_sect jill
}



* First, defining section order
import excel using "`dir'//Grocery List.xlsx", ///
	sheet("section_guide") first clear

sort `name_sect'_order
	
keep section `name_sect'_order

qui count
loc section_count = `r(N)'

forvalues i = 1/`section_count' {
	loc sect = section[`i']
	loc sections "`sections' `sect'"
}
di "`sections'"


* Now, pulling in recipe list

import excel using "`dir'//Grocery List.xlsx", ///
	sheet("recipe_list") first clear

keep if making>0 & !mi(making)

levelsof recipe, loc(recipes) clean
di "`recipes'"

* Creating quantities of each recipe to make
loc recipe_amt ""

foreach recipe in `recipes' {
	qui sum making if recipe=="`recipe'"
	loc q = `r(mean)'
	loc recipe_amt "`recipe_amt' `q'"
}




* Pulling in misc recipes
import excel using "`dir'//Grocery List.xlsx", ///
	sheet("misc_food") first clear

keep if qty!=0 & !mi(qty)
tempfile misc
save `misc'



* Pulling in the "always buy"
import excel using "`dir'//Grocery List.xlsx", ///
	sheet("food_in_recipes") first clear

tempfile full
save `full'

keep if buy=="always"	
	
loc recipe_use ""
foreach var in `recipes' {
	cap confirm variable `var'
	if _rc!=111 {
		loc recipe_use "`recipe_use' `var'"
	}
}


* Scaling up if multiple versions of a recipe are called for
loc recipe_count: word count `recipes'
forvalues i = 1/`recipe_count' {
	loc var: word `i' of `recipes'
	loc qty: word `i' of `recipe_amt'
	if `qty'!=1 {
		replace `var' = `var' * `qty'
	}
}



keep food_item tjs_section `recipe_use'



qui ds food_item tjs_section, not
loc food_vars `r(varlist)'
egen qty = rowtotal(`food_vars')
drop if qty==0

keep food_item tjs_section qty

append using `misc'

gen tjs_sort = .
forvalues i = 1/`section_count' {
	loc section: word `i' of `sections'
	replace tjs_sort = `i' if tjs_section=="`section'"
}

sort tjs_sort

tempfile list
save `list'



* Now pulling in the sometimes buy
use `full'
keep if buy=="sometimes"

loc recipe_use ""
foreach var in `recipes' {
	cap confirm variable `var'
	if _rc!=111 {
		loc recipe_use "`recipe_use' `var'"
	}
}
keep food_item tjs_section house_place `recipe_use'
	

qui ds food_item tjs_section house_place, not
loc food_vars `r(varlist)'
egen qty = rowtotal(`food_vars')
drop if qty==0


qui count
loc n = `r(N)'
gen for_recipes = ""
gen for_count = 0

forvalues i = 1/`n' {
	foreach var in `recipe_use' {
		replace for_recipes = "For " + "`var'" if _n==`i' & !mi(`var'[`i']) & for_count[`i']==0
		replace for_recipes = for_recipes + ", " + "`var'" if _n==`i' & !mi(`var'[`i']) & for_count[`i']!=0
		loc count = for_count[`i']
		replace for_count = `count' + 1 if _n==`i' & !mi(`var'[`i'])
	}
}
replace qty = 1

keep food_item qty tjs_section house_place for_recipes

gen tjs_sort = .


di `section_count'

forvalues i = 1/`section_count' {
	loc section: word `i' of `sections'
	replace tjs_sort = `i' if tjs_section=="`section'"
}

sort house_place
tempfile sometimes
save `sometimes'






* Now, making list of rarely replace
use `full'
keep if buy=="rarely"
	

loc recipe_use ""
foreach var in `recipes' {
	cap confirm variable `var'
	if _rc!=111 {
		loc recipe_use "`recipe_use' `var'"
	}
}
keep food_item tjs_section house_place `recipe_use'
	

qui ds food_item tjs_section house_place, not
loc food_vars `r(varlist)'
egen qty = rowtotal(`food_vars')
drop if qty==0


qui count
loc n = `r(N)'
gen for_recipes = ""
gen for_count = 0

forvalues i = 1/`n' {
	foreach var in `recipe_use' {
		replace for_recipes = "For " + "`var'" if _n==`i' & !mi(`var'[`i']) & for_count[`i']==0
		replace for_recipes = for_recipes + ", " + "`var'" if _n==`i' & !mi(`var'[`i']) & for_count[`i']!=0
		loc count = for_count[`i']
		replace for_count = `count' + 1 if _n==`i' & !mi(`var'[`i'])
	}
}

replace qty = 1

keep food_item qty tjs_section house_place for_recipes

gen tjs_sort = .
forvalues i = 1/`section_count' {
	loc section: word `i' of `sections'
	replace tjs_sort = `i' if tjs_section=="`section'"
}
sort house_place
tempfile rarely
save `rarely'

use `list', clear
qui count
loc ob = `r(N)' + 1
set obs `ob'


append using `sometimes'

qui count
loc ob = `r(N)' + 1
set obs `ob'


append using `rarely'

replace qty = round(qty, 0.01)

tostring qty, gen(qty_) force
drop qty
replace qty_ = substr(qty_, 1, 4) if length(qty_) > 4

sort house_place tjs_sort

loc exp_name "List - `name_disp'"
export excel qty food_item tjs_sort house_place for_recipes ///
	using "`dir'//`exp_name'.xlsx", replace firstrow(variables)


clear all
exit



