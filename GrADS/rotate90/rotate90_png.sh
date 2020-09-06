#/bin/csh
####################################
#set kaizodo = 180
####################################
set imagetype = png
#cd .epsdir
 foreach file(*.png)
  set file2 = `expr $file : '\(.*\).png'`
#  convert -rotate 90 -density $kaizodo $file $file2.jpg
  convert -rotate 90 $file $file2.${imagetype}
  echo "$file ${imagetype} change end"
#  rm -f $file
 end
# end
#   echo " END "

