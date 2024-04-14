* program for making sum scores, with standardization option
capture program drop scoreit 
program define scoreit , rclass
syntax anything [ if ] [in] ///
   [, Missinglist(string) f0 z t iq hz prorate ice meanimp] ///
   Gen(string) [Replace] [To(string)] [All] ///
   [reverse(string) prefix(string) suffix(string)] ///
   [indicator(string) minitems(string) ] ///
   [maxitemresponse(string) debug]
*syntax varlist [ if ] [in] [, Missinglist(string) z t iq hz ] Gen(string) [Replace] [To(string)] [All] [reverse(string)] 

qui {
   tempvar id
   gen `id'=_n
   capture drop _merge
   preserve // yes preserve the file, the new variable will be saved and merged back in
   foreach x in `anything' {
      if "`prefix'"=="" & "`suffix'"=="" {
         local varlist "`varlist' `x'"
      }
      else {
         local varlist "`varlist' `prefix'`x'`suffix'"
         return local varlist "`varlist'"
      }
   }
   ** Missing values
   if "`missinglist'"~="" {
      mvdecode `varlist' , mv(`missinglist')
   }
   if "`missinglist'"=="" {
     local missinglist = "."
   }
   marksample touse , novarlist
   local items 0
   foreach var of varlist `varlist' {
     local items `++items'
   }
   *** if f0 is called force the floor to 0 by item
   if "`f0'"=="f0" {
      local min=1
      foreach var of varlist `varlist' {
         su `var'
         if `r(min)'<`min' {
            local `min'=`r(min)'
         }
      }
      foreach var of varlist `varlist' {
         replace `var'=`var'-`min' 
      }
   } // end of f0 call
   *** indicator call
   *** choose a particular value to re-define the response item
   *** as an indicator
   if "`indicator'"~="" {
      foreach var of varlist `varlist' {
         recode `var' (`indicator'=1) (missing=.) (nonmissing=0)
      }
      noisily itemsummary `varlist'
   }
   *** mean imputation for missing values
   *** Rich fixed an error on the line below 6-24-2018
   *** the line used to read:    if "`meanimp'"=="`meanimp" {
   *** which would end up ALWAYS doing mean imputation even when
   *** meanimputation was not asked for (becasue ""=="")
   *** This would also have caused ICE option to crash because
   *** by the time we get to the ICE option, there are 
   *** no missing items
   if "`meanimp'"=="meanimp" {
      tempvar rowmeanis
      egen `rowmeanis'=rowmean(`varlist')
      replace `rowmeanis'=round(`rowmeanis')
      foreach var of varlist `varlist' {
         replace `var'=`rowmeanis' if `var'==.
      }
   }
   *** Compute number of missing items
   tempvar miss
   gen `miss'=0 if `touse'
   foreach var of varlist `varlist' {
      replace `miss'=`miss'+1 if missing(`var') & `touse'
   }
   *** single imputation for missing values
   if "`ice'"=="ice" {
      capture qui ice `varlist' , clear
      local icerc=_rc
      if `icerc'==0 {
         sort _mi _mj
         local nevarlist ""
         foreach var of varlist `varlist' {
            gen imputed_`var'=`var'
            local newvarlist "`newvarlist' imputed_`var'"   
            by _mi: replace imputed_`var' =imputed_`var'[_n+1] if _n==1 & imputed_`var'==.
         }
         keep if _mj==0
         drop _mj _mi
         local varlist "`newvarlist'"
      }
      if `icerc'~=0 {
         noisily di `icerc'
         noisily di in red "ICE DID NOT RUN"
         exit
      }
   }
   *** end single imputation for missing values
   tempvar tot
   gen `tot'=0 if `touse'
   * change to reverse
   if "`reverse'"=="" {
      local reverse="888888"
   }
   foreach var of varlist `varlist' {
     if "`all'"~="all" {
        if regexm("`reverse'","`var'")==0 {
           replace `tot'=`tot'+`var' if missing(`var')~=1 & `touse'
        }
        if regexm("`reverse'","`var'")==1 {
           noisily di in red "reversing `var'"
           su `var' if missing(`var')==0
           tempvar foo
           gen `foo'=r(max)-`var' if missing(`var')==0
           replace `tot'=`tot'+`foo' if missing(`var')==0 & `touse'
           drop `foo'
        }
     }
     if "`all'"=="all" {
        if regexm("`reverse'","`var'")==0 {
           replace `tot'=`tot'+`var' if missing(`var')==0 & `touse' & `var'~=.
        }
        if regexm("`reverse'","`var'")==1 {
           su `var' if missing(`var')==0
           tempvar foo
           gen `foo'=r(max)-`var' if missing(`var')==0
           replace `tot'=`tot'+`foo' if missing(`var')==0 & `touse' & `var'~=.
           drop `foo'
        }
     }
   }
   * changed revers 4-21-2009
   if "`reverse'"=="auto" {
      noisily di "checking direction of components"
      foreach var of varlist `varlist' {
         corr `var' `tot' if missing(`var')==0 & `touse'
         if r(rho)<0 {
            noisily di in green "changing direction of " in yellow "`var'" in green " in computed score"
            replace `tot'=`tot'-`var' if missing(`var')==0 & `touse'
            su `var' if missing(`var')==0 & `touse'
            tempvar t`var' 
            gen `t`var''=r(max)-`var' if missing(`var')==0 & `touse'
            replace `tot' = `tot'+`t`var'' if missing(`var')==0 & `touse'
         }
      }
   }
   if "`all'"~="all" {
      if "`prorate'"=="prorate" {
         if "`maxitemresponse'"=="" {
            replace `tot'=round(`tot'*(`items'/(`items'-`miss')),1)
         }
         if "`maxitemresponse'"~="" {
            tokenize "`maxitemresponse'"
            * check to make sure right number of response categories are given
            local toomanyitems=`items'+1
            if ("``items''"~="" & "``toomanyitems''"=="")~=1 {
               local foo = wordcount("`maxitemresponse'")
               noisily di in red _n "Wrong number of entries in " in white "maxitemresponse " in red "provided" _n ///
                  in white _col(3) "usage is, for example " in green "maxitemresponse(" in yellow "1 2 3 1 2 3" in green ")" _n ///
                  in white _col(3) "where " in yellow "1 2 3 1 2 3" in white " are the highest possible item scores for" _n ///
                  in white _col(3) "items 1-6, respectively if you had a six item measure. " _n ///
                  in white _col(3) "Note no comma or separator other than a space." _n /// 
                  in white _col(3) "In your code scoreit.ado expected " in yellow "`items'" in white " but " _c ///
                  in yellow _col(3) "`foo'" in white " were provided." _n _n 
               exit
            }
            * store item max and compute total possible maximum
            local maxscore=0
            forvalues i=1/`items' {
               local max`i'=``i''
               local maxscore=`maxscore'+`max`i''
            }
            * generate each persons maximum possible score for observed items
            tempvar imaxscore
            gen `imaxscore'=0
            local i=0
            foreach var of varlist `varlist' {
               replace `imaxscore'=`imaxscore'+`max`++i'' if missing(`var')==0
            }
            * prorate on the basis of total possible score
            replace `tot'=round(`tot'*(`maxscore'/`imaxscore'),1) if `imaxscore'>0
         }
      }
      if "`minitems'"=="" {
         noisily di in green "Applying the .4 rule: more than 40% of items must be non-missing to have a total score."
         replace `tot'=. if `miss'>.4*`items'
      }
      if "`minitems'"~="" {
         noisily di in green "Applying the minimum items rule (`minitems')"
         replace `tot'=. if `miss'>(`items'-`minitems')
      }
   }
   qui su `miss' if `miss'==`items' , meanonly
   noisily di _n "NB: `r(N)' observations set to missing on " in ye "`gen'" in gr " due to missing on all items" _n
   replace `tot'=. if `miss'==`items'
   if "`z'"=="z" | "`t'"=="t" | "`iq'"=="iq" | "`hz'"=="hz" {
      if "`to'"~="" {
         qui su `tot' if `touse' & `to'
      }
      else {
         qui su `tot' if `touse' 
      }
      local mean=r(mean)
      local sd=r(sd)
      if "`hz'"=="hz" {
         local sd=`sd'/2
      }
      replace `tot' = `sd'^-1*(`tot'-`mean')
      if "`t'"=="t" {
        replace `tot'=(`tot'*10)+50
      }
      else {
         if "`iq'"=="iq" {
            replace `tot'=(`tot'*15)+100
         }
      }
   }
   if "`replace'"=="replace" {
      capture drop `gen'
   }
   gen `gen' = `tot'
   capture qui alpha `varlist' if `touse'
   if _rc==0 {
     noisily alpha `varlist' if `touse'
     return scalar alpha = `r(alpha)'
     if "`reverse'"~="reverse" {
        di "   NB: if any items reversed, that refers to the alpha procedure only, not scoring"
     }
   }
   su `tot'
   if r(sd)>0 & r(sd)~=. {
     noisily {
        di ""
        di "Item Means +/- 1 SD from mean on scale"
        di "Item" _col(13) "High" _col(23) "Low"
        di "----------------------------------------"
        qui su `tot'
        local mean1=r(mean)+r(sd)
        local mean2=r(mean)-r(sd)
        foreach var of varlist `varlist' {
           local varl : var label `var'
           qui su `var' if `tot'>`mean1' & `tot'~=. & inlist(`var',`missinglist')==0 , meanonly
           local x1=r(mean)
           qui su `var' if `tot'<`mean2' & `tot'~=. & inlist(`var',`missinglist')==0 , meanonly //, detail
           local x2=r(mean)
           di "`var'" _col(10) %8.2f `x1' _col(20) %8.2f `x2' _col(30) "`varl'"
        }
      }
   }
   tempfile f1
   keep `id' `gen'
   save `f1' , replace
   restore 
   merge `id' using `f1' , sort
   drop _merge
} // close qui
end
