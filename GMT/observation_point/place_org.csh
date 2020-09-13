#!/bin/csh
#NeWMeKの地点を地図に描くプログラム
set range = 128.0/133.0/30.0/35.0
set datafile1 = towerplace.prn
set datafile2 = bst0824-25new.txt
set colorfile = hyoko.cpt

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

pscoast -JM14 -R$range -Ba1f1g0.5/a1f1g0.5 -Di -S255/255/255 -G255/255/255 -P -W1 -X4 -Y6 -K > $psfile1
awk '($9>=128 && $9<=133 && $10>=30 && $10<=35 && $8==0 && $14==1){print $9,$10}' $datafile2 |\
psxy -JM -R -B -Sa0.6 -W6/0/0/0 -G0/0/0 -X0 -Y0 -K -O >> $psfile1
awk '($9>=128 && $9<=133 && $10>=30 && $10<=35 && $8==0 && $14==0){print $9,$10}' $datafile2 |\
psxy -JM -R -B -Sa0.6 -W6/0/0/0 -G255/255/255 -X0 -Y0 -K -O >> $psfile1
awk '($9>=128 && $9<=133 && $10>=30 && $10<=35 && $8==0){print $9+0.1,$10-0.1,14,0,2,6,$7}' $datafile2 |\
pstext -JM -R -B -G0/0/0 -X0 -Y0 -K -O >> $psfile1
#pstext -JM14 -R$range -Ba1f1g1/a1f1g1 -G0/0/0 -X -Y -K -O -N <<EOF>> $psfile1
#130.5 35.4 20 0 0 6 NeWMeK elevation[m] 
#EOF
#awk '{print $7+$8/60+$9/3600,$4+$5/60+$6/3600,$2}' $datafile1 |\
#psxy -J -R -B -Sc0.3 -C$colorfile -W2 -X0 -Y0 -K -O >> $psfile1

while(1)
echo "描き入れたい地点番号を入れて下さい。終了は0。"
set spotnumber = $<
if($spotnumber < 0 || 123 < $spotnumber)then
echo "そんな番号はないぜ。"
continue
else if($spotnumber == 0)then
echo "終了します。"
break
endif

if($textswitch)then
awk '($1 == '$spotnumber'){print $7+$8/60+$9/3600,$4+$5/60+$6/3600,$2}' $datafile1 |\
psxy -J -R -B -Sc0.2 -C$colorfile -W2 -X0 -Y0 -K -O >> $psfile1
awk '($1 == '$spotnumber'){print $7+($8+15)/60+$9/3600,$4+$5/60+$6/3600,20,0,0,6,$1}' $datafile1|\
pstext -J -R -B -G255/0/0 -X -Y -K -O >> $psfile1
else
awk '($1 == '$spotnumber'){print $7+$8/60+$9/3600,$4+$5/60+$6/3600,$2}' $datafile1 |\
psxy -J -R -B -Sc0.2 -C$colorfile -W2 -X0 -Y0 -O >> $psfile1
endif
end






convert -rotate 270 $psfile1 $psfile2

rm -f $psfile1


