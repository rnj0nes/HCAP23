gen spgexf1=gexf
gen spgexf2 = (max((gexf--.1366)^3,0)-(.242-.126)^-1 * (max((gexf-.126)^3,0)*(.242--.1366)-max((gexf-.242)^3,0)*(.126--.1366))) / (.242--.1366)^2 if missing(gexf)~=1
gen spgexf3 = (max((gexf-.0308)^3,0)-(.242-.126)^-1 * (max((gexf-.126)^3,0)*(.242-.0308)-max((gexf-.242)^3,0)*(.126-.0308))) / (.242--.1366)^2 if missing(gexf)~=1
gen Pgexf_blom = -.6048905029525806+spgexf1*7.288711271986812+spgexf2*-.1989383843251178+spgexf3*12.34712705966047
* have a nice day
