## Overview
This note describes the contents at https://github.com/rnj0nes/HCAP23. This repo is an update for the rj0nes/HCAP22 repo. The update revises the 2022 code addressing the following issues:

- Code is written to work with public versions of HRS/HCAP data (the rjones/HCAP22 repo was written to work with interim working files of HCAP data that included variables not included in public versions)
- Errors in variable handling are corrected
- Embedded LaTeX code in Stata do-files is removed
- Analyses are integrated into a single workflow (confirmatory factor analysis, normalization and standardization, algorithmic classification)

The code provided provides a record of data handling and analyses in two manuscripts (Manly et al 2022, Jones et al 2024). **_The code, as posted in this repo, cannot be used without access to non-public sensitive data._** In a closing section I discuss approaches to modify this code to run without access to public data. 

This repo contains (mostly) Stata code used in analyses of the Health and Retirement Study (HRS) Harmonized Cognitive Assessment Protocol (HCAP). Using these command files will require:

* Stata (files were prepared using version 18)
* R (version 4.1+)
* Mplus (version 7.1+)

The workhorse software is Stata.
## Workflow

The stata code is organized inspired by the principles outlined in JS Long's _Workflow of Data Analysis  Using Stata_ (2008, Stata Corp). As such there is a "master" file that calls the individual Stata do files that organize the data and perform the analyses. It is intended that a single code fine does one major activity.  To run the code, open the `000-master.do` command file and run all of the lines. These lines `include` all of the sub-command files (e.g., `001-Environment-settings.do`). The workflow organization is illustrated in **Figure 1**.

![Figure 1. Workflow organization](https://github.com/rnj0nes/HCAP23/blob/main/HCAP-workflow-integrated-analysis-20230930.png)

This figure illustrates the flow of data -- with input data shown in blue and green boxes on the left -- through Stata code programs, and the output generated. Output generated include other Stata data files (`dta`): also the `do` files generate other `do` files (discussed below) and other kinds of output, but this figure does not illustrate those outputs. 

With this figure, you can see that one of the non-public data files (`hcapnormexcldsummary_20210426.dta`) is called by the Stata do file `017-call-data-nonpublic.do`, which generates an output data file (`w017.dta`) which is in turn used by the Stata do file `041-Normalization-Standardization.do`.

Note the command file `Compile_Public_Data` is not included in the repo.

Ideally, each component `do` file (e.g., `031-factor-score-estimation.do`) should be able to be executed on it's own (that is, without having to run all of the previous `do` files) with the exception of `001-Environment-settings.do`. So if a user wanted to only run the factor score estimation program, a small do file 

```
include 001-Environment-settings.do
include 031-Factor-score-esitmation.do
```

should be sufficient, so long as the input `dta` files are available in the working folder. The figure shows that the input data for `031-factor-score-estimation.do` is `w021.dta`.

### SSC and personal `ado` files

I make extensive use of personal `ado` files. I think the list of these is:

* `lowercase.ado` (changes all variables to lower case)
* `runmplus.ado` (run Mplus)
* `vlabel.ado` (apply value labels)
* `z1.ado` (minmax normalization)
* `scoreit.ado` (create additive sums)
* `itemsummary.ado` (called by scoreit.ado)
* `rdoc.ado` (hack of Jann's texdoc.ado)

These are all included in this repo, except for `runmplus.ado` . Only one of these includes a `sthlp` file (`scoreit.sthlp`). Others may have helpful information available if you use Stata's `viewsource` command (e.g., `viewsource z1.ado`) after you have installed the ado.  

`runmplus.ado` and associated files can be installed running the following from the Stata command line:

```
net install runmplus , from(https://s3.amazonaws.com/runmplusbucket) force 
```

Note you must have Mplus (<https://statmodel.com>) to use the `runmplus.ado`. 

I also make use of many `ado` files created by other Stata users, and hopefully most of these are available at SSC. Unfortunately I do not keep track of which of the commands I call are custom `ado`s. The user will discover this, frustratingly, by `command XYZ is unrecognized` errors thrown by Stata (where `XYZ` is the name of the command you tried to run). When this happens, the first thing to try is `SSC install XYZ`. If that does not work, more likely than not it the command is a personal ado not included on the list above. Email me ([rich_jones@brown.edu](mailto:rich_jones@brown.edu)) and I will add it to the repo.

Final note, a very easy way to avoid having to download and install my custom ados, and custom SSC ados, is to add a folder holding my custom `ado`s to your `adopath`. The way to do this is to run

`adopath +"https://quantsci.s3.amazonaws.com/Jones-ADO/"`

from the Stata command line before trying to execute the command files. Now, it is possible you might run these programs and still get a `command XYZ is unrecognized` error, but in this case the missing command is a command available from SSC (or elsewhere). A way to protect yourself from this error is to also add a copy of my plus commands to your `adopath`, with:

`adopath +"https://quantsci.s3.amazonaws.com/Jones-ADO-plus/"`

Or, you could encounter these errors and add the commands to your own "plus" as they come up. That way is more painful and time consuming, but then you have these ados in your workflow more permanently.

## Notes on individual do files 

### 000-Master.do
`include`s the other do files. 
### Data management do files
#### 001-Environment-settings.do
Sets the working folder path, notes custom ados used.
#### 011-Call-data-HCAP-respondent.do
Simply `use`s the public HCAP respondent data file as provided by HRS.
#### 013-Call-data-HCAP-informant.do
Simply `use`s the public HCAP informant data file as provided by HRS.
#### 015-Call-data-CORE-respondent.do
Calls (`use`s) the HRS Core data file from the 2016 wave, and the tracker file. The file that is called is the public access Stata data file, but the downloaded CSV has been processed into a `dta` file. Some variable handling for demographic variables is also included in this file. 
#### 017-Call-data-nonpublic.do
This `do` file calls and minimally processes non-public data relevant to identifying persons in the HCAP sample who likely have dementia and should be excluded from the normative reference sample. See Manly et al (2022). 
#### 018-Generate-hcapage.do
This small program generates a variable `hcapage`. This variable was present in early, working copies of the HCAP data, but is not included in the public data release. In order to make my code developed in these early working files perform correctly when calling the public data, I generate the `hcapage` variable.
#### 021-Create-HCAP-cognitive-indicators.do
This `do` file transforms public data cognitive performance scores into analytic variables used in the factor analysis. This is where missing data handling is, min/max normalization for selected variables, collapsing categories for sparsely observed categories, etc. Extensive annotations within the code justifying the variable handling and noting differences in variable handling from the rnj0nes/hcap22 repo.
### Analysis do files
### 031-Factor-score-estimation.do
This `do` file uses the `runmplus.ado` to call the Mplus software and conduct the confirmatory factor analysis models. Most of these models are described in Jones et al (2024). Factor score estimates are also generated. Note we generate both Bayesian plausible values and expected a posteriori (EAP) factor score estimates. They have different properties and useful in different situations. Standard errors for EAP estimates are also provided, when they are available. A list of scores generated is presented below.
#### 041-Normalization-Standardization.do
This `do` file does the normalization and standardization of factor score estimates, including the adjustment for the effects of age, sex, education, race/ethnicity. 

This program cannot run without the non-public data. However, one of the main bits of output of this `do` file are the adjustment equations. The user will notice that this repo contains many more `do` files than are listed in **Figure 1**. For example, we have

| `do` file                  | Function                                                                                                                                                                                                                                                                                                                                                                                                                        |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `gen_mem_blom_from_mem.do` | Generates `Pmem_blom` -- a Blom-transformed version of the `mem` variable (a factor score estimate from `031-factor-score-estimation.do`).  The Blom transformation is accomplished using observed values in the HRS/HCAP sample and hard coded into this `do` file using restricted cubic splines.                                                                                                                             |
| `gen_spage_from_age.do`    | Generates cubic spline functions for age (`spage1-sapge3`) from `hcapage`.                                                                                                                                                                                                                                                                                                                                                      |
| `gen_Emem_blom.do`         | Generates `Emem_blom` from `spage1-sapge3`, `female`, `black`, `hisp`, and `schlyrs`. This generated `do` file includes the parameter estimates from the adjustment regression equations. Capital `E` in `Emem_blom` is meant to indicate this is an expected score. The `_blom` indicates this is based on the Blom-transformed version of the factor score estimate, and the `mem` refers to the domain that is being scored. |
| `genTmem.do`               | Generates `Tmem` from `Emem_blom` and `Pmem_blom`, and the HRS/HCAP observed standard deviation, and adjustment model r-squared. `Tmem` should have a mean of 50 and standard deviation of 10.                                                                                                                                                                                                                                  |

There is one version of `gen_spage_from_age.do`, but there are versions of the `gen_#_blom_from_#.do`, `gen_E#_blom.do`, and `genT#.do` for many different kinds of factor score estimates (`#` is `mem`, `exf`, `lfl`, `gcp`, etc.). The table below summarizes the kinds of factor score estimates:

| Name        | Domain             | Kind of model               | Kind of score  |
| :---------- | :----------------- | :-------------------------- | :------------- |
| gmemm1      | Memory             | Second order                | PV             |
| memm1       |                    | Single factor               | PV             |
| gmem        |                    | Second order                | EAP            |
| mem         |                    | Single factor               | EAP            |
| gexfm1      | Executive function | Second order                | PV             |
| exfm1       |                    | Single factor               | PV             |
| gexf        |                    | Second order                | EAP            |
| exf         |                    | Single factor               | EAP            |
| glflm1      | Language, fluency  | Second order                | PV             |
| lflm1       |                    | Single factor               | PV             |
| glfl        |                    | Second order                | EAP            |
| lfl         |                    | Single factor               | EAP            |
| vdori1      | Orientation        | Sum of correct              | Not applicable |
| vdvis1      | Visuospatial       | CERAD constructional praxis | Not applicable |
| gcpm1       | Global cognition   | Second order                | PV             |
| gcp         |                    | Second order                | EAP            |
| h1rmsetotal | MMSE score         | Total score                 | Not applicable |
Note: EAP, Expected a posteriori; PV, Bayesian plausible value
#### 051-Imputation.do
This program imputes missing informant data and cognitive performance data. It uses Mplus to do the imputation. **_It does make use of non-public data._** A single imputation is drawn, each missing observation being replaced with a random draw from a posterior distribution of plausible values given the other variables in the data.
#### 071-Algorithm.do
Assigns persons to normal vs MCI vs Dementia categories as described in Manly et al (2022). Note that in the manuscript, and in this code, cognitive impairment indicators making use of Bayesian plausible values are used. These have a stochastic component. 

## Adapting the code for use with only public data
If the user would like to approximate the algorithm without relying upon the non-public data, it is possible to come close to the results with the non-public data. I will discuss with reference to **Figure 2**, which is the workflow diagram with some modifications.

![Figure 2. A suggestion for modifying the workflow to work without sensitive data](https://github.com/rnj0nes/HCAP23/blob/main/HCAP-workflow-integrated-analysis-without-sensitive-data-2024-04-14.png)

Without sensitive data: the data files that are not available are hashed out. Their resulting output `dta` files are also hashed out. Without sensitive data, the `do` files `017-Call-data-nonpublic.do` are not needed. The analysis files `041-Normalization-standardization.do` and `051-Imputation.do` will have to be modified.

The original **`041-Normalization-standardization.do`** does two things (I should have made this two files, each doing one thing: sorry). It both **_generates_** and **_executes_** `do` files that construct Blom-transformed versions of factor scores estimated from `031-factor-score-estimation.do`, generated predicted values for the cognitive performance scores given demographic variables, and standardizes these predicted values to a T distribution (mean 50, SD 10) taking into account the HRS/HCAP variability and r-squared of the adjustment model. These steps are described above in a little more detail. The edit that would be necessary to `041-Normalization-standardization.do` to make it work without the non-public data is to strip out the code that generates the do files, and only retains the code that executes the generated do files. All of the generated do files should be in this repo. If anything is missing, let me know. Let's call this modified version of file `041`: `041-normalization-standardization-public-version.do`. The output of this program (I suggest calling/labeling/naming the output data file `041-output-public.dta`) **_should be identical_** to that generated using the sensitive data.

The original **`051-imputation.do`** file will also have to be modified. It will have to have variables from the sensitive data removed from the imputation model. I would call the revised program `051-imputation-public-version.do` and the resulting output `w051-postimputation-public.dta`. The output from this file will **_not be the same_** as the original `w051` `dta` file, because the input data will have changed as used in the imputation model. Even if the sensitive data used in the imputation model were not very important predictors of missingness or outcomes among those for whom data were not missing, because the imputation values are single plausible values from a posterior distribution, the imputed values will be different. Of course, values for persons without missing data will be identical. 


## References cited 

Manly, J. J., Jones, R. N., Langa, K. M., Ryan, L. H., Levine, D. A., McCammon, R., Heeringa, S. G., & Weir, D. (2022). Estimating the Prevalence of Dementia and Mild Cognitive Impairment in the US: The 2016 Health and Retirement Study Harmonized Cognitive Assessment Protocol Project. _JAMA Neurol_, _79_(12), 1242-1249. https://doi.org/10.1001/jamaneurol.2022.3543

Jones, R. N., Manly, J. J., Langa, K. M., Ryan, L. H., Levine, D. A., McCammon, R., & Weir, D. (2024). Factor structure of the Harmonized Cognitive Assessment Protocol neuropsychological battery in the Health and Retirement Study. _Journal of the International Neuropsychological Society_, _30_(1), 47-55. https://doi.org/10.1017/S135561772300019X

## Contact

Please feel free to contact me with questions, missing commands or files, or
any other challenges you have using these resources.

Rich Jones

[rich_jones@brown.edu](mailto:rich_jones@brown.edu)

