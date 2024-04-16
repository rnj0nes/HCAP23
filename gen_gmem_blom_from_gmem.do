gen spgmem1=gmem
gen spgmem2 = (max((gmem--.185)^3,0)-(.3-.156)^-1 * (max((gmem-.156)^3,0)*(.3--.185)-max((gmem-.3)^3,0)*(.156--.185))) / (.3--.185)^2 if missing(gmem)~=1
gen spgmem3 = (max((gmem-.036)^3,0)-(.3-.156)^-1 * (max((gmem-.156)^3,0)*(.3-.036)-max((gmem-.3)^3,0)*(.156-.036))) / (.3--.185)^2 if missing(gmem)~=1
gen Pgmem_blom = -.601599255416517+spgmem1*5.596852712084046+spgmem2*.2422005129133406+spgmem3*8.487983119597082
* have a nice day
