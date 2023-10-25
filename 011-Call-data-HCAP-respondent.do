cap confirm file w011.dta 
if _rc==0 {
    exit 
}
use `data_source_path'/HC16/HC16sta/hc16hp_r.dta , clear 
lowercase
save w011.dta , replace 

