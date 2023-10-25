cap confirm file w017.dta 
if _rc==0 {
    exit 
}
* excerpted from
* Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP22/POSTED/ANALYSIS/Norms-with-weights-202109/-105-call-source.do

* ========================================== NORMING SAMPLE
* The norming sample data set was prepared and shared by
* Ryan McCammon. It can't be shared publicly.
local normingsample "hcapnormexcldsummary_20210426"
use $source/`normingsample'.dta , clear
lowercase 
version 16: table normexcld , c(min h1rmsetotal max h1rmsetotal)
* Drop hcap16wgtr because it's in HCAP (hc16hp_r.dta)
drop hcap16wgtr
save w017.dta , replace
* =================================== END OF NORMING SAMPLE

* Dementia indicators
* sent by Ryan McCAmmon
use  /Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP/POSTED/DATA/SOURCE/hcap16_dem_indicators_20201015.dta
save w017_hcap16_dem_indicators_20201015.dta, replace 


