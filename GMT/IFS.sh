#!/bin/bash
#-----------------#
echo -n "Parent Directory PATH:"
read DIR
echo -n "File Name:"
read FILENAME
#-----------------#
IFS_ORG=${IFS}
IFS=" "
cd $PWD

echo -e "This script is used for the case of like following cases ...

[Precondition]
既にスペースで区切られたファイルに成形されていること
[変換内容]
スペースで区切られたファイルを,で区切るように書き直す"


sed -e "s@${IFS}@,@g" ${DIR}/${FILENAME} >/dev/null
sed -e "s@,,,@, @g"${DIR} /${FILENAME} > /dev/null
sed -e "s@ @  @g" ${DIR}/${FILENAME} > /dev/null
sed -e "s@,,@, @g" ${DIR}/${FILENAME} > ${DIR}/tmp

less ${DIR}/tmp | grep -n ","

echo "If there are "," inclueded line, you should select "n"!!! "
echo -n "Can you preceed?[y/n]:"
read answer
if [ "${answer}" = "y" ]; then
  :
else
  echo "Stopped ..."
  exit
fi

sed -i -e "s@    @ @g" ${DIR}/tmp > /dev/null
sed -i -e "s@   @ @g" ${DIR}/tmp > /dev/null
sed -i -e "s@  @ @g" ${DIR}/tmp > /dev/null
sed -i -e "s@ @,@g" ${DIR}/tmp
sed -e "s@,@, @g" ${DIR}/tmp > ${DIR}/${FILENAME}
rm ${DIR}/tmp
IFS=${IFS_ORG}
exit

