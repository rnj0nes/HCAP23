gen splflm11=lflm1
gen splflm12 = (max((lflm1--.129)^3,0)-(.2-.0642)^-1 * (max((lflm1-.0642)^3,0)*(.2--.129)-max((lflm1-.2)^3,0)*(.0642--.129))) / (.2--.129)^2 if missing(lflm1)~=1
gen splflm13 = (max((lflm1--.014)^3,0)-(.2-.0642)^-1 * (max((lflm1-.0642)^3,0)*(.2--.014)-max((lflm1-.2)^3,0)*(.0642--.014))) / (.2--.129)^2 if missing(lflm1)~=1
gen Plflm1_blom = -.1983741793582952+splflm11*11.19252241201014+splflm12*-2.100968650314659+splflm13*3.786443740618824
* have a nice day
