gen spexfm11=exfm1
gen spexfm12 = (max((exfm1--.159)^3,0)-(.2543000000000002-.128)^-1 * (max((exfm1-.128)^3,0)*(.2543000000000002--.159)-max((exfm1-.2543000000000002)^3,0)*(.128--.159))) / (.2543000000000002--.159)^2 if missing(exfm1)~=1
gen spexfm13 = (max((exfm1-.021)^3,0)-(.2543000000000002-.128)^-1 * (max((exfm1-.128)^3,0)*(.2543000000000002-.021)-max((exfm1-.2543000000000002)^3,0)*(.128-.021))) / (.2543000000000002--.159)^2 if missing(exfm1)~=1
gen Pexfm1_blom = -.5137060748918489+spexfm11*6.97236580820445+spexfm12*-.499967094088975+spexfm13*11.05867479984317
* have a nice day