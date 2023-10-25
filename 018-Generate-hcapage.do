cap confirm file w018.dta 
if _rc==0 {
   exit
}
* (Re-)Create age
* HCAP age was in the non-public data from DW and RMcM
* But it does not agree with what is in the public release HCAP data
* I have previously deleted hcapage from the non-public data
* and now I generate a new hcapage and add it to the working
* respondent data file (w011.dta). I have to fill in missing
* age from the core data file.
* Fill in missing age from tracker 
use hhid pn page piwyear hcap16resp using ///
   "/Users/rnj/Library/CloudStorage/Dropbox/Work/hrs/POSTED/DATA/SOURCE/trk2018v2a/trk2018tr_r.dta" ///
   if inlist(hcap16resp,1,2,3) , clear 
tempfile trkpage 
save `trkpage'
use hhid pn R1RAGE R1IWYEAR using "/Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP23/POSTED/DATA/SOURCE/HC16/HC16sta/hc16hp_r.dta" , clear 
merge 1:1 hhid pn using `trkpage'
clonevar hcapage = R1RAGE 
replace hcapage = page if missing(hcapage)
keep hhid pn hcapage 
save w018.dta , replace 
use w011.dta , clear 
merge 1:1 hhid pn using w018.dta 
save w011.dta , replace 


