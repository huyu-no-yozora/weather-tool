function main(args)
**************************************
if(subwrd(args,1)='help' | subwrd(args,1)=''); help(); return; endif
**************************************
* [ configuration ]
lineopt='3 1 9';*(線の色 種類 太さ)
**************************************
'set line 'lineopt

pos1x = subwrd(args,1)
pos1y = subwrd(args,2)
pos2x = subwrd(args,3)
pos2y = subwrd(args,4)
pos3x = subwrd(args,5)
pos3y = subwrd(args,6)
pos4x = subwrd(args,7)
pos4y = subwrd(args,8)

position1=pos1x%' '%pos1y
position2=pos2x%' '%pos2y
position3=pos3x%' '%pos3y
position4=pos4x%' '%pos4y
say 'position1='position1'; position2='position2'; position3='position3'; position4='position4

'draw line 'position1' 'position2
'draw line 'position2' 'position3
'draw line 'position3' 'position4
'draw line 'position4' 'position1
**************************************
return

function help()
say '*************************************'
say 'squareinfo.gsの方のhelpを参照せよ!'
say '[参照方法]'
say 'GrADS console内で以下を実行'
say '   squareinfo.gs help'
say '*************************************'
return

