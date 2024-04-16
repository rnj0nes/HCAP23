gen sph1rmsetotal1=h1rmsetotal
gen sph1rmsetotal2 = (max((h1rmsetotal-24)^3,0)-(30-29)^-1 * (max((h1rmsetotal-29)^3,0)*(30-24)-max((h1rmsetotal-30)^3,0)*(29-24))) / (30-24)^2 if missing(h1rmsetotal)~=1
gen sph1rmsetotal3 = (max((h1rmsetotal-28)^3,0)-(30-29)^-1 * (max((h1rmsetotal-29)^3,0)*(30-28)-max((h1rmsetotal-30)^3,0)*(29-28))) / (30-24)^2 if missing(h1rmsetotal)~=1
gen Ph1rmsetotal_blom = -6.8489642061666+sph1rmsetotal1*.2212860770410004+sph1rmsetotal2*.2205219860848487+sph1rmsetotal3*.924748207575504
* have a nice day
