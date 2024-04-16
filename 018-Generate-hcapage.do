cap confirm file w018.dta 
if _rc==0 {
   exit
}
* (Re-)Create age
* HCAP age was in the non-public data from DW and RMcM
* But it does not agree with what is in the public release HCAP data
* I have previously deleted hcapage from the non-public data
* and now I generate a new hcapage and add it to the working
* respondent data file (w011.dta). 
* 
* hcapage is defined from r1rage from the HRS data file use "R1RAGE"
* New 2023-12-18
* If it is missing I use INF1RIWAGE from the informant interview (w013.dta)
use hhid pn R1RAGE R1IWYEAR using "/Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP23/POSTED/DATA/SOURCE/HC16/HC16sta/hc16hp_r.dta" , clear 
clonevar hcapage = R1RAGE 
su hcapage
tempfile w018a
save `w018a' , replace 
use hhid pn inf1riwage using w013.dta , clear
merge 1:1 hhid pn using `w018a' , nogen
replace hcapage = inf1riwage if missing(hcapage)
keep hhid pn hcapage 
save w018.dta , replace 
use w011.dta , clear 
cap drop _merge
merge 1:1 hhid pn using w018.dta 
save w011.dta , replace 
* . contents
*                                                            |   Obs      Mean  Std. Dev.      Min       Max
* -----------------------------------------------------------+----------------------------------------------
* hhid:     HRS 2016 HHID                                    |     0         .         .         .         .
* pn:       HRS PERSON NUMBER                                |     0         .         .         .         .
* hcapage:  W1 HCAP RESPONDENT AGE AT RESPONDENT INTERVIEW   |  3496    76.339   7.59567        65       103
*


