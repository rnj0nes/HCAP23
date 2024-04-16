local data_source_path "/Users/rnj/Library/CloudStorage/Dropbox/Work/HCAP23/POSTED/DATA/SOURCE"

global source "`data_source_path'"
dir $source 


* Rich's custom ados used
* —————————————————————————————————————————————————————————
* lowercase.ado (changes all variables to lower case)
* runmplus.ado (run Mplus)
* vlabel.ado (apply value labels)
* z1.ado (minmax normalization)
* scoreit.ado (create additive sums)
* itemsummary.ado (called by scoreit.ado)
