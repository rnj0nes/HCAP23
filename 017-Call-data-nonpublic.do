cap confirm file w017.dta 
if _rc==0 {
    exit 
}
* excerpted from
* Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP22/POSTED/ANALYSIS/Norms-with-weights-202109/-105-call-source.do


* DementiaDx from hcap16_dem_indicators_20201015.dta is used in the Imputation Model (-w051)

* ========================================== NORMING SAMPLE
* The norming sample data set was prepared and shared by
* Ryan McCammon. It can't be shared publicly.
cap confirm file hcapnormexcldsummary_20231220.dta
if _rc~=0 {
    inputst "$source/hcapnormexcldsummary_20231220.sas7bdat"
    lowercase
    save  $source/hcapnormexcldsummary_20231220.dta , replace 
}
use  $source/hcapnormexcldsummary_20231220.dta , clear
table normexcld
save w017.dta , replace
* =================================== END OF NORMING SAMPLE

* Dementia indicators
* sent by Ryan McCAmmon
use  /Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP23/POSTED/DATA/SOURCE/hcap16_dem_indicators_20201015.dta
save w017_hcap16_dem_indicators_20201015.dta, replace 

