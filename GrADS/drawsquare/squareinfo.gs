* [ USAGE ]
* squareinfo.gs [左下lon] [左下lat] [右上lon] [右上lat]
function main(args)
******************************
if(subwrd(args,1)='help' | subwrd(args,1)=''); help(); return; endif
******************************
i=1
squ_longitude1 = subwrd(args,i)
i=i+1
squ_latitude1 = subwrd(args,i)
i=i+1
squ_longitude2 = subwrd(args,i)
i=i+1
squ_latitude2 = subwrd(args,i)
******************************
dammyvar='rh'
******************************
'set mpdset hires'
*say '*************'
'd 'dammyvar
*say '*************'

'q dims'

say ''
say ''
say '[ infomation for drawing square ]'
say ''
say '**********************************'
* 左上
*say 'position1'
'q w2xy 'squ_longitude1' 'squ_latitude2
pos1_x = subwrd(result,3)
pos1_y = subwrd(result,6)
say 'pos1_x='pos1_x' ; pos1_y='pos1_y
* 右上
*say 'position2'
'q w2xy 'squ_longitude2' 'squ_latitude2
pos2_x = subwrd(result,3)
pos2_y = subwrd(result,6)
say 'pos2_x='pos2_x' ; pos2_y='pos2_y
* 右下
*say 'position3'
'q w2xy 'squ_longitude2' 'squ_latitude1
pos3_x = subwrd(result,3)
pos3_y = subwrd(result,6)
say 'pos3_x='pos3_x' ; pos3_y='pos3_y
* 左下
*say 'position4'
'q w2xy 'squ_longitude1' 'squ_latitude1
pos4_x = subwrd(result,3)
pos4_y = subwrd(result,6)
say 'pos4_x='pos4_x' ; pos4_y='pos4_y
say '**********************************'
say ''
******************************
* [definition of positions]
*letter='"'
*space=' '
*'define position1='letter%pos1_x%space%pos1_y%letter''
*'define position2='letter%pos2_x%space%pos2_y%letter''
*'define position3='letter%pos3_x%space%pos3_y%letter''
*'define position4='letter%pos4_x%space%pos4_y%letter''
*'define pos1x='pos1_x
*'define pos1y='pos1_y
*'define pos2x='pos2_x
*'define pos2y='pos2_y
*'define pos3x='pos3_x
*'define pos3y='pos3_y
*'define pos4x='pos4_x
*'define pos4y='pos4_y
*say ''
*say '======================='
*say 'position1='position1
*say 'position2='position2
*say 'position3='position3
*say 'position4='position4
*say '======================='
*say ''
******************************
'clear'
return pos1_x%' '%pos1_y%' '%pos2_x%' '%pos2_y%' '%pos3_x%' '%pos3_y%' '%pos4_x%' '%pos4_y

function help()
say '***********************************************************************'
say 'squareinfo.gs : 事前にdrawsquareline.gsの為の情報取得を行うスクリプト'
say ''
say '[ USAGE ]'
say '   squareinfo.gs [左下lon] [左下lat] [右上lon] [右上lat]'
say ' スクリプトの次の行に以下を追記!'
say '   squresult=result'
say ' 更に、ループの中などといった書きたい場所で以下の行を記述せよ!'
say "   'run drawsquareline.gs 'squresult"
say ' 但し、少なくとも陰影を描いた後でないと、塗りつぶされてしまう可能性大!'
say '***********************************************************************'
say ''
return


