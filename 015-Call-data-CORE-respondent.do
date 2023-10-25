cap confirm file w015_sex_race.dta 
if _rc==0 {
    exit 
}
* Core data file
* has been pre-processed to Stata format
use /Users/rnj/Library/CloudStorage/Dropbox/Work/hrs/POSTED/DATA/SOURCE/h16/H16D_R.dta, clear
lowercase
save w015.dta , replace 

* Demographic variables from the tracker (trk)
use ///
    "/Users/rnj/Library/CloudStorage/Dropbox/Work/hrs/POSTED/DATA/SOURCE/trk2018v2a/trk2018tr_r.dta" ///
    if inlist(hcap16resp,1,2,3) , clear 
*
* Years of education (schlyrs)
*
* For the new integrated analysis, I am using years of education (schlyrs) from
* the 2018 tracker file. In the original analysis (published in Manly et al 2022)
* I used a schlyrs data file provided by Ryan McCammon (hcap_schooling.dta). The 
* values are slightly off between these two files. Here are the discrepant records:
*                       -- schlyrs --
*      hhid    pn   Ryan McM  trk2018tr_r
*    134189   020         14         99  
*    502334   010         12         99  
*    502607   010         10         99  
*    905576   010         16         99  
*    906962   010         12         99  
*
* Since Ryan McCamon apparently had another source or imputation for these
* "99" values for schlyrs in the 2018 tracker, I will hard code these
* imputations into the current working file 
replace schlyrs =  14  if hhid == "134189" & pn ==  "020" 
replace schlyrs =  12  if hhid == "502334" & pn ==  "010" 
replace schlyrs =  10  if hhid == "502607" & pn ==  "010" 
replace schlyrs =  16  if hhid == "905576" & pn ==  "010" 
replace schlyrs =  12  if hhid == "906962" & pn ==  "010" 
* In so doing, the schlyrs variable used in the following analyses will not
* be discrepant from previous analyses on the basis of schlyrs
*
* Sex
gen female=gender==2 
* Race and Ethnicity
* labels from https://hrs.isr.umich.edu/sites/default/files/meta/tracker/codebook/trk2020tr_ri.htm
vlabel race not_obtained White Black_or_African_American Other
vlabel hispanic not_obtained Hispanic_mexican Hispanic_other Hispanic_unknown Non_Hispanic
* Black or African-American indicator identifies people who
* self-identify as black (race=2) as long as they don't also
* identify as Hispanic (Hispanic was not collected or they don't
* identify as Hispanic)
gen black=(race==2) 
replace black=0 if inlist(hispanic,1,2,3)
gen thud=inlist(hispanic,1,2,3) // thud is a placeholder name for hispanic indicator
* Note: 
* Hispanic count is off by 1 person according to data file David 
* Weir provided ("hrsvars.dta") on 31 Jan, 2018
* https://mail.google.com/mail/u/0/#search/hrsvars.dta/FMfcgxmZSpFrXKRNRhBBFlbCJDVvNKdL
* 
* In the 2018 tracker, there is 1 additional person identifying as hispanic
* hhid = 500786   pn = 011 
*
* I will be using the tracker version of 2018 hispanic
keep hhid pn female black thud schlyrs page // page is age in 2016 interview and used to fill in missing hcapage in 3496 sample
rename thud hisp
la var black "Black or African-American (not Hispanic) from TRK2018_tr_r"
la var hisp "Hispanic from TRK2018_tr_r"
save w015_sex_race.dta , replace 

