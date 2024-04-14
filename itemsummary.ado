* ITEMSUMMARY
* 6 16 2007
* Prepares a table of items by response option

program define itemsummary
syntax varlist [if] [in] [ , p ]

*** find the right name for the tex file
local fn "itemsummary.tex"

qui {
   preserve
   marksample touse , novarlist
   keep if `touse'   
   * for tex
   tempname f
   file open `f' using "`fn'" , replace write
   keep `varlist'
   local i=1
   foreach var of varlist `varlist' {
      capture confirm numeric v `var'
      if _rc==0 {
         local vrl`i' : variable label `var'
         *noisily di in red "vrl`i' is `vrl`i''"
         rename `var' _y`i'
         local lab`i' = "`var'"
         local i = `i'+1
      }
      else {
         noisily di in yellow "`var'" in green " is a string and not included"
      }
   }
   local i = `i'-1
   gen i=_n
   reshape long _y , i(i) j(item)
   gen n=1
   collapse (count) n , by(item _y)
   gen _ylab=string(item)
   foreach i of numlist 1/`i' {
      local zero=""
      if `i'<10 {
         local zero="0"
      }
      local ylab = itrim(trim("`zero'`i' `lab`i'' `vrl`i''"))
      local l=length("`ylab'")
      if `l'<50 {
         local s=50-`l'
         local tab = ""
         foreach t of numlist 1/`s' {
            local tab = "`tab'"+"."
         }
         local ylab = "`ylab'`tab'"
      }
      else if `l'>=50 {
         local ylab = substr("`ylab'",1,50)
      }
      replace _ylab = "`ylab'" if item==`i'
   }
   replace _y=99 if _y==.
   rename item itemnum
   rename _ylab item
   label define y 99 "."
   label values _y y 
   label variable _y "Response"

   if "`p'"=="" {
      di in green ""
      noisily di "Item Response Frequency (entries are counts)"
      noisily table item _y , c(sum n) col
      file write `f' "\begin{center}" _n 
      file write `f' "{\bf Item Response Frequency} (entries are counts)\\ " _n
      file write `f' "\end{center}"_n
   }
   if "`p'" =="p" {
      gsort item -_y
      by item: gen sum=sum(n)
      sort item _y
      qui by item: replace sum=sum[_n-1] if _n~=1
      qui replace n=round(n/sum*100,1)
      di in green ""
      noisily di "Item Response Frequency (entries are percentages)"
      noisily table item _y , c(mean n) format(%3.0f)
      file write `f' "\begin{center}" _n 
      file write `f' "{\bf Item Response Frequency} (entries are percentages)\\ " _n
      file write `f' "\end{center}"_n
   }
   * tex stuff
   levelsof _y , local(ylevels)
   *noisily di in red "ylevels is `ylevels'"
   levelsof itemnum , local(itemlevels)
   *noisily di in red "itemlevels is `itemlevels'"
   local y =wordcount("`ylevels'") 
   local j =wordcount("`itemlevels'") 
   *noisily di in red "y is `y'"
   *noisily di in red "j is `j'"
   local z=`y'+1
   local foo "\begin{longtable}{l"
   local goo "Item "
   forvalues i=1/`y' {
      local foo "`foo' r"                  // column format
      local hoo : word `i' of `ylevels'   // y category value
      local goo "`goo' & `hoo' "           // put it in the title
   }
   file write `f' "`foo' r} " _n
   file write `f' " & \multicolumn{`y'}{c}{Responses} \\ "_n
   *local a=`y'+2
   file write `f' "\cline{2-`z'}" _n
   file write `f' "`goo' & Total \\ " _n
   file write `f' "\hline" _n
   forvalues r=1/`j' {
      *local ioo : label item `r'
      file write `f' "`lab`r'': `vrl`r''"
      foreach c in `ylevels' joo {
         if "`c'"~="joo" {
            qui su n if itemnum==`r' & _y==`c' , detail
            file write `f' "& `r(sum)'"
         }
         if "`c'"=="joo" {
            qui su n if itemnum==`r' , detail
            file write `f' "& `r(sum)' \\" _n
         }
      }
   }
   file write `f' "\hline"_n
   file write `f' "\end{longtable}" _n

   restore
   file close `f'
   
} // close qui

di _n "(`fn' saved to `c(pwd)')" _n _n

end


