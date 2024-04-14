* z1 score[
* places variables on a (0,1) score (non-inclusive of 0,1)
* back-translation in notes
capture program drop z1
program define z1 , rclass
syntax varlist [ , logit z altmethod softmax lambda(string) altmax(string) ]

local a1=5
local b=8
local a2=10
local k=1000

if "`z'"=="z" & "`logit'"=="logit" {
   di as error "specify z or logit, not both"
}

qui {
   foreach var of varlist `varlist' {
      if "`softmax'"=="softmax" {
         * http://rgm2.lab.nig.ac.jp/RGM2/func.php?rd_id=DMwR:SoftMax
         * lambda option is expected
         * it is the number of standard deviations over which
         * the transformed variable is expected to be linear
         cap drop `var'_z1
         if "`lambda'"=="" {
            di in yellow "Caution " in green "lambda not specified, using 2"
            local lambda=2
         }
         su `var'
         gen `var'_z1 =1 / ( 1+ exp( -1*(`var'-`r(mean)')/(`lambda'*`r(sd)'/2*c(pi)) ) )
      }
      if "`altmethod'"=="altmethod" {
         * in altmethod, the values for var are replaced
         * with the halfway point between the adjacent values
         *   var   n  var'  p(var)
         *    0   n0  0.5    0.133
         *    1   n1  1.5    0.400
         *    2   n2  2.5    0.667
         *    3   n3  3.5    0.933
         * and we use half of the smoothed estimate of the value for the
         * last and unobserved level for the denominator
         *
         *   denominator = [max(var') + (1/2)*(0.5+0.5+0.5+0.5)/4]-min(var) = 4
         *
         cap drop `var'_z1
         preserve
         tempvar constant
         gen `constant'=1
         collapse `constant' , by(`var')
         drop if `var'==.
         su
         sort `var'
         gen _`var't = `var'+(1/2)*(`var'[_n+1]-`var')
         gen _`var'd = _`var't-`var'
         su
         reg _`var'd `var'
         local b0=_b[_cons]
         local b1=_b[`var']
         local N=_N
         local min=`var'[1]
         replace _`var't  = `var' + (`b0'+`b1'*`var'[`N']) in `N'
         local D= (_`var't[`N']+[0.5*(`b0'+`b1'*`var'[`N'])])-`min'
         replace _`var't = _`var't-`min'
         gen `var'_z1 = _`var't/`D'
         su
         keep `var' `var'_z1
         tempfile goo
         save `goo'
         restore
         cap drop _merge
         merge `var' using `goo' , uniqusing sort
         cap drop _merge
      }
      if "`altmethod'"~="altmethod" & "`softmax'"~="softmax" {
         qui su `var' , detail
         local max=r(max)
         if "`altmax'"~="" {
            local max=`altmax'
         }
         local sd=r(sd)
         local min=r(min)
         cap drop `var'_z1
         #d ;
         qui gen `var'_z1 = 
            (`var'-`min'+(`a1'/(`b'*`k'))*`sd') 
            /
            (`max'-`min'+(`a2'/(`b'*`k'))*`sd') ;
         #d cr
      }
      if "`logit'"=="logit" {
         replace `var'_z1 = ln(`var'_z1/(1-`var'_z1))
      }
      if "`z'"=="z" {
         replace `var'_z1 = invnorm(`var'_z1)
      }
      if "`altmethod'"~="altmethod" & "`softmax'"~="softmax" {
         note `var'_z1 : To get back to `var' from `var'_z1, use
         if "`logit'"~="logit" & "`z'"~="z" {
            note `var'_z1 : `var' = `var'_z1 * (`max'-`min'+(`a2'/(`b'*`k'))*`sd') + (`min'+(`a1'/(`b'*`k'))*`sd')
            local foo : di %20.10g (`max'-`min'+(`a2'/(`b'*`k'))*`sd') 
            local hoo : di %20.10g (`min'+(`a1'/(`b'*`k'))*`sd')
            note `var'_z1 : `var' =  `var'_z1 * `foo' + `hoo'
            label var `var'_z1 "`var' = `var'_z1 * `foo' + `hoo'"
            label var `var'_z1 "`var'_z1 = (`var' - `hoo')/`foo'"
         }
         if "`logit'"=="logit" {
            note `var'_z1 : `var' = invlogit(`var'_z1) * (`max'-`min'+(`a2'/(`b'*`k'))*`sd') + (`min'+(`a1'/(`b'*`k'))*`sd')
            local foo : di %20.10g (`max'-`min'+(`a2'/(`b'*`k'))*`sd') 
            local hoo : di %20.10g (`min'+(`a1'/(`b'*`k'))*`sd')
            note `var'_z1 : `var' =  invlogit(`var'_z1) * `foo' + `hoo'
            label var `var'_z1 "`var' = invlogit(`var'_z1) * `foo' + `hoo'"

         }
         if "`z'"=="z" {
            note `var'_z1 : `var' = normal(`var'_z1) * (`max'-`min'+(`a2'/(`b'*`k'))*`sd') + (`min'+(`a1'/(`b'*`k'))*`sd')
            local foo : di %20.10g (`max'-`min'+(`a2'/(`b'*`k'))*`sd') 
            local hoo : di %20.10g (`min'+(`a1'/(`b'*`k'))*`sd')
            note `var'_z1 : `var' =  normal(`var'_z1) * `foo' + `hoo'
            label var `var'_z1 "`var' = normal(`var'_z1) * `foo' + `hoo'"
            note `var'_z1 : `var' =  normal(`var'_z1) * `foo' + `hoo'
            note `var'_z1 : normal(`var'_z1) = (`var' - `hoo')/`foo'
            
         }
         noisily notes `var'_z1
         return scalar foo = `foo'
         return scalar hoo = `hoo'
      }
   }
}

end
