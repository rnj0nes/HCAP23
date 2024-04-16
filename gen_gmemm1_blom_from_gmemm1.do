gen spgmemm11=gmemm1
gen spgmemm12 = (max((gmemm1--.1982)^3,0)-(.3396-.155)^-1 * (max((gmemm1-.155)^3,0)*(.3396--.1982)-max((gmemm1-.3396)^3,0)*(.155--.1982))) / (.3396--.1982)^2 if missing(gmemm1)~=1
gen spgmemm13 = (max((gmemm1-.034)^3,0)-(.3396-.155)^-1 * (max((gmemm1-.155)^3,0)*(.3396-.034)-max((gmemm1-.3396)^3,0)*(.155-.034))) / (.3396--.1982)^2 if missing(gmemm1)~=1
gen Pgmemm1_blom = -.6229289634348647+spgmemm11*4.982107889610976+spgmemm12*1.527962311375488+spgmemm13*-2.252062271330542
* have a nice day
