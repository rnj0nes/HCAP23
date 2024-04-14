* change all variables to lower case
* Rich Jones
* 9OCT2008
capture program drop lowercase
program define lowercase
foreach var of varlist _all {
   local nn=lower("`var'")
   if "`var'"~="`nn'" {
      capture rename `var' `nn'
   }
}
end
