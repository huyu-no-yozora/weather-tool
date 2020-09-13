#!/bin/bash
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
#===========================
#domain
domain=128/133/30/35
#draw map share option
pscoast_shareopt="-JM14 -R${domain} -Dh -S255/255/255 -G192/192/192 -P -W1 -X2 -Y2"
#draw velue share option
psxy_shareopt="-JM14 -R${domain} -Ba1f1g1/a1f1g1 -SV0.05/0.1/0.1 -G0/0/255 -X0 -Y0"
#################################################################
########################## [ 設定事項 ] ##########################
#################################################################

#########################################################################
### function
#########################################################################

#################################################################
##################### [ 設定関連の読み込み ] ######################
#################################################################
DATADIR=/work42/username/2017_0809_gust-tornado/Maeda_Winds
DATE=20170809
GMT_TOOL_DIR=/work42/username/Tools/newmek
# apply the usersettings
source ${GMT_TOOL_DIR}/horizontalmeanwind/usersetting_for_selectwind_horizontaldist_eachtime_eachstation
# apply functions
source ${GMT_TOOL_DIR}/share/share_function
source ${GMT_TOOL_DIR}/horizontalmeanwind/selectwind_horizontaldist_function_eachtime_eachstation
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
###########################
#timecounterを基に図を作成
for station_num in $(seq ${s_station_num} ${e_station_num})
do
  ###############################################################
  # initial counter settings
  _initial_read_counter_        #(dependence: nothing) =>station_read_counter,wind_read_counter
  ###############################################################
  # station_numの文字数を揃える(for file name)
  _mod_station_num_interface_   #(dependence: station_num) =>mod_station_num
  #緯度経度情報のFRAG
  _lonlat_interface_            #(dependence: station_read_counter) =>awk_shareopt
##################################
  time_counter=1
##################################
  #############################################
  #******************************#
  # [A.M.] #(00:00:01~11:59:60)
  AMorPM=1
  hour=0; min=0; second=1
  HOUR=00; MIN=00; SECOND=01
  while [ "${time_counter}" -le 43201 ]; do
    echo "*************************************"
    #時間に関する文字数をそろえる
    _time_interface_             #(dependence: time_step,hour,min,second)=>HOUR,MIN,SECOND
    #**************************************************#
    #*** [時刻とstation番号が必要な設定事項(変数)の宣言] ***#
    #**************************************************#
    ##[Format関係]##
    #出力する画像ファイルのディレクトリ及びファイル名のFormat
    _image_format_definition_    #(dependence: mod_station_num,AMorPM,HOUR,MIN,SECOND)
    # format as for MOMENT WIND or MEAN WIND
    _winddir_format_definition_  #(dependence: mod_station_num,AMorPM)
    #===========================================
    ##[directoryname & filename declare]##
    #出力する画像ファイルのディレクトリ及びファイル名を定義
    _image_definition_           #(dependence: mod_station_num,AMorPM,HOUR,MIN,SECOND)
    # definition of MOMENT_WIND_DIR or MEAN_WIND_DIR
    _wind_dir_file_definition_   #(dependence: mod_station_num,AMorPM)
    #**************************************************#
    #*** [時刻とstation番号が必要な設定事項(変数)の宣言] ***#
    #**************************************************#
    
    #*************************************************#
    #******** [data modification and drawing] ********#
    #*************************************************#
    # definition of SELECT_WINDFILE and say MOMENT or MEAN WIND
    _def_slected_windfile        #(dependence: almost nothing) =>SELECT_WINDFILE
    ##[wind direction and wind speed の修正(微調整)]##
    _wind_interface_             #(dependence: SELECT_WINDFILE,wind_read_counter)
    #drawing map
    pscoast ${pscoast_shareopt} -K > ${IMAGE}
    # write the wind information to image
    awk -F, '{print '${awk_shareopt}'}' ${SELECT_WINDFILE} | psxy ${psxy_shareopt} -O >> ${IMAGE}
    #*************************************************#
    #******** [data modification and drawing] ********#
    #*************************************************#
    time_counter=$((time_counter + time_step_counter))
    # stepping counter for secmin 
    _secmin_counter_step_        #(dependence: time_step,sec_time_step or min_time_step) =>second,min
    echo "*************************************"
  done
##################################
  time_counter=1
  _initial_read_counter_
##################################
  #******************************#
  # [P.M.] #(12:00:01~23:59:60)
  AMorPM=2
  hour=12; min=0; second=1
  HOUR=12; MIN=00; SECOND=01
  while [ "${time_counter}" -le 43201 ]; do
    echo "*************************************"
    #時間に関する文字数をそろえる
    _time_interface_
    # format as for MOMENT WIND or MEAN WIND
    _winddir_format_definition_
    #出力する画像ファイルのディレクトリ及びファイル名のFormat
    _image_format_definition_
    #出力する画像ファイルのディレクトリ及びファイル名を定義
    _image_definition_
    #drawing map
    pscoast ${pscoast_shareopt} -K > ${IMAGE}
    #*************************************************#
    # definition of MOMENT_WIND_DIR or MEAN_WIND_DIR
    _wind_dir_file_definition_
    # definition of SELECT_WINDFILE and say MOMENT or MEAN WIND
    _def_slected_windfile_
    # modification of wind direction and wind speed
    _wind_interface_
    # write the wind information to image
    awk -F, '{print '${awk_shareopt}'}' ${SELECT_WINDFILE} | psxy ${psxy_shareopt} -O >> ${IMAGE}
    #*************************************************#
    time_counter=$((time_counter + time_step_counter)) 
    # stepping counter for secmin
    _secmin_counter_step_
    echo "*************************************"
  done
  #******************************#
  ###############################################################
done
#################################################################
############## [ 設定事項の追加の読み込み 及び 実行 ] ###############
#################################################################


################################################################
###################### [ 結合データの作成 ] #######################
# ('station number' 'lon' 'lat' 'wind direction' 'wind speed') #
################################################################



