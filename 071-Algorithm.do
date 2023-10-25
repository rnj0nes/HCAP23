cap confirm file w071.dta
if _rc==0 {
   exit
}

* Adapted from
* /Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP23/POSTED/ANALYSIS/Dementia-algorithm/dementia-algorithm-cut35-2021-10-05.domd
* Abstract and overall results
*
* The dementia algorithm cutting cognitive scores at "35".
* 
* A threshold of 35 means that a person is counted as being impaired on
* a domain if the standardized and normalized score is less than or
* equal to 35 on a T score metric.
*
*
*
*
* ----------------------------------------------------------------------------
* IMPAIRMENT IS DEFINED AS PERFORMANCE LESS THAN 1.5SD BELOW THE MEAN OF THE
* NORMATIVE REFERENCE GROUP
* ----------------------------------------------------------------------------
* In the previous analytic step (see Norms-with-weights-202109/-111-standardize-cognition-scores.do
* We had text that described our impairment threshold. We wanted to use a 1.5SD cut off, and wrote:
* "The 7.5th percentile for a T score is a value of 35.6. Since we are rounding to the nearest whole
* number, a T-score scaled factor score of 36 or higher will be considered above threshold, and a
* factor score of 35 or below will be considered below threshold.
* At this point in the process, we have T-scores for cognitive test performance, but they are
* not rounded to integers. We specified a cut point of 35 on line 57 below, and
* on line 63 use a "<" operator to identify impairment. 
* 
* So, impairment is NOW defined as a person have a Tscore that is less than 35, and 35 is going to be
* 1.5 SD below the mean of the normative reference group.
* ----------------------------------------------------------------------------
local impairment_threshold = 35
use w051-postimputation.dta , clear
* note orientation omitted from below list
foreach x in memm1 exfm1 lflm1 vdvis1 {
   cap drop I`x'
   gen I`x'=T`x'<`impairment_threshold'
}

cap drop impairedcat
gen impairedcat = 0
* note orientation included below
* Because vdori1 is omitted from the loop re-defining impairment indicators
* based on imputed T-scores) but is included in the loop below, this means
* that impairment on orientation is based on the imputed (Bayesian plausible
* value) for the binary impairment indicator for orientation (Ivdori1)
foreach x in memm1 exfm1  vdvis1  lflm1 vdori1 {
   replace impairedcat=impairedcat+1 if I`x'==1
}
replace impairedcat=2 if impairedcat>=2 & missing(impairedcat)~=1
vlabel impairedcat 0 1 2+
* Informant concern condition
* There are two versions
*  - One uses cuts of ">=" 3 or 0 (Jorm, Blessed) [Iinformant99]
*  - Two uses cuts of ">=" 3.4 or 2 (Jorm, Blessed) [Iinformant19a]
* -------------------------------------------------------- Informant99 for MCI
cap drop Iinf1jorm_score99
cap drop Iinf1bl1_score99
cap drop Iinformant99
gen Iinf1jorm_score99 = inf1jorm_score > 3 if missing(inf1jorm_score)~=1
la var Iinf1jorm_score99 "inf1jorm_score > 3"
gen Iinf1bl1_score99 = inf1bl1_score > 0 if missing(inf1bl1_score)~=1
la var Iinf1bl1_score99 "inf1bl1_score > 0 "
gen Iinformant99 = Iinf1jorm_score99 == 1 | Iinf1bl1_score99 == 1
replace Iinformant99 = 1 if Iinf1jorm_score99 == 1 & missing(Iinf1bl1_score99)
replace Iinformant99 = 1 if Iinf1bl1_score99 == 1 & missing(Iinf1jorm_score99)
* -------------------------------------------------- Informant19a for Dementia
cap drop Iinf1jorm_score19a
cap drop Iinf1bl1_score19a
cap drop Iinformant19a
gen Iinf1jorm_score19a = inf1jorm_score >= 3.4 if missing(inf1jorm_score)~=1
la var Iinf1jorm_score19a "inf1jorm_score >= 3.4"
gen Iinf1bl1_score19a = inf1bl1_score >= 2  if missing(inf1bl1_score)~=1
la var Iinf1bl1_score19a "inf1bl1_score >= 2 "
gen Iinformant19a = Iinf1jorm_score19a == 1 | Iinf1bl1_score19a == 1
replace Iinformant19a = 1 if Iinf1jorm_score19a == 1 & missing(Iinf1bl1_score19a)
replace Iinformant19a = 1 if Iinf1bl1_score19a == 1 & missing(Iinf1jorm_score19a)
* Worse self-reated memory
* Really, not same or better self-rated memory
* ---------------------------------------------------------------
gen Ipd102=inlist(pd102,1,2)~=1
* HCAP Diagnosis
cap drop hcapdx
gen hcapdx = .
replace hcapdx=3 if impairedcat==2 & Iinformant19a==1 // dementia
replace hcapdx=2 if impairedcat==2 & Iinformant19a==0 // mci
replace hcapdx=2 if impairedcat==1 & Iinformant99==1  // mci
replace hcapdx=2 if impairedcat==1 & Iinformant99==0 & Ipd102==1 // mci
replace hcapdx=1 if impairedcat==1 & Iinformant99==0 & Ipd102==0 // normal
replace hcapdx=1 if impairedcat==0
la def hcapdx 1 "1-normal" 2 "2-mci" 3 "3-dementia"
la values hcapdx hcapdx
* end product
save w071.dta , replace






