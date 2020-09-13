#!/bin/bash
GMTTOOLDIR=/work42/username/Tools/gmt
#################################################################
########################## [ 設定事項 ] ##########################
#################################################################
s_station_num=1
e_station_num=123
MOMENTorMEAN=MEAN
mean_time=1min
time_step=1min
################################################
### rows of station(place) longitude and latitude information
#station_num_row=1
##緯度経度の列
station_lon_row=3
station_lat_row=2
#===========================
### MOMENT #windspeed_row=4,winddirection_row=5
### MEAN   #windspeed_row=3,winddirection_row=5
windspeed_row=4
winddirection_row=6
#correction value of wind speed
speed_scaling_value=0.15
#===========================
#[domain]
domain=128/133/30/35
#===========================
#[draw map share option]
#pscoast_shareopt="-JM14 -R${domain} -Dh -S255/255/255 -G192/192/192 -P -W1 -X2 -Y2"
pscoast_shareopt="-JM14 -R${domain} -Dh -S255/255/255 -P -W1 -X0 -Y0"
#[draw velue share option]
psxy_shareopt="-JM14 -R${domain} -Ba1f1g1/a1f1g1 -C${GMTTOOLDIR}/VECTOR/GMT_vector.cpt -SV0.1/0.25/0.25 -G255/0/150 -P -W3/0/0/0 -X0 -Y0"
#===========================
# [drawing option for sample vector]
sample_vec_psxyopt="-JM -R -B -SV0.1/0.15/0.15 -G0/0/0 -N -X0 -Y0"
sample_vec_pstextopt="-JM -R -B -G0/0/0 -X0 -Y0"
samplevec_pstext_inputinfo="132.8 29.6 16 0 0 5"
#===========================
# [psscale option for vector]  
vecscale_shareopt="-C${GMTTOOLDIR}/VECTOR/GMT_vector.cpt -Ef0.5 -D6.0/-1.0/12/0.6h -X0 -Y0"
#################################################################
########################## [ 設定事項 ] ##########################
#################################################################

#########################################################################
### function
function drawing_station_winddata() {
echo -e "*************************************"
echo "station_num : ${station_num}"
#============================================================#
# station_numの文字数を揃える(for file name)
_mod_station_num_interface_   #(dependence: station_num) =>mod_station_num
#緯度経度情報のFRAG
_lonlat_interface_            #(dependence: station_read_counter) =>awk_shareopt
#============================================================#

#**************************************************#
#*** [時刻とstation番号が必要な設定事項(変数)の宣言] ***#
#**************************************************#
#
#######################################################
# 入力する風向風速データ (Format 及び dirname & filename)  #
#  (station番号及び時刻で風向風速の値を指定しなければならない) #
#######################################################
# format as for MOMENT WIND or MEAN WIND
_winddir_format_definition_  #(dependence: mod_station_num,AMorPM)
# definition of MOMENT_WIND_DIR or MEAN_WIND_DIR
_wind_dir_file_definition_   #(dependence: mod_station_num,AMorPM)=> MOMENT_WINDFILE or MEAN_WINDFILE
#######################################################
# 入力する風向風速データ (Format 及び dirname & filename)  #
#######################################################
#
#**************************************************#
#*** [時刻とstation番号が必要な設定事項(変数)の宣言] ***#
#**************************************************#
#*************************************************#
#******** [data modification and drawing] ********#
#*************************************************#
# definition of SELECT_WINDFILE and say MOMENT or MEAN WIND
_def_slected_windfile_        #(dependence: MOMENT_WINDFILE or MEAN_WINDFILE) =>SELECT_WINDFILE
##[wind direction and wind speed の修正(微調整)]##
_wind_interface_             #(dependence: SELECT_WINDFILE,wind_read_counter)
# correction of wind data for dwaing and definition of awk options
_awk_shareopt_interface_
echo "wind_read_counter : ${wind_read_counter}"
echo "_IMAGE_NAME_ : ${_IMAGE_NAME_}"
# write the wind information to image
#++++* bcコマンドの結果は trueが 1, falseが 0であることに注意!!! *+++++
if   [ "$(echo "${org_direction} >= 0" | bc -l)" -eq "1" -a "${station_num}" -ne "${e_station_num}" ]; then
  #データが欠損しておらず、windデータの書き込みが " station_num = e_station_num "でない場合
  awk -F, '(NR=='${wind_read_counter}') {print '${awk_shareopt}'}' ${SELECT_WINDFILE} | psxy ${psxy_shareopt} -K -O >> ${IMAGE}
elif [ "$(echo "${org_direction} >= 0" | bc -l)" -eq "1" -a "${station_num}" -eq "${e_station_num}" ]; then
  #データが欠損しておらず、windデータの書き込みが最後のstation_numの時 ( station_num = e_station_num )の場合
  awk -F, '(NR=='${wind_read_counter}') {print '${awk_shareopt}'}' ${SELECT_WINDFILE} | psxy ${psxy_shareopt} -K -O >> ${IMAGE}
elif [ -z "${MOD_DIRECTION}" -a -z "${MOD_SPEED}" ]; then
  #データが欠損している場合
  echo "[${HOUR}:${MIN}:${SECOND} ; station_num = ${station_num}] Data is missing ... !!!" | ${log}
else
  echo -e "Strange Operation\nStopped\n"; exit
fi
#*************************************************#
#******** [data modification and drawing] ********#
#*************************************************#
echo -e "*************************************\n"
#if [ "${station_read_counter}" -eq "${e_station_num}" ]; then _initial_read_counter_; break ; fi
#上は間違い(wind_read_counterまで1に戻される)
if [ "${station_read_counter}" -eq "${e_station_num}" ]; then station_read_counter=1; break ; fi
}
#########################################################################

#################################################################
##################### [ 設定関連の読み込み ] ######################
#################################################################
DATADIR=/work42/username/2017_0809_gust-tornado/Maeda_Winds
DATE=20170809
GMT_TOOL_DIR=/work42/username/Tools/newmek
LOG_DIR=${GMT_TOOL_DIR}/horizontalmeanwind
log="tee ${LOG_DIR}/winddata_writing_error.log"
TOPODIR=/work42/username/Tools/gmt/TOPO
missing_value="-99.9"
sample_speed="5"
# apply the usersettings
source ${GMT_TOOL_DIR}/horizontalmeanwind/usersetting_for_selectwind_horizontaldist
# apply functions
source ${GMT_TOOL_DIR}/share/share_function
source ${GMT_TOOL_DIR}/horizontalmeanwind/selectwind_horizontaldist_topo_function
#######################################################
#stationの緯度経度情報ファイル(org_data/place.csvより抽出済みのファイル)
_modplace_format_definition_
MOD_PLACE_FILE=$(echo ${MOD_PLACE_FILE_FORMAT})
#######################################################
### [ 時刻関連( counter用 及び secmin用 のtimestep)のinterfaceの読み込み ]
# time_stepのカウンタに関するinterface
_timestep_counter_interface_   #(dependence: time_step)
# sec or min
_secmin_timestep_interface_    #(dependence: time_step)
#################################################################
##################### [ 設定関連の読み込み ] ######################
#################################################################
#
#################################################################
############## [ 設定事項の追加の読み込み 及び 実行 ] ###############
#################################################################
_select_wind_declare_
###############################################################
#timecounterを基に図を作成
#******************************#
# initial counter settings
time_counter=1
_initial_read_counter_        #(dependence: nothing) =>station_read_counter,wind_read_counter
# [A.M.] #(00:00:01~11:59:60)
AMorPM=1
hour=0; min=${min_time_step}; second=1
HOUR=00; MIN=0${min_time_step}; SECOND=01
while [ "${time_counter}" -le 43201 ]; do
  #==================================================================#
  #出力する画像ファイルのディレクトリ及びファイル名のFormat
  _image_format_definition_    #(dependence: AMorPM,HOUR,MIN,SECOND)
  #出力する画像ファイルのディレクトリ及びファイル名を定義
  _image_definition_           #(dependence: AMorPM,HOUR,MIN,SECOND)
  #=============================
  #dwaing topograpy
  _topo_drawing_settings_
  grdcut ${grdcut_shareopt}
  grdimage ${grdimage_shareopt} -K > ${IMAGE}
  psscale ${psscale_shareopt} -K -O >> ${IMAGE}
  #drawing map(${IMAGE} does NOT depend the station_num)
  pscoast ${pscoast_shareopt} -K -O >> ${IMAGE}
  #==================================================================#

  #*****************************************#
  # drawing wind data on each station point
  for station_num in $(seq ${s_station_num} ${e_station_num}); do
    #set -x
    drawing_station_winddata
    #
    station_read_counter=$((station_read_counter+1))
    #set +x
  done
  #*****************************************#

  #*****************************************#
  # shading of vector information
  psscale ${vecscale_shareopt} -K -O >> ${IMAGE}
  #==============================#
  # sample vector
  _sample_wind_interface_
  echo 132.8 29.4 90 ${SCALING_SAMPLE_SPEED}|\
  psxy ${sample_vec_psxyopt} -K -O >> ${IMAGE}
  pstext ${sample_vec_pstextopt} -K -O -N <<EOF>> ${IMAGE}
${samplevec_pstext_inputinfo} ${sample_speed}m/s
EOF
  #==============================#
  #title
  pstext -JM -R -B -G0/0/0 -X -Y -O -N <<EOF >> ${IMAGE}
130.5 35.4 20 0 0 6 ${time_step} ave. Wind 2017 AUG 9 $HOUR:$MIN JST
EOF
  #*****************************************#

  #=========================[counter]=========================#
  #地点毎に風速のデータがある => SELECT_WINDFILEで選択 => 時刻に応じた行を(wind_read_counterで切り替えて)読み込んでいけば良い !!!
  set -x
  wind_read_counter=$((wind_read_counter+1))
  set +x
  #============( second,SECOND etc )============#
  # stepping counter for secmin
  _secmin_counter_step_        #(dependence: time_step,sec_time_step or min_time_step) =>second,min
  #時間に関する文字数をそろえる及びHOUR,MIN,SECONDの定義
  _time_interface_             #(dependence: time_step,hour,min,second)=>HOUR,MIN,SECOND
  #============( second,SECOND etc )============#
  
  # For while loop
  time_counter=$((time_counter + time_step_counter))
  #=========================[counter]=========================#
done
##################################
# initial counter settings
time_counter=1
_initial_read_counter_        #(dependence: nothing) =>station_read_counter,wind_read_counter
##################################
#******************************#
# [P.M.] #(12:00:01~23:59:60)
AMorPM=2
hour=12; min=${min_time_step}; second=1
HOUR=12; MIN=0${min_time_step}; SECOND=01
while [ "${time_counter}" -le 43201 ]; do
  #==================================================================#
  #出力する画像ファイルのディレクトリ及びファイル名のFormat
  _image_format_definition_    #(dependence: AMorPM,HOUR,MIN,SECOND)
  #出力する画像ファイルのディレクトリ及びファイル名を定義
  _image_definition_           #(dependence: AMorPM,HOUR,MIN,SECOND)
  #=============================
  #dwaing topograpy
  _topo_drawing_settings_
  grdcut ${grdcut_shareopt}
  grdimage ${grdimage_shareopt} -K > ${IMAGE}
  psscale ${psscale_shareopt} -K -O >> ${IMAGE}
  #drawing map(${IMAGE} does NOT depend the station_num)
  pscoast ${pscoast_shareopt} -K -O >> ${IMAGE}
  #==================================================================#

  #*****************************************#
  # drawing wind data on each station point
  for station_num in $(seq ${s_station_num} ${e_station_num}); do
    drawing_station_winddata
    #
    #if [ "${station_read_counter}" -eq "${e_station_num}" ]; then _initial_read_counter_; break ; fi
    station_read_counter=$((station_read_counter+1))
  done
  #*****************************************#

  #*****************************************#
  # shading of vector information
  psscale ${vecscale_shareopt} -K -O >> ${IMAGE}
  #==============================#
  # sample vector
  _sample_wind_interface_
  echo 132.8 29.4 90 ${SCALING_SAMPLE_SPEED}|\
  psxy ${sample_vec_psxyopt} -K -O >> ${IMAGE}
  pstext ${sample_vec_pstextopt} -K -O -N <<EOF>> ${IMAGE}
${samplevec_pstext_inputinfo} ${sample_speed}m/s
EOF
  #==============================#
  #title
  pstext -JM -R -B -G0/0/0 -X -Y -O -N <<EOF >> ${IMAGE}
130.5 35.4 20 0 0 6 ${time_step} ave. Wind 2017 AUG 9 $HOUR:$MIN JST
EOF
  #*****************************************#

  #=========================[counter]=========================#
  #地点毎に風速のデータがある => SELECT_WINDFILEで選択 => 時刻に応じた行を(wind_read_counterで切り替えて)読み込んでいけば良い !!!
  wind_read_counter=$((wind_read_counter+1))

  #============( second,SECOND etc )============#
  # stepping counter for secmin
  _secmin_counter_step_        #(dependence: time_step,sec_time_step or min_time_step) =>second,min
  #時間に関する文字数をそろえる及びHOUR,MIN,SECONDの定義
  _time_interface_             #(dependence: time_step,hour,min,second)=>HOUR,MIN,SECOND
  #============( second,SECOND etc )============#
  
  # For while loop
  time_counter=$((time_counter + time_step_counter))
  #=========================[counter]=========================#
done
#******************************#
###############################################################
#
#################################################################
############## [ 設定事項の追加の読み込み 及び 実行 ] ###############
#################################################################


