gen spglfl1=glfl
gen spglfl2 = (max((glfl--.087)^3,0)-(.158-.08)^-1 * (max((glfl-.08)^3,0)*(.158--.087)-max((glfl-.158)^3,0)*(.08--.087))) / (.158--.087)^2 if missing(glfl)~=1
gen spglfl3 = (max((glfl-.019)^3,0)-(.158-.08)^-1 * (max((glfl-.08)^3,0)*(.158-.019)-max((glfl-.158)^3,0)*(.08-.019))) / (.158--.087)^2 if missing(glfl)~=1
gen Pglfl_blom = -.5921479981124695+spglfl1*12.06734180063728+spglfl2*-.8274248912699335+spglfl3*17.41012530455263
* have a nice day
