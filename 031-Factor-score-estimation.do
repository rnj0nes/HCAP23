cap confirm file w031-scores.dta 
if _rc==0 {
    exit
}


* Adapted from
* /Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP/POSTED/ANALYSIS/CFA-HCAP/-5010-scores.do

* Factor score estimation
*
* Factor score estimation is conducted at the single domain
* level, meaning the factor scores are estimated
* separately for multiple indicator domains separately.
* I also estimate a general cognitive composite
* using all domains and the orientation and visual processing
* single indicators. Factor scores are generated using
* weighted least squares, maximum likelihood, and 
* Bayes methods. These return, respectively, expected
* a posteriori, regression method, and plausible values
* as factor score estimates.
*
* This procedure is to 
* 1. first estimate a model using WLSMV(theta) to obtain 
*    starting values, then using the final estimates (using
*    the SVALUES option)
* 2. Estimate a final model using MLR(probit) because the  
*    MLR has better has missing data handling. These   
*    MLR(Probit) estimates with are saved using the SVALUES 
*    option, and treating these values as fixed, I 
* 3. Run a model to get Expected A Posteriori (EAP) factor 
*    score estimates (and their standard error) using the  
*    MLR(Probit) estimator, and then
* 4. Run a model to get a set of Bayesian Plausible Values 
*    using a Bayes estimator. The WLSMV(theta), MLR(probit), 
*    and Bayes parameter estimates are on the samme metric, 
*    and on the typical IRT 2PL metric as well. 
*
*
* Because this file takes so long to run (about 35 minutes),
* I have a test here to determine if the output data file 
* exists. If it does, I send an exit command.
*
* If you would like to run this program, delete the output 
* data file
* ---------------------------------------------------------
cap erase svalues.txt
cap erase model17wlsmv.out
cap erase model17mlr.out
cap erase model17bayes.out
cap erase model17pv.out

* process starting values       =====================================
cap program drop process_svalues
	program define process_svalues , rclass
	insheet line using svalues.txt , clear
	replace line=lower(line)
	replace line=trim(itrim(line))
	replace line=subinstr(line,"[ ","[",.)
	replace line=subinstr(line," ]","]",.)
	*replace line=subinstr(line,"*","@",.)
	gen order1=_n // 1-1000
	gen order2="Z"
	replace order2="A" if regexm(line,"\[") // thresholds
	replace order2="B" if regexm(line,"mem by") 
	replace order2="C" if regexm(line,"exf by") 
	replace order2="D" if regexm(line,"lfl by") 
	replace order2="F" if regexm(line,"gcp by") 
	replace order2="G" if regexm(line,"gcp by vdori") 
	replace order2="H" if regexm(line,"gcp by vdvis") 
	replace order2="I" if regexm(line,"ceradwl by") 
	replace order2="J" if regexm(line,"lm by") 
	replace order2="K" if regexm(line,"with") 
	sort order2 order1
	list , clean noobs
 	local model2 = "model("
	while `c(N)'>0 {
		local line=line
		local line = trim("`line'")
		local model2 "`model2' `line'"
		drop in 1
	}
	local model2 "`model2' )"
	return local model "`model2'"
end
* end process starting values   =====================================

if "`m'"=="" {
	local m=20
}
if "`t'"=="" {
	local t=101
}

use w021.dta , clear
gen rnjid=_n
save w031.dta , replace


* Memory
local memdomain "Memory, delayed episodic and recognition"
local memvarlist "vdmde1z vdmde2z vdmde3 vdmde4z vdmde5z vdmre1z vdmre2z"
local model_mem "`model_mem' mem by vdmde1z vdmde2z vdmde3 vdmde4z vdmde5z ;"
local model_mem "`model_mem' mem by vdmre1z vdmre2z  ; "
local model_mem "`model_mem' ceradwl by vdmde1z@1 ;"
local model_mem "`model_mem' ceradwl by vdmre1z@1 ;"
local model_mem "`model_mem' lm by vdmde2z@1 ;"
local model_mem "`model_mem' lm by vdmre2z@1 ;"
local model_mem "`model_mem' mem with ceradwl@0 lm@0;"
local model_mem "`model_mem' ceradwl with lm@0;"
local latents_mem "mem"
local pv_mem "memm1"

* Executive
local exfdomain "Executive functioning and attention, speed"
local exfvarlist "vdexf1z vdexf2z vdexf7z vdasp1z vdasp2z vdasp3 vdasp4z vdasp5z"
local model_exf "`model_exf' exf by vdexf1z vdexf2z vdexf7z  ;"
local model_exf "`model_exf' exf by vdasp1z vdasp2z vdasp3 vdasp4z vdasp5z ;"
local latents_exf "exf"
local pv_exf "exfm1"

* Language, fluency
local lfldomain "Language, fluency"
local lflvarlist "vdlfl1z vdlfl2 vdlfl3 vdlfl4 vdlfl5 vdlfl6 "
local model_lfl "`model_lfl' lfl by vdlfl1z vdlfl2 vdlfl3 vdlfl4 vdlfl5 vdlfl6  ;"
local latents_lfl "lfl"
local pv_lfl "lflm1"


* Second order
local gcpdomain "General cognitive performance"
local gcpvarlist "vdmde1z vdmde2z vdmde3 vdmde4z vdmde5z vdmre1z vdmre2z"
local gcpvarlist "`gcpvarlist' vdexf1z vdexf2z vdexf7z vdasp1z vdasp2z vdasp3 vdasp4z vdasp5z"
local gcpvarlist "`gcpvarlist' vdlfl1z vdlfl2 vdlfl3 vdlfl4 vdlfl5 vdlfl6 "
local gcpvarlist "`gcpvarlist' vdori1z vdvis1z"
local oridomain "Orientation"
local orivarlist "vdori1z"
local visdomain "Visuospatial"
local visvarlist "vdvis1z"
local model_gcp "`model_gcp' gcp by mem@1 exf* lfl*  ;"
local model_gcp "`model_gcp' gcp by vdori1z* vdvis1z*  ;"
local model_gcp "`model_gcp' lm ceradwl with gcp@0 exf@0 lfl@0 vdori1z@0 vdvis1z@0 ;"
local latents_gcp "gcp mem exf lfl"
local pv_gcp "gcpm1 memm1 exfm1 lflm1"


foreach x in mem exf lfl or vis gcp {
   local `x'_lab "``x'domain'"
}
local lm_lab "Logical memory methods factor"
local ceradwl_lab "CERAD word list methods factor"



foreach domain in mem exf lfl gcp {
	use w031.dta , clear
	
	tex \subsection{``x'domain'}

	cap macro drop _varlist
	cap macro drop _catlist
	cap macro drop _catis
	cap macro drop _modelis

	local catis "cat("
	foreach x in ``domain'varlist' {
		distinct `x'
		if `r(ndistinct)'<10 {
			local catis "`catis' `x'"
		}
	}
	local catis "`catis')"
	
	if "`domain'"~="gcp" {
		local modelis "model("
		local modelis "`modelis' `model_`domain'' )"
	}
	if "`domain'"=="gcp" {
		local modelis "model(`model_mem' `model_exf' `model_lfl'"
		local modelis "`modelis' `model_`domain'' )"		
	}

	* 1 : WLSMV(THETA)  =============================================
	local analysis1 "analysis(estimator=wlsmv; parameterization=theta;)"
	local output1 "output(stdyx; svalues;) savelog(model`domain'wlsmv) log(off)"
	use w031.dta , clear
	cap confirm file model`domain'wlsmv.out
	if _rc!=0 {
		runmplus ``domain'varlist' , `catis' `modelis' `analysis1' `output1' 
	}
	if _rc==0 {
		runmplus , po(model`domain'wlsmv.out)
	}
	mat E=r(estimate)
	mat E1=E
	fitsis `m'
	global start = `m'
	global end =`m'
	
	* 2 : MLR(probit) =============================================
	local analysis2 "analysis(estimator=mlr; link=probit; integration = montecarlo; algorithm=integration;)"
	local output2 "output(stdyx; svalues;) savelog(model`domain'mlr) log(off)"
	clear
	cap erase svalues.txt
	runmplus_read_svalues , out(model`domain'wlsmv.out)
	process_svalues
	local model2 "`r(model)'"
	cap confirm file model`domain'mlr.out
	if _rc~=0 {
		use w031.dta , clear
		runmplus ``domain'varlist' , `catis' `analysis2' `output2' `model2'
	}
	else {
		runmplus , po(model`domain'mlr.out)
	}
	mat E2=r(estimate)
	
	* 3 : MLR(probit) Factor Scores  =============================================
	local analysis3 "`analysis2'"
	local output3 "output(stdyx; svalues;) savelog(model`domain'mlr_eap_scores)"
	local output3 "`output3' savedata(save=fscores; file=eap`domain'.dat;) idvariable(rnjid) saveinp(model`domain'mlr_eap_scores)"
	clear
	cap erase svalues.txt
	runmplus_read_svalues , out(model`domain'mlr.out)
	process_svalues
	local model3 "`r(model)'"
	local model3 = subinstr("`model3'","*","@",.)
	* EAP Estimates
	use w031.dta , clear
	cap confirm file model`domain'mlr_eap_scores.out
	if _rc!=0 {
		runmplus ``domain'varlist' , `catis' `analysis3' `output3' `model3'
	}
	if _rc==0 {
		runmplus , po(model`domain'mlr_eap_scores.out)
	}
	*set matsize 9000
	cap confirm file w031-`domain'-eap.dta 
	if _rc ~=0 {
		clear
		runmplus_load_savedata , out(model`domain'mlr_eap_scores.out) 
		cap macro drop _foo
		foreach domainse in `latents_`domain'' {
			cap confirm variable `domainse'_se
			if _rc==0 {
				local foo "`foo' `domainse'_se "
			}
		}
		di in red "`foo'"
		keep rnjid `latents_`domain'' `foo'
		save w031-`domain'-eap.dta , replace 
	}
	* 4 : Bayes Factor Scores  =============================================
	local analysis4 "analysis(estimator=bayes;)"
	local output4 "idvariable(rnjid) savelog(model`domain'bayes) log(off) "	
	* Bayes parameter estimates =============================================
	cap confirm file model`domain'bayes.out
	if _rc~=0 {
		use w031.dta, clear
		runmplus ``domain'varlist' , `catis' `analysis4' `output4' `model2'
	}
	if _rc==0 {
		runmplus , po(model`domain'bayes.out)
	}
	mat E3=r(estimate)
	* Bayes factor scores using fixed estimates
	local output5 "output(data imputation: ndatasets=1; save = model`domain'pv*.dat;)"
	local output5 "`output5' savedata(file=model`domain'pv_plaus.dat; save = fscores(1); factors = `latents_`domain'' ;)"
	local output5 "`output5' idvariable(rnjid) savelog(model`domain'bayespv) log(off) saveinp(model`domain'bayesPV)"	
	cap confirm file model`domain'bayespv.out
	if _rc~=0 {
		runmplus ``domain'varlist' , `catis' `analysis4' `output5' `model3'
	}
	if _rc==0 {
	   runmplus , po(model`domain'bayespv.out)
	}
   * post-process scores files: plausible values
	cap confirm file w031-`domain'-pv.dta 
	if _rc~=0 {
		clear	
		runmplus_load_savedata , out(model`domain'bayespv.out) m(1)
		keep rnjid  `pv_`domain'' 
		save w031-`domain'-pv.dta , replace
	}
	clear
	* post-process parameter estimates
	cap erase E1.dta
	cap erase E2.dta
	cap erase E3.dta
	clear
	matsave E1
	gen model=1 // "WLSMV-theta"
	save E1.dta , replace
	clear
	matsave E2
	gen model=2 // "MLR(probit)"
	save E2.dta , replace
	clear
	matsave E3
	gen model=3 // "Bayes"
	save E3.dta , replace

	use E1 , clear
	append using E2
	append using E3
	la def model 1 "WLSt" 2 "MLRpr" 3 "Bayes"
	la values model model
	save w031_`domain'_parameters.dta , replace

}


clear
use w031-gcp-eap.dta , clear
rename exf gexf
rename lfl glfl
rename mem gmem
cap rename exf_se gexf_se
cap rename lfl_se glfl_se
cap rename mem_se gmem_se
foreach var of varlist _all {
	la var `var' "EAP (multidimensional)"
}
merge 1:1 rnjid using w031-mem-eap.dta , nogen
merge 1:1 rnjid using w031-exf-eap.dta , nogen
merge 1:1 rnjid using w031-lfl-eap.dta , nogen
foreach var of varlist _all {
	local foo : var lab `var'
	if "`foo'"=="" {
	   la var `var' "EAP (single domain)"
	}
}
save w031-scores-eap.dta , replace

clear
use w031-gcp-pv.dta , clear
rename exfm1 gexfm1
rename lflm1 glflm1
rename memm1 gmemm1
foreach var of varlist _all {
	la var `var' "PV (multidimensional)"
}
merge 1:1 rnjid using w031-mem-pv.dta , nogen
merge 1:1 rnjid using w031-exf-pv.dta , nogen
merge 1:1 rnjid using w031-lfl-pv.dta , nogen
foreach var of varlist _all {
	local foo : var lab `var'
	if "`foo'"=="" {
	   la var `var' "PV (single domain)"
	}
}
save w031-scores-pv.dta , replace


use w031.dta , clear 
keep hhid pn rnjid 
merge 1:1 rnjid using w031-scores-eap.dta , nogen
merge 1:1 rnjid using w031-scores-pv.dta , nogen
drop rnjid 
order hhid pn
save w031-scores.dta , replace





