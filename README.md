
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

The stata code is organized inspired by the principles outlined in JS Long's _Workflow of Data Analysis  Using Stata_ (2008, Stata Corp). As such there is a "master" file that calls the individual Stata do files that organize the data and perform the analyses. It is intended that a single code fine does one major activity. 

![Figure 1. Workflow organization](https://github.com/rnj0nes/HCAP23/blob/main/HCAP-workflow-integrated-analysis-20230930.png)

Stata code are provided (`do` files). The code is organized as follows. To run the code, open the `-000-master.do` command file and run all of the lines. These lines `include` all of the sub-command files (e.g., `-205-table1.do`).

I make extensive use of personal `ado` files. These are not shared in this
repo and I do not keep track of which of the commands I call are custom `ado`s.
The user will discover this, frustratingly, by `command XYZ is unrecognized` errors
thrown by Stata. A very easy way to avoid this is to add a folder holding my
custom `ado`s to your `adopath`. The way to do this is to run

`adopath +"https://quantsci.s3.amazonaws.com/Jones-ADO/"`

from the Stata command line before trying to execute the command files. Now, it
is possible you might run these programs and still get a `command XYZ is unrecognized`
error, but in this case the missing command is a command available from
SSC (or elsewhere). A way to protect yourself from this error is to also add a
copy of my plus commands to your `adopath`, with:

`adopath +"https://quantsci.s3.amazonaws.com/Jones-ADO-plus/"`

Or, you could encounter these errors and add the commands to your own "plus"
as they come up. That way is more painful and time consuming, but then you
have these ados in your workflow more permanently.

## Note on code: stmd files

Two of the subprojects are coded in German Rodriguez's `markstat` command /
framework. These are files with the "stmd" suffix. I especially like this
approach for the easy integration of `R` and `Stata`. However, this framework is
limited relative to R markdown and I'll still be transitioning to R. Regardless,
the command for executing these programs is embedded in the top of the command
file. For example in the `MS-prev-dem.stmd` file, there is near the top:

> `<!--`
> `cd /Users/rnj/Dropbox/Work/HCAP22/POSTED/ANALYSIS/MS-Prev-Dem/`
> `markstatit MS-Prev-Dem.stmd , strict keep bundle docx`
> `-->`

That code block is enclosed in markdown comments (`<!-- blah -->`). So when the
enclosing `stmd` file is sent to Stata/markstat, it will be deleted. I use this
block of code to execute the program from the code editor. I highlight the two
lines with Stata code and send those to Stata.

## References cited 

Manly, J. J., Jones, R. N., Langa, K. M., Ryan, L. H., Levine, D. A., McCammon, R., Heeringa, S. G., & Weir, D. (2022). Estimating the Prevalence of Dementia and Mild Cognitive Impairment in the US: The 2016 Health and Retirement Study Harmonized Cognitive Assessment Protocol Project. _JAMA Neurol_, _79_(12), 1242-1249. https://doi.org/10.1001/jamaneurol.2022.3543

Jones, R. N., Manly, J. J., Langa, K. M., Ryan, L. H., Levine, D. A., McCammon, R., & Weir, D. (2024). Factor structure of the Harmonized Cognitive Assessment Protocol neuropsychological battery in the Health and Retirement Study. _Journal of the International Neuropsychological Society_, _30_(1), 47-55. https://doi.org/10.1017/S135561772300019X

## Contact

Please feel free to contact me with questions, missing commands or files, or
any other challenges you have using these resources.

Rich Jones

[rich_jones@brown.edu](mailto:rich_jones@brown.edu)

