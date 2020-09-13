#!/bin/csh

set datafile = "ETOPO1_Ice_g_gmt4.grd"
set tmpfile = "topography"
set psfile = "topography.ps"

grdcut  $datafile -R128/133/30/35 -G$tmpfile.grd
grdimage $tmpfile.grd -R -JM14 -CGMT_relief.cpt -P -K > $psfile
#C:数字だけを書いた場合は等値線の間隔になる。 L:等値線を書く範囲 A:数字を書く間隔
#grdcontour $tmpfile.grd -R -J -C100 -W0 -L0/1000 -O -K >> $psfile
#
psscale -Ba2000g1000f1000 -CGMT_relief.cpt -D6/-1/12/0.3h -O -K >>$psfile
pscoast -R -J -Ba1f1g0.5/a1f1g0.5 -Di -S255/255/255 -W1 -O -K >>$psfile
