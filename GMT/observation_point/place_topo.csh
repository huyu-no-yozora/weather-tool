#!/bin/csh
set number_shift = 0
set number_size = 10
#NeWMeKの地点を地図に描くプログラム
set range = 128.0/133.0/30.0/35.0
set datafile1 = towerplace.prn
set colorfile = hyoko.cpt
#===========================
#[ drawing topograpy ]
#地形データPATH
set GMTTOOLDIR = /work42/username/Tools/gmt
set TOPODIR = /work42/username/Tools/gmt/TOPO

# file name of topography data(grid file)
set topodata = ETOPO1_Ice_g_gmt4.grd
#basename of cutted topo data file
set tmpfile = topography

# settings of share option
set grdcut_shareopt = $TOPODIR"/"$topodata" -R"$range" -G"$TOPODIR"/"$tmpfile".grd"
set grdimage_shareopt = $TOPODIR"/"$tmpfile".grd -R -JM14 -C"$TOPODIR"/GMT_relief.cpt -P -X2 -Y3"
set psscale_shareopt = "-Ba200g200f200 -C"$TOPODIR"/GMT_relief.cpt -D15.5/8/12/0.3"
#===========================
set pscoast_shareopt = "-JM14 -Ba1g1f1 -R"${range}" -Dh -S255/255/255 -P -W1 -X0 -Y0"

echo "テキストを入れるときは1、入れないときは0を入力してください。"
set textswitch = $<

if($textswitch != 0 && $textswitch != 1)then
echo "入力エラー：入力する文字が違います。終了します。"
exit
endif

#if($textswitch)then
#set psfile1 = place_withtext1.ps
#set psfile2 = place_withtext.ps
#else
#set psfile1 = place_notext1.ps
#set psfile2 = place_notext.ps
#endif
set number = 1
while(1)
if(!(-e place$number.jpg))then
set psfile1 = place$number-1.ps
set psfile2 = place$number.ps
echo "####"
break
endif
set number = `expr $number + 1`
echo $number
end

#=====================================================#
#[drawing topography]
grdcut ${grdcut_shareopt}
grdimage ${grdimage_shareopt} -K > $psfile1
psscale ${psscale_shareopt} -K -O >> $psfile1
#drawing map(${IMAGE} does NOT depend the station_num)
pscoast ${pscoast_shareopt} -K -O >> $psfile1
#=====================================================#

#pscoast -JM14 -R$range -Ba1f1g0.5/a1f1g0.5 -Di -S255/255/255 -G255/255/255 -P -W1 -X -Y -K -O >> $psfile1
#pstext -JM14 -R$range -Ba1f1g1/a1f1g1 -G0/0/0 -X -Y -K -O -N <<EOF>> $psfile1
#130.5 35.4 20 0 0 6 NeWMeK elevation[m] 
#EOF
#awk '{print $7+$8/60+$9/3600,$4+$5/60+$6/3600,$2}' $datafile1 |\
#psxy -J -R -B -Sc0.3 -C$colorfile -W2 -X0 -Y0 -K -O >> $psfile1

#while(1)
#echo "描き入れたい地点番号を入れて下さい。終了は0。"
#set spotnumber = $<
#if($spotnumber < 0 || 123 < $spotnumber)then
#echo "そんな番号はないぜ。"
#continue
#else if($spotnumber == 0)then
#echo "終了します。"
#break
#endif


set spotnumber = 1
while($spotnumber <= 123)

if($textswitch)then
awk '($1 == '$spotnumber'){print $7+$8/60+$9/3600,$4+$5/60+$6/3600,$2}' $datafile1 |\
psxy -J -R -B -Sc0.2 -C$colorfile -W2 -X0 -Y0 -P -K -O >> $psfile1
awk '($1 == '$spotnumber'){print $7+($8+'$number_shift')/60+$9/3600,$4+$5/60+$6/3600,'$number_size',0,0,6,$1}' $datafile1|\
pstext -J -R -B -G255/255/255 -X -Y -K -O >> $psfile1
awk '($1 == '$spotnumber'){print $7+($8+'$number_shift')/60+$9/3600,$4+$5/60+$6/3600,'$number_size',0,0,6,$1}' $datafile1|\
pstext -J -R -B -G0/0/0 -X -Y -K -O >> $psfile1
else
awk '($1 == '$spotnumber'){print $7+$8/60+$9/3600,$4+$5/60+$6/3600,$2}' $datafile1 |\
psxy -J -R -B -Sc0.2 -C$colorfile -W2 -X0 -Y0 -P -O >> $psfile1
endif

set spotnumber = `expr $spotnumber + 1`
end



#convert -rotate 270 $psfile1 $psfile2

#rm -f $psfile1


