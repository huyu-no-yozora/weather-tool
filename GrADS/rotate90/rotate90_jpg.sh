#/bin/csh
####################################
#set kaizodo = 180
####################################

#cd .epsdir
 foreach file(*.jpg)
  set file2 = `expr $file : '\(.*\).jpg'`
#  convert -rotate 90 -density $kaizodo $file $file2.jpg
  convert -rotate 90 $file $file2.jpg
  echo "$file jpg change end"
#  rm -f $file
 end
# end
#   echo " END "

