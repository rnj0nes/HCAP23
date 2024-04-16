gen spexfm11=exfm1
gen spexfm12 = (max((exfm1--.15965)^3,0)-(.25-.127)^-1 * (max((exfm1-.127)^3,0)*(.25--.15965)-max((exfm1-.25)^3,0)*(.127--.15965))) / (.25--.15965)^2 if missing(exfm1)~=1
gen spexfm13 = (max((exfm1-.018)^3,0)-(.25-.127)^-1 * (max((exfm1-.127)^3,0)*(.25-.018)-max((exfm1-.25)^3,0)*(.127-.018))) / (.25--.15965)^2 if missing(exfm1)~=1
gen Pexfm1_blom = -.5426384502943202+spexfm11*6.822903909573579+spexfm12*-.040635378011856+spexfm13*9.280567457907878
* have a nice day
