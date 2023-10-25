cap confirm file w051-postimputation.dta 
if _rc==0 {
   exit
}

* differences from 2022
* Using HCAP informant Jorm total score, as imputed in HCAP data download
* Using Blessed part 1 score, as imputed in HCAP data download
* Jorm and Blessed scores
* oldvar    new var
* h1ijormsc inf1jorm_score
* h1ibl1tot inf1bl1_score
use w013.dta , clear
keep hhid pn inf1jorm_score inf1bl1_score
merge 1:1 hhid pn using w041_output.dta, nogen
gen _id=_n

gen racecat3=.
replace racecat3=1 if black==1
replace racecat3=2 if hisp==1
replace racecat3=0 if missing(racecat3)
vlabel racecat3 white Black Hispanic

su vdori1 if normexcld==0
* 9.6955792 - 1.5*.61812629 = 8.76838976
* gen IMPAIRED_vdori1 = vdori1 < 8.76838976  if missing(vdori1)~=1
* since vdori1 are intergers from 0-10, impairment is 
* classified when vdori1 is 8 or less (and missing if vdori1 is missing)
gen IMPAIRED_vdori1 = vdori1<`r(mean)'-1.5*`r(sd)' if missing(vdori1)~=1

clonevar Imemm1 = IMPAIRED_memm1 
clonevar Iexfm1 = IMPAIRED_exfm1 
clonevar Ilflm1 = IMPAIRED_lflm1 
clonevar Ivdvis1 = IMPAIRED_vdvis1 
clonevar Ivdori1 = IMPAIRED_vdori1 

cap drop _merge
merge m:1 hhid pn using w017_hcap16_dem_indicators_20201015.dta, nogen


* now imputation
cap drop rnjid
egen rnjid=group(hhid pn)
save w051-preimputation.dta , replace 

* capture is needed because the imputation-only 
* runmplus model returns an error code. 
* capture makes sure the program keeps running
capture runmplus Imemm1 Iexfm1 Ilflm1 Ivdvis1 Ivdori1 Tmemm1 Texfm1 Tlflm1 Tvdvis1 vdori1 inf1jorm_score inf1bl1_score dementiaDx black hisp hcapage edcat female , id(rnjid) ///
   variable( ///
	   usevariables = Imemm1 Iexfm1 Ilflm1 Ivdvis1 Ivdori1 inf1jorm_score inf1bl1_score Tmemm1 Texfm1 Tlflm1 Tvdvis1 vdori1 dementiaDx ; ///
		auxiliary = dementiaDx black hisp hcapage edcat female ; )	///
   dataimputation( ///
	   IMPUTE  = Imemm1 (c) Iexfm1 (c) Ilflm1 (c) Ivdvis1 (c) Ivdori1 (c) inf1jorm_score inf1bl1_score  Tmemm1 Texfm1 Tlflm1 Tvdvis1 vdori1 ; ///
		NDATASETS = 1 ; ///
		SAVE = hcapimp.dat ; ) ///
	analysis(type=basic ; bseed = 3481; ) ///
	savelogfile(foogoo) ///
	tech8
clear
runmplus_load_savedata , out(foogoo.out)
rename imemm1 Imemm1 
rename iexfm1 Iexfm1 
rename ilflm1 Ilflm1 
rename ivdvis1 Ivdvis1 
rename ivdori1 Ivdori1 
rename inf1jorm inf1jorm_score 
rename inf1bl1_ inf1bl1_score
rename tmemm1 Tmemm1
rename texfm1 Texfm1
rename tlflm1 Tlflm1
rename tvdvis1 Tvdvis1
* rename vdori1 vdori1
keep rnjid ///
   Imemm1 Iexfm1 Ilflm1 Ivdvis1 Ivdori1 ///
   inf1jorm_score inf1bl1_score ///
   Tmemm1 Texfm1 Tlflm1 Tvdvis1 vdori1 
save w051-line70.dta , replace

use w051-preimputation.dta , clear
rename Imemm1 oImemm1
rename Iexfm1 oIedfm1
rename Ilflm1 oIlflm1
rename Ivdvis1 oIvis
rename Ivdori1 oIvdori1
rename inf1jorm_score oinf1jorm_score
rename inf1bl1_score oinf1bl1_score
rename Tmemm1  oTmemm1 
rename Texfm1  oTexfm1 
rename Tlflm1  oTlflm1 
rename Tvdvis1 oTvdvis1 
rename vdori1 ovdori1 

merge 1:1 rnjid using w051-line70.dta , nogen

* range restriction on imputed values matches original
foreach x in inf1jorm_score inf1bl1_score Tmemm1 Texfm1 Tlflm1 Tvdvis1 vdori1 {
   su o`x'
   replace `x' = `r(min)' if `x' < `r(min)' & missing(`x')~=1
   replace `x' = `r(max)' if `x' > `r(max)' & missing(`x')~=1
}

save w051-postimputation.dta , replace



