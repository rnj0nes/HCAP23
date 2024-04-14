{smcl}
{hline}
Help file for {hi:scoreit}
{hline}

{p 4 4 2}
Generate a sum score from a {it:variable list}. Intended for the automatic creation of 
additive summative scores from multiple item tests, instruments, questionnaires, rating
forms, etc. Options for handling missing data (mean imputation, prorating, imputation via
chained equations [stochastic single imputation]), scaling of the sum score, reverse 
coding items, indicator coding for items.


{p 8 17 2}
{cmd: scoreit} {it:varlist} [ if in ] , 
   {cmd:gen(}{it:string}{hi:)} [{cmd:replace}]
   [{cmd:prefix(}{it:string}{cmd:)} {cmd:suffix(}{it:string}{cmd:)}]
   [{cmd:f0 } {cmd:indicator(}{it:string}{hi:)} {cmd:reverse(}{it:varlist}{cmd:)}]
   [{cmd:all prorate meanimp ice } {cmd:missinglist(}{it:string}{hi:)} {cmd:minitems(}{it:string}{hi:)} {cmd:maxitemresponse(}{it:string}{hi:)}]
   [{cmd:z hz t iq} {cmd:to(}{it:string}{hi:)}]
 
{title: Options related to input and output variables}

{p 0 8 2}
{cmd:gen(}{it:string}{hi:)} - specify the variable to be created. 

{p 0 8 2}
{cmd:replace} - if the variable in gen exists, it is to be replaced.

{p 0 8 2}
{cmd:prefix(}{it:string}{cmd:)} and {cmd:suffix(}{it:string}{cmd:)} - If the {it:varlist} contains 
variables that are named with a prefix or suffix. For example, the variables is actually
named {it: hicam1, hicam2, hicam3, hicam4} and you'd like to lighten your typing load,
use the command {cmd:scoreit} m1-m4 {cmd:, prefix(}hica{cmd:)}.


{title: Options related to the scaling of the items to be summed}

{p 0 8 2}
{cmd:f0} - if the {hi: f0} option is specified (say to yourself "force zero" or "floor zero"), 
each item will be re-scaled by subtracting the minimum value over all items from each item. 
This is done to attempt to force all items to have a minimum value of 0. Say you had a set of 
{it:items} with values 1 and 2 the sum generated from 
{hi: scoreit} {it:items} {hi: , f0 gen(}{it:scorename}{hi:)} will first subtract the minimum
(1) from each item before generating the sum. The interim statistics (item means, alpha) 
use these recoded items. 

{p 0 8 2}
{cmd:indicator(}{it:string}{hi:)} - If your items have multiple, but you want 
the summary variable to be a count of one of these values, place the target value in the 
{cmd: indicator} option. For example, if the items are coded 1 and 2, and you want the sum of 
the 1's, use {cmd: indicator(1)}.

{p 0 8 2}
{cmd:reverse(}{it:varlist}{hi:)} - If some of the items are reversed coded (as sometimes is
the case in attitude or mood questionnaires) identify them here and the reversal will be
handled automatically in generating the sum. 


{title: Options related to handling item level missing data}

{p 0 8 2}
{cmd:all} - if the {hi: all} option is specified, all values in {it: varlist} will be added 
together and no prorating for missing values will be performed.

{p 0 8 2}
{cmd:ice} - if the {hi: ice} option is specified, the sum score will be computed using item 
scores that have been imputed using non-missing values from the remainder of the item list. 
This procedure is completed using the ice module and it's default settings. The imputation 
is stochastic, meaning not all observations with the same response pattern will have the 
same imputed value. This is good for parameter estimation and variance estimation but not
good for high stakes assessment situations or situations involving individual level inference.

{p 0 8 2}
{cmd:missinglist(}{it:string}{hi:)} - put code to identify values for the items that are 
missing (not included in the sum). Please note: {hi: scoreit} makes a call to {hi: mvdecode} 
before running statistics and imputations, pro-rating, etc. Items with missing values so 
noted in the {hi:missinglist} will be treated as missing values for all operations in 
this program. However, these changes are not saved in the working file.

{p 0 8 2}
{cmd:prorate} - if the {hi: prorate} option is specified, all values in {cmd: varlist} will be 
added together and a prorating step will inflate scores to a common number of items. If 
{cmd: maxitemresponse} is specified, the prorating step will inflate to a common total score. If all 
items have the same maximum score, it is sufficient to prorate to a common number of items. 
But if some items have a different maximum possible score, then use {cmd: maxitemresponse} 
or {cmd:ice}.

{p 0 8 2}
{cmd:maxitemresponse} - if the {hi: prorate} option is specified, and not all items have 
the same response scale, use the {cmd:maxitemresponse} option to specify the maximum 
possible item score (or use the {cmd:ice} option). The usage is, for example 
{cmd: maxitemresponse(}{it:1 2 3 1 2 3}{cmd:)} where {it: 1 2 3 1 2 3} are the highest 
possible item scores for items 1-6, respectively if you had a six item measure. Note 
no comma or separator other than a space.

{p 0 8 2}
{cmd:meanimp} - if the {hi: meanimp} option is specified missing items will be replaced with 
the mean from among non-missing items. Note that when all items have the same response scale, 
this is the same thing as {hi:prorate}. Only use {cmd:meanimp} if you have items on the same
scale (i.e., {cmd:meanimp} does not work with {cmd:maxitemresponse}).

{p 0 8 2}
{cmd:minitems} - The program default is to provide a sum if greater than .4*(number of items) 
are not missing. This can be over ridden with the {cmd:minitems} option. Just specify the 
minimum number of items desired. NB {hi: all} and {hi: indicator} also override the
default minimum non-missing item exclusion. Note that the 40% rule is not a good rule, in 
general, and by setting this as the default no endorsement of that rule is implied. But it 
is as low as my clinical colleagues will tolerate. For the purposes of population parameter 
estimation, it is most appropriate and least biased to perform imputation for all persons or 
at least all persons with 1 non-missing item. 


{title: Options related to the scaling of the generated variable}

{p 0 8 2}
{cmd:z} - request the sum be converted to a z-score (mean zero, sd 1). See {hi:to} option.

{p 0 8 2}
{cmd:hz} - request the sum be standardized to 2 standard deviations. The resulting variable 
has a mean of 0 and a sd of 0.5. Read why and how this is useful at 
{browse "https://pdfs.semanticscholar.org/6b9f/0ed064b71cf4843167fa1857dea90ee8f953.pdf":Gelman (2007)}

{p 0 8 2}
{cmd:t} - request the sum be converted to a T-score (mean 50, sd 10). See {hi:to} option.

{p 0 8 2}
{cmd:iq} - request the sum be converted to a IQ-score (mean 100, sd 15). See {hi:to} option.

{p 0 8 2}
{cmd:to(}{it:string}{hi:)} - put code to identify the subset of observations to be used 
as the sample to which all values are standardized. Use the syntax here that you would 
following an {cmd: if} statement.


{title:Examples}

{p 4 4 4}
In the below example, every person had the opportunity to answer all 12 items

{hi: scoreit q1ebmt-q12ebmt , gen(ebit) replace z}
{hi: label variable ebit "ebit East Boston Story Immediate Recall (z-score)"}

{p 4 4 4}
In the below example, persons only answered conditional on answering correctly
prior questions. So there is a lot of missing data in the latter items.
Use the {hi:if} command to restrict scoring to persons with a valid response
on the first question, and the {hi:all} option to override missing and
prorating procedures

{hi: scoreit digbak1a-digbak6b if digbak1a~=. , gen(db) all replace z}
{hi: label variable db "db Digits Backwards (z-score)}

{p 4 4 4}
In the below example, not all items have the same number of response
categories. In this situation prorate and mean imputation could
based on the number of non-missing items is not appropriate, but
instead should be based on the maximum possible score for
items observed and all items. To figure this out, {hi:scoreit} needs to
have the maximum item response scores for each item. Remember the default
is to prorate when more than 40% of items asked are non-missing.

{hi: scoreit cams1-cams10 , gen(camstotal) prorate maxitemresponse(1 2 2 2 2 2 2 2 2 2)}
{hi: la var camstotal "CAM-S total score"}


{title:Author}

{p 8 8 2}
Richard N Jones, ScD{break}
{browse "mailto:rich_jones@brown.edu"}{break}
Update: 2018-06-24{break}







