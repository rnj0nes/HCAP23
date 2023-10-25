gen spvdvis11=vdvis1
gen spvdvis12 = (max((vdvis1-5)^3,0)-(11-10)^-1 * (max((vdvis1-10)^3,0)*(11-5)-max((vdvis1-11)^3,0)*(10-5))) / (11-5)^2 if missing(vdvis1)~=1
gen spvdvis13 = (max((vdvis1-8)^3,0)-(11-10)^-1 * (max((vdvis1-10)^3,0)*(11-8)-max((vdvis1-11)^3,0)*(10-8))) / (11-5)^2 if missing(vdvis1)~=1
gen Pvdvis1_blom = -4.055803064594793+spvdvis11*.4823243076917662+spvdvis12*-.2320143499017405+spvdvis13*1.787545978378465
* have a nice day
