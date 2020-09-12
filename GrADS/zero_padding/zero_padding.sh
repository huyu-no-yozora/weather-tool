#!/bin/bash
#
# 桁数を合わせるScript
# 例) 1, 10, 100 -> 001, 010, 100
#
# renameしたいディレクトリの中で実行せよ！
#
#=====================================#
basename=total_precipitation_tendency
#filetype=ps
#=====================================#
echo "File Type : ex) ps, pdf, jpg, png, tiff, ...(anything)"
echo -n "File Type: "
read filetype
#=====================================#
parentdir=$PWD

rename "$basename" "$basename00" ${parentdir}/$basename?.$filetype
rename "$basename" "$basename0"  ${parentdir}/$basename??.$filetype
echo "finished ..."
exit

