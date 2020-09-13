#!/bin/bash
################################################################
# write the wind information to image
function drawing_stationmeanwind() {
if [ "${station_num}" -ne "${e_station_num}" ]; then
  awk -F, '{print '${awk_shareopt}'}' ${SELECT_WINDFILE} | psxy ${psxy_shareopt} -K -O >> ${IMAGE}
elif [ "${station_num}" -eq "${e_station_num}" ]; then
  awk -F, '{print '${awk_shareopt}'}' ${SELECT_WINDFILE} | psxy ${psxy_shareopt} -O >> ${IMAGE}
else
  echo -e "Strange Operation\nStopped\n"; exit
fi
}
station_num=1
################################################################
DATADIR=/work42/username/2017_0809_gust-tornado/Maeda_Winds
DATE=20170809
GMT_TOOL_DIR=/work42/username/Tools/newmek
source ${GMT_TOOL_DIR}/stationmeanwind/usersetting_for_station_meanwind
source ${GMT_TOOL_DIR}/share/share_function
################################################################
MOMENTorMEAN=MEAN
mean_time=1min
time_step=1min
#===========================
### MOMENT #windspeed_row=4,winddirection_row=5
### MEAN   #windspeed_row=3,winddirection_row=5
windspeed_row=4
winddirection_row=6
#===========================
#domain=128/133/30/35
pscoast_shareopt="-JX14T/14 -Dh -S255/255/255 -G192/192/192 -P -W1 -X2 -Y2"
#draw velue share option
psxy_shareopt="-JX14T/14 -RT00:00:01/T12:00:00/0/1000 -Ba30mf10mg10m/a510g10WeSn \
-SV0.05/0.1/0.1 -G0/0/255 -P -X0 -Y0"
###################################






_select_wind_declare_
# definition of mod_station_num
_mod_station_num_interface_
##stationの緯度経度情報ファイル(org_data/place.csvより抽出済みのファイル)
#_modplace_format_definition_
#MOD_PLACE_FILE=$(echo ${MOD_PLACE_FILE_FORMAT})
###################################



