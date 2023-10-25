

use ../w071.dta , clear 

noisily di _n "Weighted distribution of final classifications by race/ethnicity group (`impairment_threshold' cut)" _n
noisily tab hcapdx racecat3 , m col, [fw=hcap16wgtr]

* Compute entries for flow diagram
*
*          [Impaired on 2+ domains] -- [No] -- n11 -- [Impaired on 1 domain] --+
*           |                                          |                       |
*          [Yes]                                      [Yes]                   [No]
*           |                                          |                       |
*           n21                                        n22                    n23 ---------------+
*           |                                          |                                         |
*          [Inf-rated impairment] --+                 [Inf-rated concerns] --+                   |
*           |                       |                  |                     |                   |
*          [Yes]                   [No]               [Yes]                 [No]                 |
*           |                       |                  |                     |                   |
*           n31                     n32                n33                   n41                 |
*           |                       |                  |                     |                   |
*           |                       |                  |                    [Self-rated          |
*           |                       +----------------- +                      memory             |
*           |                       |                                        concerns] --+       |
*           |                       |                                        |           |       |
*           |                       |                                       [Yes]      [No]      |
*           |                       +----------------------- n41 ------------+          |        |
*           |                       |                                                   n42      |
*           |                       |                                                   |        |
*          [Dementia]              [MCI]                                               [Normal Cognition]
*           |                       |                                                   |
*           n51                    n52                                                  n53
*
qui {
    noisily di _n "Unweighted distribution of final classifications (`impairment_threshold' cut)" _n
    noisily tab hcapdx , m
    noisily di _n "Weighted distribution of final classifications (`impairment_threshold' cut)" _n
    noisily tab hcapdx , m ,[fw=hcap16wgtr]
}
* ---------------------------------------------------------------
* For the figure
gen n11 = impairedcat<2 // impaired 2+ domains: no
gen n21 = impairedcat==2 // impaired 2+ domains: yes
gen n22 = impairedcat==1 if impairedcat<2 // impaired 1 domain: yes
gen n23 = impairedcat==0 if impairedcat<2 // impaired 1 domain: no
gen n31 = Iinformant19a==1 if impairedcat==2 // informant rated impairment: yes
gen n32 = Iinformant19a==0 if impairedcat==2 // informant rated impairment: no
gen n33 = Iinformant99==1 if impairedcat==1 // informant rated concerns: yes
gen n34 = Iinformant99==0 if impairedcat==1 // informant rated concerns: no
gen n41 = Ipd102==1 if Iinformant99==0 & impairedcat==1 // self-rated memory concerns: yes
gen n42 = Ipd102==0 if Iinformant99==0 & impairedcat==1 // self-rated memory concerns: no
gen n51 = hcapdx==3 // dementia
gen n52 = hcapdx==2 // mci
gen n53 = hcapdx==1 // normal
la var n11 "impaired 2+ domains: no"
la var n21 "impaired 2+ domains: yes"
la var n22 "impaired 1 domain: yes"
la var n23 "impaired 1 domain: no"
la var n31 "informant rated impairment: yes"
la var n32 "informant rated impairment: no"
la var n33 "informant rated concerns: yes"
la var n34 "informant rated concerns: no"
la var n41 "self-rated memory concerns: yes"
la var n42 "self-rated memory concerns: no"
la var n51 "dementia"
la var n52 "mci"
la var n53 "normal"
preserve
keep hhid pn hcapdx hcap16wgtr n11-n53
save hcapdx.dta , replace
rdoc init results.csv , replace
r node, label, n, denom, p, pw, Npw
foreach var of varlist n11-n53 {
   qui {
      local foo: var lab `var'
      su `var'
      local goo  = `r(N)'
      local hoo  =  `r(sum)'
      local ioo : di %5.3f `r(mean)'
      logit `var' [pw=hcap16wgtr]
      local joo : di %5.3f invlogit(_b[_cons])
      replace `var' = 0 if missing(`var')
      logit `var' [pw=hcap16wgtr]
      local koo : di %5.3f invlogit(_b[_cons])
      r `var', `foo', `hoo' , `goo', `ioo' , `joo',`koo'
   }
}
rdoc close
type results.csv
* node  is the position in the flow diagram
* label is the descriptor for the node
* n     is the numerator  for the node
* denom is the denominator for the node
* p     is the n/denom 
* pw    is n/demom with sampling weights
* Npw   is n/total sample size (3496) with sampling weights
