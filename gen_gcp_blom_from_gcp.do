gen spgcp1=gcp
gen spgcp2 = (max((gcp--.1396)^3,0)-(.2635999999999999-.138)^-1 * (max((gcp-.138)^3,0)*(.2635999999999999--.1396)-max((gcp-.2635999999999999)^3,0)*(.138--.1396))) / (.2635999999999999--.1396)^2 if missing(gcp)~=1
gen spgcp3 = (max((gcp-.0368)^3,0)-(.2635999999999999-.138)^-1 * (max((gcp-.138)^3,0)*(.2635999999999999-.0368)-max((gcp-.2635999999999999)^3,0)*(.138-.0368))) / (.2635999999999999--.1396)^2 if missing(gcp)~=1
gen Pgcp_blom = -.620851640545495+spgcp1*6.988800036489263+spgcp2*-.3612666316454378+spgcp3*12.06302271106055
* have a nice day
