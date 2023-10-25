cap confirm file w013.dta 
if _rc==0 {
    exit 
}

use `data_source_path'/HC16/HC16sta/hc16hp_i.dta , clear 
lowercase
save w013.dta , replace 

