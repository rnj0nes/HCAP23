cap confirm file w021.dta 
if _rc==0 {
   exit 
}
* Rich Jones
* 2023-07-26
* 021-Create-HCAP-cognitive-indicators.do
* ---------------------------------------
* This program takes public HCAP respondent data 
* and generates indicator variables for factor analysis models
* ---------------------------------------
* Adapted from 
* /Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP/POSTED/ANALYSIS/CFA-HCAP/-110-create-variables.do
* and
* /Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP/POSTED/ANALYSIS/CFA-HCAP/-206-refine-variables.do

use w011.dta , clear 
* keep a running list of created variables in local "varlist"
local varlist ""

* =========================================================
* Orientation
* ---------------------------------------------------------
* MMSE 10 items
local var "vdori1"
local `var'_domain "Orientation"
local `var'_lab "MMSE 10 items (number of correct, 0-10)"
cap macro drop _`var'_source
local sc="1"
foreach x in t p {
    if "`x'"=="p" {
        local sc="i"
    }
    foreach j in 1 2 3 4 5 {
       local `var'_source "``var'_source' r`sc'orient_`x'`j'"
    }
}
cap drop `var'
scoreit ``var'_source' , ///
   indicator(1) /// counting correct responses
   missinglist(97 98 99) /// responses treated as missing
   minitems(1) all /// must have at least 1 item
   gen(`var') // name of variable 
local `var'_tx "sum of correct source items"
local `var'_alpha  : di %5.3f `r(alpha)' 
la var `var' "``var'_lab'"
local `var'_note "*`var'* captures orientation to time and place using 10 items from the MMSE. It is coded as the sum of the number of MMSE orientation items (*``var'_source''*) that have a value of 1, with 97, 98, and 99 responses treated as missing values. Persons who do not have at least 1 item in the list that has a response of 1 or 5 are treated as missing. This sum has a Cronbach's alpha of ``var'_alpha'." 
local varlist "`varlist' `var'"

* =========================================================
* Memory
* ---------------------------------------------------------
* CERAD WORD LIST DELAYED
local var "vdmde1" 
local `var'_lab "CERAD word list delayed (0-10)"
local `var'_source "r1word_dscore"
local `var'_domain "Memory, delayed episodic"
cap drop `var'
gen `var' = ``var'_source' if inlist(``var'_source',97,98,99)~=1
replace `var'=. if r1fword_dscore==1 // missing if imputed
local `var'_tx "restriction of source"
la var `var' "``var'_lab'"
local `var'_alpha  "NA"
local `var'_note "*`var'* is the number correct on the CERAD delayed 10 word recall task. It is simply a renaming of *``var'_source'*. **Special handling** if the HRS variable *r1fword_dscore* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing." 
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* LOGICAL MEMORY DELAYED
local var "vdmde2" 
local `var'_lab "Logical memory delayed (0-25)"
local `var'_source "r1lmb_delscore"
local `var'_domain "Memory, delayed episodic"
gen `var' = ``var'_source' if inlist(``var'_source',97,98,99)~=1
replace `var'=. if r1flmb_delscore==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "*`var'* is the number correct on the WMS-IV Logical Memory I delayed story recall task. There are 25 story points to be recalled, and the source variable is the sum of these that are recalled. *`var'* is basically a renaming of *``var'_source'*. **Special handling:** if the HRS variable *r1flmb_delscore* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing." 
local varlist "`varlist' `var'"


* ---------------------------------------------------------
* MMSE 3 word delayed recall
local var "vdmde3" 
local `var'_lab "MMSE 3 word delayed recall (0-3)"
local `var'_source "r1dlrc3"
local `var'_domain "Memory, delayed episodic"
cap drop `var'
gen `var' = ``var'_source' if inlist(``var'_source',97,98,99)~=1
* There is no imputation flag for the source variable
local `var'_tx "restriction and recoding of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "*`var'* represents the number of words recalled after a delay on the MMSE 3 word list. It is simply a recoded version of the original variable *``var'_source'*, with responses of 97, 98 , 99 treated as missing." 
local varlist "`varlist' `var'"
* Refinement
* vdmde3 MMSE 3 word delayed recognition
clonevar vvdmde3o=vdmde3
recode vdmde3 (0=0)(1=0)(2=1)(3=2)
vlabel vdmde3 "0-1" "2" "3"
local vdmde3_note "`vdmde3_note' To address maldistribtion, observed values of 0 and 1 are scored 0, observed values of 2 are scored 1, and observed values of 3 are scored 2. Note that in Jones et al (2023) there was a mistake and 3's were recoded to 1."

* ---------------------------------------------------------
* PRAXIS RECALL
local var "vdmde4" 
local `var'_lab "CERAD constructional praxis delayed (0-11)"
local `var'_source "r1cpdel_score"
local `var'_domain "Memory, delayed episodic"
cap drop `var'
gen `var' = ``var'_source' if inlist(``var'_source',97,98,99)~=1
replace `var'=. if r1fcpdel_score==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "*`var'* is the number correct shapes drawn from memory after a delay on the CERAD Constructional Praxis task. This is a delayed recall of the geometric shapes drawn in the test of CERAD Constructional Praxis (immediate) task. Respondents are asked to draw the shapes from earlier in the interview to the best of their memory. It is simply a renaming of ``var'_source'. **Special handling:** if the HRS variable *r1fcpdel_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing." 
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* Brave Man Delayed 
local var "vdmde5"
local `var'_lab "Brave man delayed score (0-12)"
local `var'_source "r1bm_delscore"
local `var'_domain "Memory, delayed episodic"
cap drop `var'
gen `var' = ``var'_source' if inlist(``var'_source',97,98,99)~=1
replace `var'=. if r1fbm_delscore==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "This item *`var'* is simply a renaming of *``var'_source'*. No accomodation for missing or other non-response codes has been used. **Special handling:** if the variable *r1fbm_delscore* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* CERAD WORD LIST Recognition Task
local var "vdmre1" 
local `var'_lab "CERAD word list recognition task (0-20)"
local `var'_source "r1wlrec_totscore"
local `var'_domain "Memory, recognition"
cap drop `var'
gen `var' = ``var'_source' if inlist(``var'_source',97,98,99)~=1
replace `var'=. if r1fwlrec_totscore==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha =  "NA"
la var `var' "``var'_lab'"
local `var'_note "This item *`var'* is simply a renaming of *``var'_source'*. No accomodation for missing or other non-response codes has been used. **Special handling:** if the variable *r1fwlrec_totscore* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* =========================================================
* Memory: recognition ---------------------------------------------------------
* Logical memory recognition
local var "vdmre2" 
local `var'_lab "Logical memory recognition (0-15)"
local `var'_source "r1lmb_recoscore"
local `var'_domain "Memory, recognition"
cap drop `var'
gen `var' = ``var'_source' if inlist(``var'_source',97,98,99)~=1
replace `var'=. if r1flmb_recoscore ==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "*`var'* is the number correct on the WMS-IV Logical Memory I story recognition task. It is simply a renaming of *``var'_source'* but missing codes (97, 98, 99) are treated as missing. **Special handling:** if the  variable *r1flmb_recoscore* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"


* =========================================================
* Executive Function 
* ---------------------------------------------------------
* ---------------------------------------------------------
* Raven's progressive matrices
local var "vdexf1"
local `var'_lab "Raven's progressive matrices"
local `var'_source "r1rv_score"
local `var'_domain "Executive function"
cap drop `var'
gen `var' = ``var'_source' if inlist(``var'_source',97,98,99)~=1
replace `var'=. if r1frv_score ==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "*`var'* is the score from Raven's progressive matrices. It is based only on *``var'_source'* **Special handling:** if the  variable *r1frv_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* Number series
local var "vdexf7"
local `var'_lab "HRS Number Series"
local `var'_source "r1ns_score"
local `var'_domain "Executive function"
cap drop `var'
gen `var'=``var'_source' if ``var'_source' < 996
replace `var'=. if r1fns_score ==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "This is from the *2016 Harmonized Cognitive Assessment Protocol (HCAP) Study Protocol Summary*: Developed for the HRS, this section evaluates Respondents ability for numeric reasoning by presenting a series of 6 individual series of numbers, where one or two numbers in the series is missing. The Respondent is asked to take as much time as s/he needs, with the help of scrap paper and a pencil, to identify the missing number/s. This test is a block-adaptive test. Respondents are given a set of three number series questions of varying difficulty to first complete. Based on the number of correct responses in this first set of three (score Range = 0 to 4), Respondents are then assigned to a second set of three questions, for which the difficulty level is based on the number correct on the first set. The HRS uses two versions of the Number Series questions and respondents are assigned to the version that was not done in the previous wave. For HRS-HCAP, Respondents were assigned to the Number Series that was not assigned in the 2016 Core interview. If a Respondent was not able to do the Number Series section in the 2016 Core interview (not able to do practice questions, was too confused), then they were skipped out of this section. In creating *`var'*, missing codes (codes 996 and higher) on the source variable *``var'_source'* are treated as system missing.  **Special handling:** if the  variable *r1fns_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* Trails A
local var "vdasp2"
local `var'_lab "Trails A"
local `var'_source "r1tma_score"
local `var'_domain "Attention, speed"
gen `var'=1-(log(``var'_source')/log(300)) if ``var'_source'<996
replace `var'=. if r1ftma_score ==1 // missing if imputed
local `var'_tx "restriction and transformation of source"
local `var'_alpha "NA"
la var `var' "``var'_lab'"
local `var'_note "*`var'* is calculated as $$1-\frac{\log (T_A)}{\log (300)}$$ where $T_A$ is the number of seconds needed to complete the Trails A task, and 300 is the ceiling on the number of seconds allowed to complete the task. The resulting score is 0 when the participant took 300 seconds to complete the task (or did not complete the task in 300 seconds and was assigned a score of 300), and 1 when the task was completed in 0 seconds (unsurprisingly, we do not observe scores of 1). The direction of this log transformed score is such that higher scores (approaching 1) are better and indicate faster performance. Missing codes (i.e., not between 0 and 300 on the source variables) are treated as missing. **Special handling:** if the  variable *r1ftma_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* Trailmaking part B
local var "vdexf2"
local `var'_lab "Trails B time"
local `var'_source "r1tmb_score"
local `var'_domain "Executive function"
cap drop _tmtbtime
gen _tmtbtime=1-(log(``var'_source')/log(300)) if ``var'_source'<990
gen `var'=_tmtbtime
replace `var'=. if r1ftmb_score ==1 // missing if imputed
local `var'_tx "restriction and transformation of source"
cap drop _tmtbtime
local `var'_alpha "NA"
la var `var' "``var'_lab'"
local `var'_note "*`var'* is computed as $$1-\frac{\log (T_B)}{\log (300)}$$ where $T_B$ is the number of seconds needed to complete the Trails B task, and 300 is the ceiling on the number of seconds allowed to complete the task. The resulting score is 0 when the participant took 300 seconds to complete the task (or did not complete the task in 300 seconds and was assigned a score of 300), and 1 when the task was completed in 0 seconds (unsurprisingly, we do not observe scores of 1). The direction of this log transformed score is such that higher scores (approaching 1) are better and indicate faster performance. Missing codes (i.e., not between 0 and 300 on the source variable(s)) are treated as missing. NB the reverse transformation is $300^{(1-B)}$ where $B$ is the log transformed, log-normalized complement number of seconds to complete the Trails B task. **Special handling:** if the  variable *r1ftmb_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* Symbol Digit
local var "vdasp1"
local `var'_lab "Symbol Digit Modalities Test score"
local `var'_source "r1dig_score"
local `var'_domain "Attention, speed"
cap drop `var'
gen `var' = ``var'_source'
replace `var'=. if r1fdig_score ==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "The varialbe *`var'* is simply a renaming of ``var'_source'. No accomodation for missing or other non-response codes has been used. Note that according to the *2016 Harmonized Cognitive Assessment Protocol (HCAP) Study Protocol Summary}, the SDMT score is the number of correct pairings minus any mistakes or skips. **Special handling:** if the  variable *r1fdig_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* MMSE-DLROW Spelling backwards
local var "vdasp3"
local `var'_lab "MMSE spell world backwards"
local `var'_source "r1backwards1 r1backwards2 r1backwards3 r1backwards4 r1backwards5"
local `var'_domain "Attention, speed"
cap drop `var'
scoreit ``var'_source' , ///
   indicator(1) /// count the 1's
   missinglist(97 98 99) /// responses treated as missing
   minitems(1) all /// must have at least 1 item
   gen(`var') // name of variable 
local `var'_alpha  : di %5.3f `r(alpha)' 
local `var'_tx "sum of correct source items"
la var `var' "``var'_lab'"
local `var'_note "*`var'*is the sum of 5 recorded responses to the MMSE spell world backwards task, recored with five correct/incorrect indicators. Only correct responses are summed (code 1 on source variables). At least 1 of the five indicators must have a non-missing code (not missing or 96, 97, 98, 99) to get the 0-5 score on *`var'*." 
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* Backwards counting
local var "vdasp4"
local `var'_lab "Backwards counting"
local `var'_source "r1bc_score"
local `var'_domain "Attention, speed"
cap drop `var'
gen `var'= ``var'_source' if ``var'_source'<96
replace `var'=. if r1fbc_score ==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "This is from the  *2016 Harmonized Cognitive Assessment Protocol (HCAP) Study Protocol Summary}: This test assesses speed and attention and is derived from the Backward Count measure in the MIDUS Study. Respondents are asked to begin at 100 and to count backwards as fast as possible. They are given 30 seconds and the number they reach and number of errors are recorded. The variable `var' is simply a renaming of the variable ``var'_source', with values greater than or equal to 96 treated as missing values. **Special handling:** if the  variable *r1fbc_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* Letter cancellation
local var "vdasp5"
local `var'_lab "Letter cancellation"
local `var'_source "r1lc_score"
local `var'_domain "Attention, speed"
cap drop `var'
gen `var'= ``var'_source' if ``var'_source'<96
replace `var'=. if r1flc_score ==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "This is from the  *2016 Harmonized Cognitive Assessment Protocol (HCAP) Study Protocol Summary}: This test has been included in ELSA and assesses attention and speed. Respondents are given a paper with a large grid of letters and are asked to scan the grid as quickly as possible in a minute and to cross out as many *P} and *W} letters as they can in that time. This variable (*`var'*, renamed and otherwise unchanged version of *``var'_source'+) is the number of correctly crossed-out letters. **Special handling:** if the  variable *r1fbc_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* =========================================================
* Language and fluency
* ---------------------------------------------------------
* Category (animal) fluency	H1RAFSCORE	language/fluency
local var "vdlfl1"
local `var'_lab "Category fluency (animals)"
local `var'_source "r1verbal_score"
local `var'_domain "Language, fluency"
cap drop `var'
gen `var'=``var'_source'
replace `var'=. if r1fverbal_score ==1 // missing if imputed
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "The created variable *`var' is simply a copied or renamed version of *``var'_source'*. **Special handling:** if the  variable *r1fverbal_score* has a value of 1, this implies that *``var'_source'* is imputed the created variable *`var'* is set to missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* TICS – Naming “scissors”, “cactus”	TICSNAMING	language/fluency
local var "vdlfl2"
local `var'_lab "Naming 2 items HRS TICS scissors, cactus"
local `var'_source "r1scis r1cactus"
local `var'_domain "Language, fluency"
cap drop `var'
scoreit ``var'_source' , ///
   indicator(1) /// count the 1's
   missinglist(7 8 9) /// responses treated as missing
   minitems(1) all /// must have at least 1 item
   gen(`var') // name of variable 
local `var'_alpha  : di %5.3f `r(alpha)'
la var `var' "``var'_lab'"
local `var'_note "This is the number of correct responses to the HRS TICS items name two objects (scisssor, cactus; ``var'_source' are the original items). Respondents must have at least 1 non-missing (not system missing, not 7, 8, 9) to get a score."
local varlist "`varlist' `var'"
* Refine variable 
recode vdlfl2 (0=0)(1=0)(2=1)
vlabel vdlfl2 "0-1" "2" 
local vdlfl2_note "`vdlfl2_note' To address maldistribtion, observed values of 0 and 1 are scored 0, observed values of 2 are scored 1."
local `var'_tx "recoded sum of correct responses in source items"


* ---------------------------------------------------------
* MMSE – Naming two objects “watch”, “pen”	
* MMSENAMING	language/fluency
local var "vdlfl3"
local `var'_lab "Naming 2 items MMSE"
local `var'_source "r1object1 r1object2"
local `var'_domain "Language, fluency"
cap drop `var'
scoreit ``var'_source' , ///
   indicator(1) /// count the 1's
   missinglist(97 98 99) /// responses treated as missing
   minitems(1) all /// must have at least 1 item
   gen(`var') // name of variable 
local `var'_alpha  : di %5.3f `r(alpha)'
la var `var' "``var'_lab'"
local `var'_note "This is the number of correct responses to the two MMSE name objects questions (``var'_source'). Respondents must have at least 1 non-missing (not system missing, not 97, 98, 99) to get a score." 
local varlist "`varlist' `var'"
* Refine
recode vdlfl3 (0=0)(1=0)(2=1)
vlabel vdlfl3 "0-1" "2"
local vdlfl3_note "`vdlfl3_note' To address maldistribtion, observed values of 0 and 1 are scored 0, observed values of 2 are scored 1."
local `var'_tx "recoded sum of correct responses in source items"

* ---------------------------------------------------------
* CSI-D score (sum of elbow, hammer, store, point)	H1R1066SCORE	language/fluency
local var "vdlfl6"
local `var'_lab "CSID object naming"
local `var'_source "r1csid_score"
local `var'_domain "Language, fluency"
cap drop `var'
gen `var'=``var'_source' 
replace `var'=. if r1fcsid_score==1 // missing if imputed
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "The created variable *`var'* is simply a copied or renamed version of *``var'_source'*, so long as (**Special handling**) the variable if r1fcsid_score is not equal to 1, as when it is it implies that ``var_source' was imputed. This variable is the number correct for CSID naming items (elbow, hammer, store, point)."
local varlist "`varlist' `var'"
* Refine
recode vdlfl6 (0=0)(1=0)(2=0)(3=1)(4=2)
vlabel vdlfl6 "0-2" "3" "4"
local vdlfl3_note "`vdlfl6_note' To address maldistribtion, observed values of 0-2 are scored 0, observed values of 2 are scored 1, and observed values of 4 are scored 2."
local `var'_tx "recoded sum of correct responses in source items"

* ---------------------------------------------------------
* MMSE – Sentence	H1RMSE21	language/fluency
local var "vdlfl4"
local `var'_lab "MMSE write a sentence"
local `var'_source "r1senten"
local `var'_domain "Language, fluency"
cap drop `var'
gen `var'=``var'_source'==1 if ``var'_source'<96
* There is no imputation flag for source variable
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "The variable `var' is an indicator as to whether  ``var'_source' is scored as correct (value 1). Missing codes (any value coded 96 or higher) are treated as missing."
local varlist "`varlist' `var'"

* ---------------------------------------------------------
* MMSE – Close eyes	H1RMSE17	language/fluency
local var "vdlfl5"
local `var'_lab "MMSE read and follow command"
local `var'_source "r1combfol"
local `var'_domain "Language, fluency"
cap drop `var'
gen `var'=``var'_source'==1 if ``var'_source'<96
* There is no imputation flag for source variable
local `var'_tx "restriction of source"
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "The variable `var' is an indicator as to whether  ``var'_source' is scored as correct (value 1). Missing codes (any value coded 96 or higher) are treated as missing"
local varlist "`varlist' `var'"

* =========================================================
* Visualspatial
* ---------------------------------------------------------
* Constructional praxis CERAD
local var "vdvis1"
local `var'_lab "CERAD Constructional praxis"
local `var'_source "r1cp_score"
local `var'_domain "Visuospatial"
cap drop `var'
gen `var' = ``var'_source'
replace `var'=. if r1fcp_score==1 // if imputed set to missing
local `var'_alpha  "NA"
la var `var' "``var'_lab'"
local `var'_note "*`var'* is CERAD constructional praxis immediate. The summary variable is a simple recode (for missing, other non-response codes as system missing) version of *``var'_source'*. **Special handling** if r1fcp_score is equal to 1, this indicates that ``var'_source' was imputed and `var' is therefore set to missing."
local varlist "`varlist' `var'"
local `var'_tx "restriction of source"

* ====================== END OF HCAP COGNITIVE ITEMS CODING 

* ============= SCALING OF INPUTS FOR FACTOR ANALYSIS MODEL
* Min-max normalization with custom ado "z1.ado"

local z1varlist ""

foreach var of varlist `varlist' {
	distinct `var'
	if `r(ndistinct)'<=10 {
		* do nothing, variable treated as categorical
	}
	if `r(ndistinct)'>10 {
		z1 `var'
		rename `var'_z1 `var'z
      local foo: var lab `var'z
      local foo = subinstr("`foo'","`var'_z1","`var'z",.)
      local foo = itrim("`foo'")
      la var `var'z "`foo'"
      local z1varlist "`z1varlist' `var'z" 
	}
}
* ======== END OF SCALING OF INPUTS FOR FACTOR ANALYSIS MODEL

aorder 
contents `varlist' `z1varlist'
local foo = wordcount("`varlist'")
di "`foo' variables in local varlist"

keep hhid pn `varlist' `z1varlist'
save w021.dta , replace 



