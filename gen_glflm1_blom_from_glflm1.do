gen spglflm11=glflm1
gen spglflm12 = (max((glflm1--.101)^3,0)-(.181-.0822000000000001)^-1 * (max((glflm1-.0822000000000001)^3,0)*(.181--.101)-max((glflm1-.181)^3,0)*(.0822000000000001--.101))) / (.181--.101)^2 if missing(glflm1)~=1
gen spglflm13 = (max((glflm1-.015)^3,0)-(.181-.0822000000000001)^-1 * (max((glflm1-.0822000000000001)^3,0)*(.181-.015)-max((glflm1-.181)^3,0)*(.0822000000000001-.015))) / (.181--.101)^2 if missing(glflm1)~=1
gen Pglflm1_blom = -.5312235205553626+spglflm11*10.53682654987273+spglflm12*.1742290206012542+spglflm13*6.325054446407084
* have a nice day