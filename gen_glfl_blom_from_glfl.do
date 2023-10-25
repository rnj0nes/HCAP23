gen spglfl1=glfl
gen spglfl2 = (max((glfl--.085)^3,0)-(.155-.08)^-1 * (max((glfl-.08)^3,0)*(.155--.085)-max((glfl-.155)^3,0)*(.08--.085))) / (.155--.085)^2 if missing(glfl)~=1
gen spglfl3 = (max((glfl-.02)^3,0)-(.155-.08)^-1 * (max((glfl-.08)^3,0)*(.155-.02)-max((glfl-.155)^3,0)*(.08-.02))) / (.155--.085)^2 if missing(glfl)~=1
gen Pglfl_blom = -.5977318269023791+spglfl1*12.20208012589167+spglfl2*-.8357157050786094+spglfl3*18.67775037731493
* have a nice day
