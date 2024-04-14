capture program drop vlabel
program define vlabel
* label ascending values according to common separated list
syntax anything

local var="`1'"
capture confirm var `var'
if _rc~=0 {
   di in red "`var' not found"
   exit
}
levelsof `var' , local(vlevels)
local numvalues = wordcount("`vlevels'")
local foo=`numvalues'+2
if "``foo''"~="" {
   di in red "syntax error: too many labels specified. Use underscores instead of spaces"
}
capture label drop `var'
local j=1
foreach x in `vlevels' {
   local lab`++j' : subinstr local `j' "_" " " , all
   label define `var' `x' "`lab`j''"  , modify
}
label values `var' `var'
end

