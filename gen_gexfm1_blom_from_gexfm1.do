gen spgexfm11=gexfm1
gen spgexfm12 = (max((gexfm1--.1482)^3,0)-(.256-.129)^-1 * (max((gexfm1-.129)^3,0)*(.256--.1482)-max((gexfm1-.256)^3,0)*(.129--.1482))) / (.256--.1482)^2 if missing(gexfm1)~=1
gen spgexfm13 = (max((gexfm1-.029)^3,0)-(.256-.129)^-1 * (max((gexfm1-.129)^3,0)*(.256-.029)-max((gexfm1-.256)^3,0)*(.129-.029))) / (.256--.1482)^2 if missing(gexfm1)~=1
gen Pgexfm1_blom = -.5987341757089075+spgexfm11*6.896593128844327+spgexfm12*.349455320325926+spgexfm13*7.713760493229226
* have a nice day
