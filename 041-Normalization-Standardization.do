cap confirm file w041_output.dta
if _rc==0 {
	*exit 
}
************************************************************************
******
****** Compile data sources 
******
************************************************************************
* adapted from ../Norms-with-weights-202109/-105-call-source.do
* Data used in the normalization, standardization, adjustment
* Factor scores are in w031-scores.dta 
cap erase w041.dta 
use w031-scores.dta , clear 
* Norming sample in w017.dta 
merge 1:1 hhid pn using w017.dta 
save w041.dta , replace 
cap drop _merge 
save w041.dta , replace
* self-rated memory from core file 
use w015.dta , clear 
keep hhid pn pd102 
merge 1:1 hhid pn using w041.dta 
version 16: table _merge
keep if _merge==3 
cap drop _merge 
save w041.dta , replace 
* needs female, black and hispanic and schlyrs 
merge 1:1 hhid pn using w015_sex_race.dta , nogen 
save w041.dta , replace 
* need vdori1 and vdvis1
use w031.dta , clear 
keep hhid pn vdori1 vdvis1
merge 1:1 hhid pn using w041.dta , nogen 
save w041.dta , replace
* need hcap16wgt (from w011.dta)
use hhid pn hcap16wgt using w011.dta , clear 
merge 1:1 hhid pn using w041.dta , nogen 
save w041.dta , replace





***********************************************************************
******
****** Create variables norms-weigh-weights
******
************************************************************************
* adapted from /Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP23/POSTED/ANALYSIS/Norms-with-weights-202109/-110-create-variables.do

use w041.dta , clear
la var normexcld "Excluded from normative sample"
la def normexcld 0 "Not excluded" 1 "Excluded"
la val normexcld normexcld

cap drop agegroup
cap drop agetrim
cap drop rage*
cap la drop vl

gen agetrim=min(hcapage,99) 
bracket agetrim , units(5) start(65)
rename agetrim_bracket agegroup
la def vl  7 "[95+" , modify
la def vl  0 "<65" , modify
replace agegroup=0 if hcapage<65
tabulate agegroup
la var agegroup "Age group at HCAP"
tabulate agegroup


gen rage=hcapage
local foo : var lab hcapage
la var rage "[hcpage] `foo'"
contents rage


foreach x in 75 85 {
	gen rage`x'=`x' if missing(rage)~=1
	gen ragec`x'=rage-rage`x' if missing(rage)~=1
	gen raged`x'=rage>`x' if missing(rage)~=1
	gen ragei`x'=ragec`x'*raged`x'
	local table "`table' mean ragei`x')"
}

* here is a reference to a random component that will 
* possibly be different in the 2023 replication
forvalues j=1/6 {
	gen random`j'=invnorm(uniform())
	la var random`j' "Normal random variable number `j'"
}

vlabel female Men Women
vlabel black All_other_racial_groups Black_or_African_American
vlabel hisp All_other_ethnicity_groups Hispanic_or_Latinx


* Age*Sex*Race
gen _agegroup = 1 if rage<=74
replace _agegroup = 2 if inrange(rage,75,84)
replace _agegroup = 3 if rage>=84 & missing(rage)~=1
vlabel _agegroup under_75 75_to_84 85_and_over
table _agegroup

cap drop _demgroup
gen _demgroup=1     if female==0 & black==0 & hisp==0
replace _demgroup=2 if female==1 & black==0 & hisp==0
replace _demgroup=3 if female==0 & black==1 & hisp==0
replace _demgroup=4 if female==1 & black==1 & hisp==0
replace _demgroup=5 if female==0 & black==0 & hisp==1
replace _demgroup=6 if female==1 & black==0 & hisp==1
vlabel _demgroup WM WF BM BF HM HF
table _demgroup

* Education levels
gen edcat=.
replace edcat = 1 if inrange(schlyrs,0,8)
replace edcat = 2 if inrange(schlyrs,9,11)
replace edcat = 3 if inrange(schlyrs,12,12)
replace edcat = 4 if inrange(schlyrs,13,15)
replace edcat = 5 if inrange(schlyrs,16,16)
replace edcat = 6 if schlyrs>16 & missing(schlyrs)~=1
label var edcat "Education level"
vlabel edcat schlyrs_0-8 schlyrs_9-11 schlyrs_12 schlyrs_13-15 schlyrs_16 schlyrs_17up
sort normexcld
version 16: by normexcld: table edcat, c(min schlyrs max schlyrs n schlyrs)

save w041.dta , replace



***********************************************************************
******
****** Standardize cognition scores
******
************************************************************************
* adapted from /Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP23/POSTED/ANALYSIS/Norms-with-weights-202109/-111-standardize-cognition-scores.do

use w041.dta , clear

* ### Normalizing, adjusting, and standardizing cognition scores
*
* The estimated factor scores, from the factor analysis work, are on
* an arbitrary scale. We desired to produce scores that adjusted for
* the effect of demographic variables in the norming sample and
* were on a more interpretable scale.
*
* We accomplish this by placing the scores on a T-score metric. 
* A T-score metric has a mean of 50 and standard deviation of 10.
* T-score metrics are often used in health research settings.
*
* We use a regression adjustment procedure to account for the
* effect of demographic variables on test scores.
*
* We use a rank-based normalizing transformation to accomplish two
* goals. First, the transformation limits the possibility of
* obtaining out-of-range values from the adjustment procedure. Second,
* the normalizing transformation makes it easy to identify
* persons falling below a fixed threshold (in our case, 1.5 SD, or a 
* T score of 35) below the mean in the norming sample.
*
* These are the steps in generating standardized scores:

* 1. Raw score is rank-normalized
*    Each factor score estimate is subject to a rank-based normalizing
*    transformation (Blom transformation) within the sample of persons
*    selected for generating norms (the norming sample).
*
*    The reason for the Blom transformation is: In the next step
*    I will be regressing (Blom-transformed) observed score performance 
*    on demographic variables. The normalizing transformation helps make 
*    sure that the predicted values from this regression model do not 
*    lead to implausible values
*
* 2. Model back-translation of rank-normalized and raw scores in norming sample
*    I regress the Blom-transformed score back on to the 
*    original factor score estimate using a restricted cubic spline
*    with four knots. This regression model is used to generate
*    Blom transformed factor scores in the norming sample and
*    the non-norming sample and any future observation(s). This
*    step is necessary because the Blom transformation is dependent
*    upon the sample in which it is derived. By generating this
*    regression model, I can produce Blom-transformed scores in
*    any future sample that reflect the distribution of scores
*    observed in the norming sample, regardless of the distribution
*    of scores in the new sample. Using restricted cubic splines
*    allows a flexible curve shape and typically very high
*    predictive accuracy (e.g., for memory plausible values
*    the model r-squared is 0.9995, both have means of 0 and 
*    standard deviations of 0.999, and the plausible value
*    range is from -3.42 to +3.42 and the predicted range
*    is from -3.48 to 3.30
* 
* 3. Regression adjustment
*    Regress each Blom-transformed factor score (separately) on age, sex, 
*    race, Hispanic ethnicity, and educational attainment. 
*
*    Age is modeled as a continuous predictor using restricted cubic 
*    splines with knots at 70, 78, 86, 94 (on a range of 65-103). These 
*    knots were chosen ad hoc using an empirical process, and fall at 
*    the 25th, 60th, 88th, and 99th percentiles of \verb+hcapage+.

*    The somewhat unusual choice of knot locations is driven by the 
*    cross-sectional relationship between age and cognitive test score. 
*    The shape is distinctly hockey-stick-shaped relationship where a 
*    nearly linear performance-age relationship is seen through most of 
*    the age range (older people performing worse) but then the direction 
*    shifts and older people perform better. 
*
*    This effect is likely caused by the retention of only the most
*    cognitively-intact persons among the oldest-old following our
*    exclusions from the norming sample. The knot choice is meant to get 
*    more parameters estimated in the region where the age-performance 
*    relationship is more dynamic.
*
*    Sex is modeled as male and female using a dummy variable
*
*    Race and ethnicity are coarsely modeled with two dummy variables,
*    one indicating Black or African-American, the other Hispanic ethnicty.
*
*    Education is included as a continuous predcitor (0-17). 
*
*           Note: we compared different ways for controlling for education
*              - A continuous variable (0-17)
*              - A categorical predictor identifying the following 
*                groups defined in terms of years of completed schooling: 
*                    0, 1-8, 9-11, 12, 13-15, 16, 17 and higher
*              - A restricted cubic spline with 4 knots placed at default 
*                locations
*              - A set of models including two linear splines with knots 
*                placed from 4 to 15 years
*                
*              To evaluate these alternative parameterizations, we 
*              regressed the estimated GCP (EAP), GCP (PV), MEM (EAP), 
*              LFL (EAP), vdori1, vdvis1, h1rmseotal on each of the above 
*              representations of education. For all except vdori1 and 
*              h1rmseotal the model with the lowest BIC was the continuous 
*              linear function of number of years of education. 
*              Orientation favored two linear splines with a knot at 13 
*              years of education, and the MMSE (h1rmsetotal) preferred the 
*              restricted cubic splines.
*
*              Based on the predominance of evidence, we decided to keep 
*              education as a continuous predictor.
*										  
*    Main effects and two-way interactions} are included. The only
*    two-way interaction that is not included is black*hisp, because
*    in sample there are no persons both Black and Hispanic.
*
* 4. Compute an expected score for every combination of age, sex, 
*    education level, and race/ethnicity using the results of the 
*    regression model. 
*
* 5. Compute an adjusted score for each person as their observed score 
*    minus their expected score given age, sex, education level, and 
*    race/ethnicity.
*
* 6. Compute an adjusted, standardized score as their observed minus 
*    expected score, all divided by the standard error of estimate 
*    from the regression model, which is the overall sample standard 
*    deviation of the raw score multiplied by $\sqrt{1-R^2}$ where
*    $R^2$ is the r-squared from the adjustment model in the norming 
*    sample.
* 
* 7. Compute an adjusted, standardized, and scaled score as the
*   adjusted, standardized score (from step 6) multiplied by 10, plus 50, 
*   and rounded to the nearest integer. This places the standardized score 
*   on a roughly T-score metric.
*
*   Rounding and thresholds - We round all factor scores - after transformation - 
*   to the nearest whole number, which provides two digits precision.
*   Note that the 7.5th percentile for a T score is a value of 35.6. 
*   Since we are rounding to the nearest whole number, a T-score scaled 
*   factor score of 36 or higher will be considered above threshold, 
*   and a factor score of 35 or below will be considered below
*   threshold.
* 

local memlab "Memory"
local exflab "Executive functioning"
local lfllab "Language, fluency"
local orilab "Orientation"
local vislab "Visuospatial"
local gcplab "General cognitive performance"

local memdesc "Memory is a factor score estimated from delayed recall and recognition tasks of episodic memory (10 word delayed recall, 3 word delayed recall, Logical Memory II, story recall (EBMT), 10 word recognition and Logical Memory recognition)."

local exfdesc "Executive functioning is a factor score estimated from attention and speed tasks, set shifting tasks, and logical reasoning tasks, including Standard Progressive Matrices, HRS number series, trail making (part A \& B), Symbol Digit Modalities Test, Backwards spelling, Backwards counting, and letter cancellation."

local lfldesc "Language, fluency is a factor score estimated from animal naming, object naming (two objects from TICS), two objects from MMSE, objects from the CSI-D, sentence writing, and read and follow command."

local oridesc "Orientation is not a factor score, but is the observed performance on 10 orientation to time and place items from the Mini-Mental State Examination. For ease of interpretation the observed score is placed on a T-score metric and standardized in the HCAP normative sample. No Bayesian plausible values are estimated for this score."

local visdesc "Visuospatial is not a factor score, but is the observed performance on a constructional praxis (immediate) task. For ease of interpretation the observed score is placed on a T-score metric and standardized in the HCAP normative sample. No Bayesian plausible values are estimated for this score."

local gcpdesc "The GCP (General cognitive performance) score is a second order factor score estimate derived from a model with first-order factors for orientation, memory, executive functioning, language/fluency, and visuospatial functioning."

* scores 
local memscores "gmemm1 memm1 gmem mem"
local exfscores "gexfm1 exfm1 gexf exf "
local lflscores "glflm1 lflm1 glfl lfl "
local oriscores "vdori1"
local visscores "vdvis1"
local gcpscores "gcpm1 gcp h1rmsetotal"

local gmemm1lab "Memory factor score from second-order factor model, estimated as a plausible value (draw from posterior)"
local memm1lab "Memory factor score from single-factor model, estimated as a plausible value (draw from posterior)"

* Key to various scores and tests used in normalization and standardization
*
*  Name        Domain      Model               Flavor 
* ------------+-----------+-------------------+----------------
*  gmemm1      Memory      Second order model  PV 
*  memm1                   Single factor       PV 
*  gmem                    Second order        EAP 
*  mem                     Single factor       EAP 
*
*  gexfm1      Executive   Second order        PV 
*  exfm1                   Single factor       PV 
*  gexf                    Second order        EAP 
*  exf                     Single factor       EAP 
*
*  glflm1      Language    Second order        PV 
*  lflm1                   Single factor       PV
*  glfl                    Second order        EAP
*  lfl                     Single factor       EAP
*
*  vdori1      Orientation Sum of correct      Not applicable 
*
*  vdvis1      Visuospatial CERAD construc-
*                           tional praxis      Not applicable 
*  
*  gcpm1       Global       Second order       PV 
*  gcp                      Second order       EAP 
*  h1rmsetotal MMSE         Total score        Not applicable 
*              score &      NA \\
* ------------+-----------+-------------------+----------------
* Note: EAP, Expected a posteriori; PV, Bayesian plausible value.

* I will pre-pend a "T" to the front of a source estimate (e.g., 
* Tgmemm1 to indicate the T-score (mean 50, sd 10) standardized 
* and normalized estimate. These variables have been rank normalized, 
* adjusted for demographics, and standardized  T-score metric 
* (in the normative sample)

* I will pre-pend a "IMPAIRED" to the front of a source estimate 
* (e.g., IMPAIRED_gmemm1) to identify dummy variables that indicate 
* if a person has scored less than 36 on the normalized, adjusted, 
* and standardized estimate.

* Adjust for age using cubic splines
* I will place knots at 75, 85 and 95
cap erase gen_spage_from_age.do
rdoc init gen_spage_from_age.do
local y "hcapage"
local spage_knot1 = 70
local spage_knot2 = 78
local spage_knot3 = 86
local spage_knot4 = 94
r gen spage1=`y'
r gen spage2 = (max((`y'-`spage_knot1')^3,0)-(`spage_knot4'-`spage_knot3')^-1 * (max((`y'-`spage_knot3')^3,0)*(`spage_knot4'-`spage_knot1')-max((`y'-`spage_knot4')^3,0)*(`spage_knot3'-`spage_knot1'))) / (`spage_knot4'-`spage_knot1')^2 if missing(`y')~=1
r gen spage3 = (max((`y'-`spage_knot2')^3,0)-(`spage_knot4'-`spage_knot3')^-1 * (max((`y'-`spage_knot3')^3,0)*(`spage_knot4'-`spage_knot2')-max((`y'-`spage_knot4')^3,0)*(`spage_knot3'-`spage_knot2'))) / (`spage_knot4'-`spage_knot1')^2 if missing(`y')~=1
r * have a nice day
rdoc close

include gen_spage_from_age.do

cap macro drop _Tlist
cap macro drop _IMPAIREDlist

* loop over each score
foreach x in mem exf lfl ori vis gcp {
	foreach y in ``x'scores' {
		di in red "* =============================================" _n _n _col(10) "`y'" _n _n "* ============================================="
		* blom transformation
		cap drop `y'_blom
		* the blom command is a custom ado created by Rich Jones
		blom `y' if normexcld==0
		* model Blom-transformed score as a function of observed score
		* Use restricted cubic spline
		* This model will be used to convert observed factor scores
		* to Blom-transformed factor scores within and outside of 
		* the norming sample
		cap drop sp`y'*
		* with 4 splines the default location are at the 5, 35, 65, and 95th percentiles)
		* 4 knots makes 3 variables
		if "`y'"~="vdori1" {
		    mkspline sp`y' = `y' if normexcld==0 , cubic displayknots nk(4)
			local sp`y'_knot1 = r(knots)[1,1]
			local sp`y'_knot2 = r(knots)[1,2]
			local sp`y'_knot3 = r(knots)[1,3]
			local sp`y'_knot4 = r(knots)[1,4]
			cap erase gen_`y'_blom_from_`y'.do
			rdoc init gen_`y'_blom_from_`y'.do
			r gen sp`y'1=`y'
			r gen sp`y'2 = (max((`y'-`sp`y'_knot1')^3,0)-(`sp`y'_knot4'-`sp`y'_knot3')^-1 * (max((`y'-`sp`y'_knot3')^3,0)*(`sp`y'_knot4'-`sp`y'_knot1')-max((`y'-`sp`y'_knot4')^3,0)*(`sp`y'_knot3'-`sp`y'_knot1'))) / (`sp`y'_knot4'-`sp`y'_knot1')^2 if missing(`y')~=1
	 		r gen sp`y'3 = (max((`y'-`sp`y'_knot2')^3,0)-(`sp`y'_knot4'-`sp`y'_knot3')^-1 * (max((`y'-`sp`y'_knot3')^3,0)*(`sp`y'_knot4'-`sp`y'_knot2')-max((`y'-`sp`y'_knot4')^3,0)*(`sp`y'_knot3'-`sp`y'_knot2'))) / (`sp`y'_knot4'-`sp`y'_knot1')^2 if missing(`y')~=1
			*** Since this "do" file is called below ("include gen_`y'_blom_from_`y'.do")
			*** the code as written probably works as intended, but the 
			*** do file is not as intended: I wanted the regression parameter estimates hard
			*** coded into the do file so that the programs could be reused.
			*** Here is the start of my correction
	        reg `y'_blom sp`y'1 sp`y'2 sp`y'3 [fw=hcap16wgt]
			local b0 = _b[_cons]
			local b1 = _b[sp`y'1]
			local b2 = _b[sp`y'2]
			local b3 = _b[sp`y'3]
			r gen P`y'_blom = `b0'+sp`y'1*`b1'+sp`y'2*`b2'+sp`y'3*`b3'
			macro drop b0
			macro drop b1
			macro drop b2
			macro drop b3
			predict p`y'_blom
			r * have a nice day
			rdoc close
			* check my math					 
			su sp`y'* p`y'_blom
			drop sp`y'*
			include gen_`y'_blom_from_`y'.do
			su sp`y'* P`y'_blom if normexcld==0
			su sp`y'* P`y'_blom 
			* store the observed standard deviation (should be very close to 1)
			su P`y'_blom if normexcld==0
			local sd_P`y'_blom = `r(sd)'
			cap erase genT`y'.do

            tempname genT 
			file open `genT' using genT`y'.do , write text replace 
			file write `genT' "* local sd_P`y'_blom = `sd_P`y'_blom'" _n

			cap confirm file P`y'_blom.dta 
			if _rc~=0 {
				preserve
				keep P`y'_blom spage* female black hisp schlyrs hcapage normexcld hhid pn hcap16wgt
				drop normexcld // can't share normexclud as it encodes Medicare data
				save P`y'_blom.dta , replace
				outputst P`y'_blom.sas7bdat , replace 
				restore			
			}
			* regression
			reg P`y'_blom (c.spage1 c.spage2 c.spage3)##(c.female c.black c.hisp c.schlyrs) c.female#(c.black c.hisp c.schlyrs) c.schlyrs#(c.black c.hisp) [fw=hcap16wgt] if normexcld==0
			reg , coeflegend		
			estimates store `y'	
			local r2`y' = `e(r2)'
			local r2`y' = `e(r2)'
			file write `genT' "* local r2`y' = `e(r2)'" _n
			file close `genT' 
			gen E`y'_blom = _b[_cons] //  black=0, hisp=0, female=0
			replace E`y'_blom = E`y'_blom + spage1*_b[spage1]
			replace E`y'_blom = E`y'_blom + spage2*_b[spage2]
			replace E`y'_blom = E`y'_blom + spage3*_b[spage3]
			replace E`y'_blom = E`y'_blom + female*_b[female]
			replace E`y'_blom = E`y'_blom + black*_b[black]
			replace E`y'_blom = E`y'_blom + hisp*_b[hisp]
			replace E`y'_blom = E`y'_blom + (spage1*female)*_b[c.spage1#c.female]
			replace E`y'_blom = E`y'_blom + (spage1*black)*_b[c.spage1#c.black]
			replace E`y'_blom = E`y'_blom + (spage1*hisp)*_b[c.spage1#c.hisp]
			replace E`y'_blom = E`y'_blom + (spage2*female)*_b[c.spage2#c.female]
			replace E`y'_blom = E`y'_blom + (spage2*black)*_b[c.spage2#c.black]
			replace E`y'_blom = E`y'_blom + (spage2*hisp)*_b[c.spage2#c.hisp]
			replace E`y'_blom = E`y'_blom + (spage3*female)*_b[c.spage3#c.female]
			replace E`y'_blom = E`y'_blom + (spage3*black)*_b[c.spage3#c.black]
			replace E`y'_blom = E`y'_blom + (spage3*hisp)*_b[c.spage3#c.hisp]
			replace E`y'_blom = E`y'_blom + (female*black)*_b[c.female#c.black]
			replace E`y'_blom = E`y'_blom + (female*hisp)*_b[c.female#c.hisp]
			replace E`y'_blom = E`y'_blom + schlyrs*_b[c.schlyrs]
			replace E`y'_blom = E`y'_blom + schlyrs*spage1*_b[c.schlyrs#c.spage1]
			replace E`y'_blom = E`y'_blom + schlyrs*spage2*_b[c.schlyrs#c.spage2]
			replace E`y'_blom = E`y'_blom + schlyrs*spage3*_b[c.schlyrs#c.spage3]
			replace E`y'_blom = E`y'_blom + schlyrs*female*_b[c.schlyrs#c.female]
			replace E`y'_blom = E`y'_blom + schlyrs*black*_b[c.schlyrs#c.black]
			replace E`y'_blom = E`y'_blom + schlyrs*hisp*_b[c.schlyrs#c.hisp]
			rdoc init gen_E`y'_blom.do , replace
			local foo = _b[_cons]
			r gen E`y'_blom = `foo' //  black=0, hisp=0, female=0
			local foo = _b[spage1]
			r replace E`y'_blom = E`y'_blom + spage1*`foo'
			local foo = _b[spage2]
			r replace E`y'_blom = E`y'_blom + spage2*`foo'
			local foo = _b[spage3]
			r replace E`y'_blom = E`y'_blom + spage3*`foo'
			local foo = _b[female]
			r replace E`y'_blom = E`y'_blom + female*`foo'
			local foo = _b[black]
			r replace E`y'_blom = E`y'_blom + black*`foo'
			local foo = _b[hisp]
			r replace E`y'_blom = E`y'_blom + hisp*`foo'
			local foo = _b[c.spage1#c.female]
			r replace E`y'_blom = E`y'_blom + (spage1*female)*`foo'
			local foo = _b[c.spage1#c.black]
			r replace E`y'_blom = E`y'_blom + (spage1*black)*`foo'
			local foo = _b[c.spage1#c.hisp]
			r replace E`y'_blom = E`y'_blom + (spage1*hisp)*`foo'
			local foo = _b[c.spage2#c.female]
			r replace E`y'_blom = E`y'_blom + (spage2*female)*`foo'
			local foo = _b[c.spage2#c.black]
			r replace E`y'_blom = E`y'_blom + (spage2*black)*`foo'
			local foo = _b[c.spage2#c.hisp]
			r replace E`y'_blom = E`y'_blom + (spage2*hisp)*`foo'
			local foo = _b[c.spage3#c.female]
			r replace E`y'_blom = E`y'_blom + (spage3*female)*`foo'
			local foo = _b[c.spage3#c.black]
			r replace E`y'_blom = E`y'_blom + (spage3*black)*`foo'
			local foo = _b[c.spage3#c.hisp]
			r replace E`y'_blom = E`y'_blom + (spage3*hisp)*`foo'
			local foo = _b[c.female#c.black]
			r replace E`y'_blom = E`y'_blom + (female*black)*`foo'
			local foo = _b[c.female#c.hisp]
			r replace E`y'_blom = E`y'_blom + (female*hisp)*`foo'
			local foo = _b[c.schlyrs]
			r replace E`y'_blom = E`y'_blom + schlyrs*`foo'
			local foo = _b[c.schlyrs#c.spage1]
			r replace E`y'_blom = E`y'_blom + schlyrs*spage1*`foo'
			local foo = _b[c.schlyrs#c.spage2]
			r replace E`y'_blom = E`y'_blom + schlyrs*spage2*`foo'
			local foo = _b[c.schlyrs#c.spage3]
			r replace E`y'_blom = E`y'_blom + schlyrs*spage3*`foo'
			local foo = _b[c.schlyrs#c.female]
			r replace E`y'_blom = E`y'_blom + schlyrs*female*`foo'
			local foo = _b[c.schlyrs#c.black]
			r replace E`y'_blom = E`y'_blom + schlyrs*black*`foo'
			local foo = _b[c.schlyrs#c.hisp]
			r replace E`y'_blom = E`y'_blom + schlyrs*hisp*`foo'
			r 
			rdoc close 
			file open `genT' using genT`y'.do , write text append 
			gen T`y'= 50+10*((P`y'_blom-E`y'_blom)/(`sd_P`y'_blom'*sqrt(1-`r2`y''))) // SEE
			file write `genT' "T`y'= 50+10*((P`y'_blom-E`y'_blom)/(`sd_P`y'_blom'*sqrt(1-`r2`y'')))" _n
			file write `genT' "* have a nice day" _n
			file close `genT' 
			local Tlist "`Tlist' T`y'"
			gen IMPAIRED_`y' = T`y'<36 if missing(T`y')~=1
			local IMPAIREDlist "`IMPAIREDlist' IMPAIRED_`y'"
			local foo : var lab `y'
			la var T`y' "Standardized, group-normalized `foo'"
			la var IMPAIRED_`y' "Std, group-normed `foo' is less than 36"
		}
	}
}

qui {
	noisily di in green "R-squared values for demographic models" _n "============================================="
	foreach x in mem exf lfl ori vis gcp {
		foreach y in ``x'scores' {
			if "`r2`y''"~="" {
				noisily di in green "R2 `y'" in yellow _col(15) %3.2f `r2`y'' _col(25) %4.3f sqrt(1-`r2`y'')
			}
		}
	}
}


* Some statistics in the normative sample
su `Tlist' if normexcl==0 [fw=hcap16wgt]


* Some statistics in both samples
sort normexcl 
version 16: by normexcl : su `Tlist' [fw=hcap16wgt]

* Impairment
* Percent impaired (having normalized, adjusted, standardized score less than 36)\\[.5cm]
* NB: These numbers reflect sampling weight (hcap16wt).
version 16: by normexcl : su `IMPAIREDlist'  [fw=hcap16wgt]

save w041_output.dta , replace


