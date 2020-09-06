#!/bin/bash
#
# [usage]
#  変換したいディレクトリ内で以下コマンドを実行
#  $ make_gif.sh *
#  
#  対称のファイル群のあるディレクトリ内で実行せよ！
#  すぐ下のsettingをしてから実行するだけ。
#  ディレクトリ内は欲しいデータの分のファイル群だけにして実行せよ。
# 
##################################################
# settings
imagetype=png
step_second="0.2"
size='640'
##################################################
echo -n "output_gif_filebasename: "
read output_gif_filebasename
##################################################
DIR=${PWD}
cd ${DIR}
#*********************
rm "${DIR}/${output_gif_filebasename}.gif" 2>/dev/null
rm -i -R ${DIR}/gif
#*********************

total_filenumber=$#
echo -e "\ntotal file number is ${total_filenumber}"
sleep 3

#declare -a files
for file in "$@"
do
  files=( "${files[@]}" ${file} )
done
#######################################################

mkdir ${DIR}/tmp
TMPDIR="${DIR}/tmp"
cp "${files[@]}" ${TMPDIR}/
cd ${TMPDIR}

num='001'
for org_file in "${files[@]}"
do
  convert -resize ${size}x -unsharp 2x1.4+0.5+0 -quality 100 -coalesce -verbose ${org_file} ${TMPDIR}/tmp${num}.${imagetype}
  num=$(expr ${num} + 1 )
  # modification of num (桁数を合わせる = こうしないとsortによる順番が変わってしまうため)
  if [ "${num}" -lt 10 ]; then
    num='00'"${num}"
  elif [ "${num}" -ge 10 -a "${num}" -lt 100 ]; then
  	num='0'${num}
  else
  	:
  fi
  if [ $(expr ${num} + 0) = "$#" ]; then break ; fi
done

# modification of step_second
if [ $(echo "${step_second} <= 1" | bc) = 1 ]; then
   mod_step_second=$(echo "$(echo ${step_second} | bc | sed "s@\.@0.@") * 100" | bc)
else
   mod_step_second=$(echo "${step_second} * 100" | bc)
fi
echo -e "\nmod_step_second : ${mod_step_second}"

# making animation gif
ORG_IFS=$IFS
IFS=$'\n'
sorted_tmpfiles=( $(echo ${TMPDIR}/tmp*.${imagetype} | sort -n) )
IFS=$ORG_IFS

echo -e "\nConverting Now ...\n\n"
convert -delay ${mod_step_second} $(echo "${sorted_tmpfiles[@]}") "${DIR}/${output_gif_filebasename}.gif"

#######################################################
mkdir ${DIR}/gif
mv "${DIR}/${output_gif_filebasename}.gif" ${DIR}/gif/

###################################################
cd ${DIR}
rm -R ${TMPDIR}
echo -e "\ngif make job is completed!\n"
exit
#########################################################
#made by huyu-no-yozora(2018/10/28)

