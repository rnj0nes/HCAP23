* Clean up working directory 
#d ;
foreach x in
__000001.dat
__000001.inp 
__000001.out 
E1.dta 
E2.dta 
E3.dta 
foogoo.out 
itemsummary.md 
itemsummary.tex 
svalues.txt 
{ ;
cap erase `x' ;
} ;
#d cr
