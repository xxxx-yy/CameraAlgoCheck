configPath=./config.txt
TIME_WAIT_NORMAL=1
TIME_WAIT_PREVIEW_RESULT=5
TIME_WAIT_CAPTURE_DONE=5

AISCENE_RESULT_ENUM=("Default" "食物" "人像" "植物" "N/A" "夜景" "N/A" "文档" "N/A" "N/A" "N/A" "N/A" "N/A" "N/A" "N/A" "花朵")

#LOG_TAG:LOG_LEVEL	KEY_WORD	LOG_FILE
SPRD_AISCENE_VERSION_INFO=("AIC:I" "CAM_ALGO_CV_SD_LIBVER" "logcat_ai_scene_version.txt")
SPRD_AISCENE_RESULT_INFO=("Cam3OEMIf:D" "sprd_ai_scene_type_current" "logcat_ai_scene_result.txt")

TRAN_ASD_VERSION_INFO=("TranCam-ASD:I" "Version" "logcat_ai_asd_version.txt")
TRAN_ASD_RESULT_INFO=("TranCam-ASD:D" "ASD to APP result" "logcat_ai_asd_result.txt")

SPRD_HDR_VERSION_INFO=("hdr2:D" "hdr" "logcat_ai_hdr_version.txt")
SPRD_HDR_CAP_TIME_INFO=("sprdhdr2:I" "sprd_hdr_process:" "logcat_ai_hdr_cap_time.txt")

SPRD_MFNR_VERSION_INFO=("TDNS_LOG:D" "CAM_ALGO_CV_MFNR_LIBVER" "logcat_mfnr_version.txt")
SPRD_MFNR_CAP_BEGIN_INFO=("TDNS_LOG:D" "mfnr init handle pos" "logcat_mfnr_begin_time.txt")
SPRD_MFNR_CAP_END_INFO=("TDNS_LOG:D" "mfnr_deinit func finish, run time" "logcat_mfnr_end_time.txt")

TRAN_FB_VERSION_INFO=("TranCam-FaceBeauty:I" "tran FB version" "logcat_fb_version.txt")
TRAN_FB_LEVELS_INFO=("CamAp_ItelFaceBeautySet:I" "supportList" "logcat_fb_level_list.txt")
TRAN_FB_INDEX_INFO=("CamAp_ItelFaceBeautySet:I" "mCurrentEntryValue" "logcat_fb_current_level.txt")
TRAN_FB_PREV_PERF_INFO=("TranCam-FaceBeauty:D" "\[processPreview\]E|\[processPreview\]X ret=0" "logcat_fb_prev_time.txt")
TRAN_FB_CAP_BEGIN_INFO=("TranCam-FaceBeauty:D" "\[processRaw\]E" "logcat_fb_cap_begin_time.txt")
TRAN_FB_CAP_END_INFO=("TranCam-FaceBeauty:D" "\[processRaw\]X ret=0" "logcat_fb_cap_end_time.txt")
TRAN_FB_CUR_INDEX_INFO=("CamAp_ItelFaceBeautySet:D" "set Degree To Devices|\[updateEntryView\] mCurrentEntryValue" "logcat_fb_cur_index.txt")

ST_PORTRAIT_PREV_VERSION_INFO=("singlecam_blur_preview:I" "version" "logcat_portrait_prev_version.txt")
ST_PORTRAIT_CAP_VERSION_INFO=("singlecam_blur_capture:I" "version" "logcat_portrait_cap_version.txt")
ST_PORTRAIT_CAP_BEGIN_INFO=("TranCam-STSingleBlur:I" "\[processRaw\]E" "logcat_portrait_cap_begin_time.txt")
ST_PORTRAIT_CAP_END_INFO=("TranCam-STSingleBlur:I" "\[processRaw\]X" "logcat_portrait_cap_end_time.txt")

ARC_FILTER_CAP_BEGIN_INFO=("TranCam-ArcFilter:I" "\[processRaw\]\+" "logcat_filter_cap_begin_time.txt")
ARC_FILTER_CAP_END_INFO=("TranCam-ArcFilter:I" "\[processRaw\]\-" "logcat_filter_cap_end_time.txt")

TRAN_PHOTO_WM_BEGIN_TIME=("TranCam-WaterMark:I" "\[processRaw\]\+|\[processRaw\]E" "logcat_photo_wm_cap_begin_time.txt")
TRAN_PHOTO_WM_END_TIME=("TranCam-WaterMark:I" "\[processRaw\]\-|\[processRaw\]X" "logcat_photo_wm_cap_end_time.txt")

#检测命令
CMD_SPRD_AISCENE=0
CMD_TRAN_ASD=1
CMD_SPRD_HDR=2
CMD_SPRD_MFNR=3
CMD_TRAN_FB=4
CMD_ST_PORTRAIT=5
CMD_ARC_FILTER=6
CMD_TRAN_WATERMARK=7

aiscene_version_pid=0
aiscene_result_pid=0
asd_version_pid=0
asd_result_pid=0
tran_fb_version_pid=0
tran_fb_levels_pid=0
tran_fb_index_pid=0
tran_fb_perf_pid=0
st_portrait_prev_version_pid=0

sprd_hdr_version_pid=0
sprd_hdr_cap_time_pid=0
sprd_mfnr_version_pid=0
sprd_mfnr_version_begin_pid=0
sprd_mfnr_version_end_pid=0
tran_fb_cap_begin_pid=0
tran_fb_cap_end_pid=0
st_portrait_cap_version_pid=0
st_portrait_cap_begin_pid=0
st_portrait_cap_end_pid=0
arc_filter_cap_begin_pid=0
arc_filter_cap_end_pid=0
tran_photoWM_cap_begin_pid=0
tran_photoWM_cap_end_pid=0

#==============================================================================
# 欢迎界面
#==============================================================================
hint() {
	echo "********************************************************************"
	echo "* Preconditions: 请在执行该脚本前确认并修改配置文件的信息，        *"
	echo "*                并将配置文件与该脚本放置在同一路径下。            *"
	echo "********************************************************************"
	echo "* Tips: 该脚本为半自动化测试，请根据提示信息寻找场景配合测试。     *"
	echo "********************************************************************"
}

#==============================================================================
# 读取${configPath}文件中配置的可支持的检查项目
#==============================================================================
getProductList() {
	productList=($(grep "PRODUCT=" $configPath | awk -F '=' '{print $2}'))
}

#==============================================================================
# 根据用户选择的测试项目，读取${configPath}文件的对应项目所在的行
#==============================================================================
getRegion() {
    local productName=$1
    cat -n $configPath | grep "PRODUCT=" | grep -A 1 "PRODUCT=$productName" | awk '{print $1}' | xargs
}

#==============================================================================
# 根据用户选择的测试项目，读取${configPath}文件的对应项目配置
#==============================================================================
getConfig() {
    local productName=$1
    local region=$(getRegion $productName)
    local startLine=$(echo $region | awk '{print $1}')
    local endLine=$(echo $region | awk '{print $2}')
	if [ ! $endLine ]; then
		endLine=$(cat -n $configPath | tail -n 1 | awk '{print $1}')
	else
		endLine=$(($endLine-1))
	fi
	product=$(sed -n "${startLine}, ${endLine} {/PRODUCT=.*/p}" $configPath | awk -F '=' '{print $2}')
	android_version=$(sed -n "${startLine}, ${endLine} {/ANDROID_VERSION=.*/p}" $configPath | awk -F '=' '{print $2}')
	brand=$(sed -n "${startLine}, ${endLine} {/BRAND=.*/p}" $configPath | awk -F '=' '{print $2}')
	photo_hdr=$(sed -n "${startLine}, ${endLine} {/PHOTO_HDR=.*/p}" $configPath | awk -F '=' '{print $2}')
	photo_lowlight=$(sed -n "${startLine}, ${endLine} {/PHOTO_LOWLIGHT=.*/p}" $configPath | awk -F '=' '{print $2}')
	photo_fb=$(sed -n "${startLine}, ${endLine} {/PHOTO_FB=.*/p}" $configPath | awk -F '=' '{print $2}')
	fb_level=$(sed -n "${startLine}, ${endLine} {/FB_LEVEL=.*/p}" $configPath | awk -F '=' '{print $2}')
	fb_mode=$(sed -n "${startLine}, ${endLine} {/FB_MODE=.*/p}" $configPath | awk -F '=' '{print $2}')
	portrait_mode=$(sed -n "${startLine}, ${endLine} {/PORTRAIT_MODE=.*/p}" $configPath | awk -F '=' '{print $2}')
	nightscene_mode=$(sed -n "${startLine}, ${endLine} {/NIGHTSCENE_MODE=.*/p}" $configPath | awk -F '=' '{print $2}')
	hdr_mode=$(sed -n "${startLine}, ${endLine} {/HDR_MODE=.*/p}" $configPath | awk -F '=' '{print $2}')
	filter=$(sed -n "${startLine}, ${endLine} {/FILTER=.*/p}" $configPath | awk -F '=' '{print $2}')
	photo_wm=$(sed -n "${startLine}, ${endLine} {/PHOTO_WM=.*/p}" $configPath | awk -F '=' '{print $2}')
	video_wm=$(sed -n "${startLine}, ${endLine} {/VIDEO_WM=.*/p}" $configPath | awk -F '=' '{print $2}')
	asd_brand=$(sed -n "${startLine}, ${endLine} {/ASD_ALGO=.*/p}" $configPath | awk -F '=' '{print $2}')
	hdr_brand=$(sed -n "${startLine}, ${endLine} {/HDR_ALGO=.*/p}" $configPath | awk -F '=' '{print $2}')
	nightscene_mode_algo=$(sed -n "${startLine}, ${endLine} {/NIGHTSCENE_ALGO=.*/p}" $configPath | awk -F '=' '{print $2}')
	fb_brand=$(sed -n "${startLine}, ${endLine} {/FB_ALGO=.*/p}" $configPath | awk -F '=' '{print $2}')
	blur_brand=$(sed -n "${startLine}, ${endLine} {/BLUR_ALGO=.*/p}" $configPath | awk -F '=' '{print $2}')
	filter_brand=$(sed -n "${startLine}, ${endLine} {/FILTER_ALGO=.*/p}" $configPath | awk -F '=' '{print $2}')
	photo_wm_brand=$(sed -n "${startLine}, ${endLine} {/PHOTO_WM_ALGO=.*/p}" $configPath | awk -F '=' '{print $2}')
	video_wm_brand=$(sed -n "${startLine}, ${endLine} {/VIDEO_WM_ALGO=.*/p}" $configPath | awk -F '=' '{print $2}')
	continuous_cap=$(sed -n "${startLine}, ${endLine} {/CONTINUOUS_CAP=.*/p}" $configPath | awk -F '=' '{print $2}')
	if [ ${brand,,} == "tecno" ] || [ ${brand,,} == "itel" ] || [ ${brand,,} == "infinix" ]; then
		printNormalTip "当前相机brand为${brand}"
	else
		echo "ERROR!!!请检查配置文件中的brand配置，本脚本只支持检查TECNO、ITEL或INFINIX其中一种。\n"
	fi
}

#==============================================================================
# 提示用户选择对应的测试项目
#==============================================================================
chooseProduct() {
	local num=0
	for item in ${productList[*]}
	do
		num=$(($num+1))
		echo "$num: $item"
	done
	echo -n "请选择项目名[若选项中无所需项目，请在配置文件中按要求添加]: "
	read num
	echo "读取配置文件中，请稍后..."
	getConfig ${productList[$(($num-1))]}
}

#==============================================================================
# 格式化输出每个模式场景的名称
# $1 : 模式场景的名称
#==============================================================================
printModeName() {
	echo "********************************************************************"
	echo "模式场景: $1"
	echo "********************************************************************"
}

#==============================================================================
# 格式化每个模式场景中需要检查的算法的简称
# $1 : 算法的简称
#==============================================================================
printAlgoName() {
	echo "算法名称: $1"
	echo "--------------------------------------------------------------------"
}

#==============================================================================
# 格式化每个模式场景中检查的交互语句
# $1 : 交互语句
#==============================================================================
printInteractTip() {
	echo -n "提    示: $1"
}

#==============================================================================
# 输出分隔行
#==============================================================================
printDivideLine() {
	echo "--------------------------------------------------------------------"
}

#==============================================================================
# 格式化每个模式场景中检查的提示信息
# $1 : 提示信息
#==============================================================================
printNormalTip() {
	echo "提    示: $1"
	echo "--------------------------------------------------------------------"
}

#==============================================================================
# 格式化每个模式场景中检查的结果
# $1 : 结果内容
#==============================================================================
printResult() {
	echo -e "检查结果: \e[32m$1\e[0m"
	echo "--------------------------------------------------------------------"
}

#==============================================================================
# 格式化输出异常结果
# $1 : 结果内容
#==============================================================================
printErrorResult() {
	echo -e "\e[31m检查结果: \e[32m$1\e[0m"
	echo "--------------------------------------------------------------------"
}

#==============================================================================
# 格式化输出配置错误的提示信息
# $1 : 错误提示语
# $2 : 配置错误的名称
# $3 : 配置的可选参数 1
# $4 : 配置的可选参数 2
#==============================================================================
printErrorConfigMsgAndExit() {
	echo -e "\e[31m===>[$1]场景检查失败，请稍后重试\e[0m"
	echo -e "\e[31m===>请检查[$2]配置是否正确，可配置选项为[$3|$4]，不区分大小写\e[0m"
	exit 1
}

#==============================================================================
# 用于正常删除文件
#==============================================================================
deleteFile() {
	if [ -e $1 ]; then 
		rm $1
	fi
}

#==============================================================================
# 抓取预览过程中关键信息
# $1 : LOG_TAG:LOG_LEVEL
# $2 : 日志关键字
# $3 : 日志保存文件
#==============================================================================
grabOneInfo() {
	adb logcat -v brief -b main $1 *:S --regex "$2" > $3 &
	echo "$!"
}

#==============================================================================
# 抓取预览过程中关键信息
# $1 : LOG_TAG:LOG_LEVEL
# $2 : 日志关键字
# $3 : 日志保存文件
#==============================================================================
grabOneInfoWithTime() {
	adb logcat -v time -b main $1 *:S --regex "$2" > $3 &
	echo "$!"
}

#==============================================================================
# 开始预览场景所有算法和功能的关键信息抓取
# $@ 需要检测的算法对应命令参数
#==============================================================================
previewStartGrabInfos() {
	#printInteractTip "生成的中间文件即将被覆盖，如需查看请先查看，按回车确认覆盖"
	#read CMD
	#printDivideLine
	adb logcat -c

	for item in $@
	do
		case $item in
        $CMD_SPRD_AISCENE)
            #sprd aiscene
			deleteFile ${SPRD_AISCENE_VERSION_INFO[2]}
			deleteFile ${SPRD_AISCENE_RESULT_INFO[2]}
			aiscene_version_pid=$(grabOneInfo "${SPRD_AISCENE_VERSION_INFO[@]}")
			aiscene_result_pid=$(grabOneInfo "${SPRD_AISCENE_RESULT_INFO[@]}")
            ;;
        $CMD_TRAN_ASD)
            #tran asd
			deleteFile ${TRAN_ASD_VERSION_INFO[2]}
			deleteFile ${TRAN_ASD_RESULT_INFO[2]}
			asd_version_pid=$(grabOneInfo "${TRAN_ASD_VERSION_INFO[@]}")
			asd_result_pid=$(grabOneInfo "${TRAN_ASD_RESULT_INFO[@]}")
            ;;
		$CMD_TRAN_FB)
            #tran fb
			deleteFile ${TRAN_FB_VERSION_INFO[2]}
			deleteFile ${TRAN_FB_LEVELS_INFO[2]}
			deleteFile ${TRAN_FB_INDEX_INFO[2]}
			deleteFile ${TRAN_FB_PREV_PERF_INFO[2]}
			tran_fb_version_pid=$(grabOneInfo "${TRAN_FB_VERSION_INFO[@]}")
			tran_fb_levels_pid=$(grabOneInfo "${TRAN_FB_LEVELS_INFO[@]}")
			tran_fb_index_pid=$(grabOneInfo "${TRAN_FB_INDEX_INFO[@]}")
			tran_fb_perf_pid=$(grabOneInfoWithTime "${TRAN_FB_PREV_PERF_INFO[@]}")
            ;;
		$CMD_ST_PORTRAIT)
            #st portrait
			deleteFile ${ST_PORTRAIT_PREV_VERSION_INFO[2]}
			st_portrait_prev_version_pid=$(grabOneInfo "${ST_PORTRAIT_PREV_VERSION_INFO[@]}")
            ;;
		esac
	done
}

#==============================================================================
# 停止预览场景所有算法和功能的关键信息抓取
# $@ 开启了检测的算法对应命令参数
#==============================================================================
previewStopGrabInfos() {
	for item in $@
	do
		case $item in
        $CMD_SPRD_AISCENE)
            #sprd aiscene
			kill $aiscene_version_pid
			kill $aiscene_result_pid
            ;;
		$CMD_TRAN_ASD)
            #tran asd
			kill $asd_version_pid
			kill $asd_result_pid
            ;;
		$CMD_TRAN_FB)
            #tran fb
			kill $tran_fb_version_pid
			kill $tran_fb_levels_pid
			kill $tran_fb_index_pid
			kill $tran_fb_perf_pid
            ;;
		$CMD_ST_PORTRAIT)
            #st portrait
			kill $st_portrait_prev_version_pid
            ;;
		esac
	done
}

#==============================================================================
# 分析预览场景所有算法和功能的关键信息,并整理输出
#==============================================================================
previewInfosAnalysis() {
	for item in $@
	do
		case $item in
        $CMD_SPRD_AISCENE)
			#sprd aiscene
			local aiscene_version=$(sed -n "2p" ${SPRD_AISCENE_VERSION_INFO[2]} | awk -F '[' '{print $3}' | awk -F ']' '{print $1}')
			if [[ ${aiscene_version} != "" ]]; then
				printResult "[AIScene版本为: $aiscene_version]"
			fi
			local aiscene_result=$(sed -n "2p" ${SPRD_AISCENE_RESULT_INFO[2]} | awk -F ':' '{print $4}')
			if [[ ${aiscene_result} != "" ]]; then
				printResult "[AIScene识别到: ${AISCENE_RESULT_ENUM[aiscene_result]}]"
			fi
            ;;
		$CMD_TRAN_ASD)
            #tran asd
			local asd_version=$(sed -n "2p" ${TRAN_ASD_VERSION_INFO[2]} | awk -F ':' '{print $3}')
			if [[ ${asd_version} != "" ]]; then
				printResult "[ASD版本为: $asd_version]"
			fi
			local illumination_type=$(sed -n "2p" ${TRAN_ASD_RESULT_INFO[2]} | awk -F ':' '{print $3}' | awk -F ',' '{print $1}' | awk -F '=' '{print $2}')
			local scene_type=$(sed -n "2p" ${TRAN_ASD_RESULT_INFO[2]} | awk -F ':' '{print $3}' | awk -F ',' '{print $2}' | awk -F '=' '{print $2}')
			if [[ ${illumination_type} != "" ]]; then
				printResult "[ASD识别到: 明亮度：$illumination_type]"
			fi
			if [[ ${scene_type} != "" ]]; then
				printResult "[           场  景：$scene_type]"
			fi
            ;;
		$CMD_TRAN_FB)
            #tran fb
			local fb_version=$(sed -n "2p" ${TRAN_FB_VERSION_INFO[2]} | awk -F ':' '{print $3}')
			if [[ ${fb_version} != "" ]]; then
				printResult "[FaceBeauty当前的版本为: $fb_version]"
			fi
			local fb_currLev=$(sed -n "2p" ${TRAN_FB_INDEX_INFO[2]} | awk -F '=' '{print $2}' | awk -F ',' '{print $1}')
			if [[ ${fb_currLev} != "" ]]; then
				printResult "[FaceBeauty当前的等级为: $fb_currLev]"
			fi
			local levelList=$(sed -n "2p" ${TRAN_FB_LEVELS_INFO[2]} | awk -F ':' '{print $3}')
			if [[ ${levelList} != "" ]]; then
				printResult "[配置文件中配置的该项目FaceBeauty支持的最高等级为: $fb_level]"
				printResult "[FaceBeauty实际支持的等级有: $levelList]"
			fi
			if [ `tail -n 1 ${TRAN_FB_PREV_PERF_INFO[2]} | grep -c "X ret=0"` -eq 0 ]; then
				local startTime=$(tail -n 3 ${TRAN_FB_PREV_PERF_INFO[2]} | head -n 1 | awk '{print $1 " " $2}')
				local endTime=$(tail -n 2 ${TRAN_FB_PREV_PERF_INFO[2]} | head -n 1 | awk '{print $1 " " $2}')
			else
				local startTime=$(tail -n 2 ${TRAN_FB_PREV_PERF_INFO[2]} | head -n 1 | awk '{print $1 " " $2}')
				local endTime=$(tail -n 1 ${TRAN_FB_PREV_PERF_INFO[2]} | awk '{print $1 " " $2}')
			fi
			local time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
			if [[ ${time} != "" && ${time} != 0 ]]; then
				printResult "[美颜预览处理耗时为: $time ms]"
			fi
            ;;
		$CMD_ST_PORTRAIT)
            #st portrait
			local st_version=$(sed -n "2p" ${ST_PORTRAIT_PREV_VERSION_INFO[2]} | awk -F '=' '{print $2}')
			if [[ ${st_version} != "" ]]; then
				printResult "[预览虚化版本为: $st_version]"
			fi
            ;;
		esac
	done
}

#==============================================================================
# 开始拍照场景所有算法和功能的关键信息抓取
#==============================================================================
captureStartGrabInfos() {
	#printInteractTip "生成的中间文件即将被覆盖，如需查看请先查看，按回车确认覆盖"
	#read CMD
	#printDivideLine
	adb logcat -c
	
	for item in $@
	do
		case $item in
        $CMD_SPRD_HDR)
            #sprd hdr
			deleteFile ${SPRD_HDR_VERSION_INFO[2]}
			deleteFile ${SPRD_HDR_CAP_TIME_INFO[2]}
			sprd_hdr_version_pid=$(grabOneInfo "${SPRD_HDR_VERSION_INFO[@]}")
			sprd_hdr_cap_time_pid=$(grabOneInfo "${SPRD_HDR_CAP_TIME_INFO[@]}")
            ;;
		$CMD_SPRD_MFNR)
            #sprd mfnr
			deleteFile ${SPRD_MFNR_VERSION_INFO[2]}
			deleteFile ${SPRD_MFNR_CAP_BEGIN_INFO[2]}
			deleteFile ${SPRD_MFNR_CAP_END_INFO[2]}
			sprd_mfnr_version_pid=$(grabOneInfo "${SPRD_MFNR_VERSION_INFO[@]}")
			sprd_mfnr_version_begin_pid=$(grabOneInfoWithTime "${SPRD_MFNR_CAP_BEGIN_INFO[@]}")
			sprd_mfnr_version_end_pid=$(grabOneInfoWithTime "${SPRD_MFNR_CAP_END_INFO[@]}")
            ;;
		$CMD_TRAN_FB)
            #tran fb
			deleteFile ${TRAN_FB_CAP_BEGIN_INFO[2]}
			deleteFile ${TRAN_FB_CAP_END_INFO[2]}
			tran_fb_cap_begin_pid=$(grabOneInfoWithTime "${TRAN_FB_CAP_BEGIN_INFO[@]}")
			tran_fb_cap_end_pid=$(grabOneInfoWithTime "${TRAN_FB_CAP_END_INFO[@]}")
            ;;
		$CMD_ST_PORTRAIT)
            #st portrait
			deleteFile ${ST_PORTRAIT_CAP_VERSION_INFO[2]}
			deleteFile ${ST_PORTRAIT_CAP_BEGIN_INFO[2]}
			deleteFile ${ST_PORTRAIT_CAP_END_INFO[2]}
			st_portrait_cap_version_pid=$(grabOneInfo "${ST_PORTRAIT_CAP_VERSION_INFO[@]}")
			st_portrait_cap_begin_pid=$(grabOneInfoWithTime "${ST_PORTRAIT_CAP_BEGIN_INFO[@]}")
			st_portrait_cap_end_pid=$(grabOneInfoWithTime "${ST_PORTRAIT_CAP_END_INFO[@]}")
            ;;
		$CMD_ARC_FILTER)
            #arc filter
			deleteFile ${ARC_FILTER_CAP_BEGIN_INFO[2]}
			deleteFile ${ARC_FILTER_CAP_END_INFO[2]}
			arc_filter_cap_begin_pid=$(grabOneInfoWithTime "${ARC_FILTER_CAP_BEGIN_INFO[@]}")
			arc_filter_cap_end_pid=$(grabOneInfoWithTime "${ARC_FILTER_CAP_END_INFO[@]}")
            ;;
		$CMD_TRAN_WATERMARK)
            #tran_photo_wm
			deleteFile ${TRAN_PHOTO_WM_BEGIN_TIME[2]}
			deleteFile ${TRAN_PHOTO_WM_END_TIME[2]}
			tran_photoWM_cap_begin_pid=$(grabOneInfoWithTime "${TRAN_PHOTO_WM_BEGIN_TIME[@]}")
			tran_photoWM_cap_end_pid=$(grabOneInfoWithTime "${TRAN_PHOTO_WM_END_TIME[@]}")
            ;;
		esac
	done
}

#==============================================================================
# 停止拍照场景所有算法和功能的关键信息抓取
#==============================================================================
captureStopGrabInfos() {
	for item in $@
	do
		case $item in
        $CMD_SPRD_HDR)
            #sprd hdr
			kill $sprd_hdr_version_pid
			kill $sprd_hdr_cap_time_pid
            ;;
		$CMD_SPRD_MFNR)
            #sprd mfnr
			kill $sprd_mfnr_version_pid
			kill $sprd_mfnr_version_begin_pid
			kill $sprd_mfnr_version_end_pid
            ;;
		$CMD_TRAN_FB)
            #tran fb
			kill $tran_fb_cap_begin_pid
			kill $tran_fb_cap_end_pid
            ;;
		$CMD_ST_PORTRAIT)
            #st portrait
			kill $st_portrait_cap_version_pid
			kill $st_portrait_cap_begin_pid
			kill $st_portrait_cap_end_pid
            ;;
		$CMD_ARC_FILTER)
            #arc filter
			kill $arc_filter_cap_begin_pid
			kill $arc_filter_cap_end_pid
            ;;
		$CMD_TRAN_WATERMARK)
            #tran_photo_wm
			kill $tran_photoWM_cap_begin_pid
			kill $tran_photoWM_cap_end_pid
            ;;
		esac
	done
}

#==============================================================================
# 分析拍照场景所有算法和功能的关键信息,并整理输出
#==============================================================================
captureInfosAnalysis() {
	for item in $@
	do
		case $item in
        $CMD_SPRD_HDR)
            #sprd hdr
			local version=$(sed -n "2p" ${SPRD_HDR_VERSION_INFO[2]} | awk -F '[' '{print $3}' | awk -F ' ' '{print $2}' | awk -F ']' '{print $1}')
			if [[ ${version} != "" ]]; then
				printResult "[HDR版本为: $version]"
			fi
			local time=$(sed -n "2p" ${SPRD_HDR_CAP_TIME_INFO[2]} | awk -F ':' '{print $3}')
			if [[ ${time} != "" && ${time} != 0 ]]; then
				printResult "[HDR拍照耗时为:$time]"
			fi
            ;;
		$CMD_SPRD_MFNR)
            #sprd mfnr
			version=$(sed -n "2p" ${SPRD_MFNR_VERSION_INFO[2]} | awk -F '[' '{print $2}' | awk -F ']' '{print $1}')
			if [[ ${version} != "" ]]; then
				printResult "[MFNR版本为:$version]"
			fi
			startTime=$(tail -n 1 ${SPRD_MFNR_CAP_BEGIN_INFO[2]} | awk '{print $1 " " $2}')
			endTime=$(tail -n 1 ${SPRD_MFNR_CAP_END_INFO[2]} | awk '{print $1 " " $2}')
			time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
			if [[ ${time} != "" && ${time} != 0 ]]; then
				printResult "[MFNR拍照耗时为: $time ms]"
			fi
            ;;
		$CMD_TRAN_FB)
            #tran fb
			startTime=$(tail -n 1 ${TRAN_FB_CAP_BEGIN_INFO[2]} | awk '{print $1 " " $2}')
			endTime=$(tail -n 1 ${TRAN_FB_CAP_END_INFO[2]} | awk '{print $1 " " $2}')
			time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
			if [[ ${time} != "" && ${time} != 0 ]]; then
				printResult "[美颜拍照耗时为: $time ms]"
			fi
            ;;
		$CMD_ST_PORTRAIT)
            #st portrait
			version=$(sed -n "2 {/version/p}" ${ST_PORTRAIT_CAP_VERSION_INFO[2]} | awk -F '=' '{print $2}')
			if [[ ${version} != "" ]]; then
				printResult "[虚化拍照版本为:$version]"
			fi
			startTime=$(tail -n 1 ${ST_PORTRAIT_CAP_BEGIN_INFO[2]} | awk '{print $1 " " $2}')
			endTime=$(tail -n 1 ${ST_PORTRAIT_CAP_END_INFO[2]} | awk '{print $1 " " $2}')
			time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
			if [[ ${time} != "" && ${time} != 0 ]]; then
				printResult "[虚化拍照耗时为: $time ms]"
			fi
            ;;
		$CMD_ARC_FILTER)
            #arc filter
			startTime=$(tail -n 1 ${ARC_FILTER_CAP_BEGIN_INFO[2]} | awk '{print $1 " " $2}')
			endTime=$(tail -n 1 ${ARC_FILTER_CAP_END_INFO[2]} | awk '{print $1 " " $2}')
			time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
			if [[ ${time} != "" && ${time} != 0 ]]; then
				printResult "[滤镜拍照耗时为: $time ms]"
			fi
            ;;
		$CMD_TRAN_WATERMARK)
            #tran_photo_wm
			startTime=$(tail -n 1 ${TRAN_PHOTO_WM_BEGIN_TIME[2]} | awk '{print $1 " " $2}')
			endTime=$(tail -n 1 ${TRAN_PHOTO_WM_END_TIME[2]} | awk '{print $1 " " $2}')
			time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
			if [[ ${time} != "" && ${time} != 0 ]]; then
				printResult "[水印拍照耗时为: $time ms]"
			fi
            ;;
		esac
	done
}

#==============================================================================
# 等待关键文件生成
#==============================================================================
waitUntilDone() {
	while ! [ -s $1 ]
	do
		continue
	done
}

#==============================================================================
# 展锐平台场景识别算法功能检查
#==============================================================================
sprdAISceneCheck() {
	previewStartGrabInfos $CMD_SPRD_AISCENE
	printNormalTip "请进入或返回键退出后重新进入相机"
	waitUntilDone ${SPRD_AISCENE_VERSION_INFO[2]}
	previewStopGrabInfos $CMD_SPRD_AISCENE
	previewInfosAnalysis $CMD_SPRD_AISCENE
	
	printNormalTip  "请确保AI功能开启"
	while true
	do
		previewStartGrabInfos $CMD_SPRD_AISCENE
		printNormalTip "场景检测中,请保持手机对准需要识别的场景"
		waitUntilDone ${SPRD_AISCENE_RESULT_INFO[2]}
		previewStopGrabInfos $CMD_SPRD_AISCENE
		previewInfosAnalysis $CMD_SPRD_AISCENE
		while true
		do
			printInteractTip "是否继续识别？[Y/N][直接回车默认Y] "
			read detect
			printDivideLine
			if [ -z $detect ] || [ ${detect,,} == "y" ] || [ ${detect,,} == "n" ]; then
				break
			else
				printNormalTip "请输入[Y/N]"
			fi
		done
		if [ -z $detect ] || [ ${detect,,} == "y" ]; then
			continue
		else
			printNormalTip "退出场景识别功能检查"
			break
		fi
	done
}

#==============================================================================
# 传音自研场景识别算法功能检查
#==============================================================================
tranAsdCheck() {
	previewStartGrabInfos $CMD_TRAN_ASD
	printNormalTip "请进入或返回键退出后重新进入相机"
	waitUntilDone ${TRAN_ASD_VERSION_INFO[2]}
	previewStopGrabInfos $CMD_TRAN_ASD
	previewInfosAnalysis $CMD_TRAN_ASD

	printNormalTip  "请确保AI功能开启"
	while true
	do
		previewStartGrabInfos $CMD_TRAN_ASD
		printNormalTip "场景检测中,请保持手机对准需要识别的场景"
		waitUntilDone ${TRAN_ASD_RESULT_INFO[2]}
		previewStopGrabInfos $CMD_TRAN_ASD
		previewInfosAnalysis $CMD_TRAN_ASD
		while true
		do
			printInteractTip "是否继续识别？[Y/N][直接回车默认Y] "
			read detect
			printDivideLine
			if [ -z $detect ] || [ ${detect,,} == "y" ] || [ ${detect,,} == "n" ]; then
				break
			else
				printNormalTip "请输入[Y/N]"
			fi
		done
		if [ -z $detect ] || [ ${detect,,} == "y" ]; then
			continue
		else
			printNormalTip "退出场景识别功能检查"
			break
		fi
	done
}

#==============================================================================
# 普通拍照模式下的场景识别算法的检查
#==============================================================================
sceneDetectCheck() {
	if [ ${asd_brand,,} == "sprd" ]; then
		printAlgoName "SPRD AiScene"
		sprdAISceneCheck
	elif [ ${asd_brand,,} == "tran" ]; then
		printAlgoName "TRAN ASD"
		tranAsdCheck
	else
		printErrorConfigMsgAndExit "普通拍照" "asd_brand" "sprd" "tran"
	fi
}

#==============================================================================
# 展锐平台HDR的场景拍照算法的检查
#==============================================================================
sprdHDRCheck() {
	captureStartGrabInfos $CMD_SPRD_HDR
	printNormalTip "$1"
	printNormalTip "在识别到HDR的场景下拍摄一张照片"
	waitUntilDone ${SPRD_HDR_VERSION_INFO[2]}
	waitUntilDone ${SPRD_HDR_CAP_TIME_INFO[2]}
	captureStopGrabInfos $CMD_SPRD_HDR
	captureInfosAnalysis $CMD_SPRD_HDR
}

#==============================================================================
# 三方虹软HDR的场景拍照算法的检查
#==============================================================================
arcHDRCheck() {
	echo "$1"
}

#==============================================================================
# HDR算法检查
#==============================================================================
hdrCheck() {
	printAlgoName "HDR"
	local tip=""
	if [ $1 == "photo" ]; then
		if [ ${brand,,} == "itel" ]; then
			tip="请确保开启快速功能栏中的AI开关"
		elif [ ${brand,,} == "tecno" ] || [ ${brand,,} == "infinix" ]; then
			tip="请确保开启快速功能栏中的HDR开关"
		fi
	fi
	
	if [ ${hdr_brand,,} == "sprd" ]; then
		sprdHDRCheck $tip
	elif [ ${hdr_brand,,} == "arc" ]; then
		arcHDRCheck $tip
	else
		printErrorConfigMsgAndExit "HDR" "HDR_ALGO" "sprd" "arc"
	fi
}

#==============================================================================
# 普通拍照模式下的HDR算法的检查
#==============================================================================
photoHDRcheck() {
	if [ ${photo_hdr,,} == "yes" ]; then
		hdrCheck "photo"
	elif [ ${photo_hdr,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "拍照模式HDR" "PHOTO_HDR" "yes" "no"
	fi
}

#==============================================================================
# MFNR算法检查
#==============================================================================
mfnrCheck() {
	printAlgoName "MFNR"
	captureStartGrabInfos $CMD_SPRD_MFNR
	printNormalTip "请关闭闪光灯，并在暗环境下拍摄一张照片"
	waitUntilDone ${SPRD_MFNR_VERSION_INFO[2]}
	waitUntilDone ${SPRD_MFNR_CAP_BEGIN_INFO[2]}
	waitUntilDone ${SPRD_MFNR_CAP_END_INFO[2]}
	captureStopGrabInfos $CMD_SPRD_MFNR
	captureInfosAnalysis $CMD_SPRD_MFNR
}

#==============================================================================
# 普通拍照模式下的暗光多帧降噪拍照算法的检查
#==============================================================================
photoLowLight() {
	if [ ${photo_lowlight,,} == "mfnr" ]; then
		mfnrCheck
	fi
}

#==============================================================================
# 获取并计算美颜算法执行时间
#==============================================================================
getTranFbTime() {
	printInteractTip "请将摄像头对准人脸后,再按回车键"
	read CMD
	printDivideLine
	
	previewStartGrabInfos $CMD_TRAN_FB
	waitUntilDone ${TRAN_FB_PREV_PERF_INFO[2]}
	previewStopGrabInfos $CMD_TRAN_FB
	previewInfosAnalysis $CMD_TRAN_FB
	
	captureStartGrabInfos $CMD_TRAN_FB
	printNormalTip "请将摄像头对准人脸后,点击拍照按钮"
	waitUntilDone ${TRAN_FB_CAP_BEGIN_INFO[2]}
	waitUntilDone ${TRAN_FB_CAP_END_INFO[2]}
	captureStopGrabInfos $CMD_TRAN_FB
	captureInfosAnalysis $CMD_TRAN_FB
}

#==============================================================================
# 美颜算法检查
#==============================================================================
tranFbCheck() {
	previewStartGrabInfos $CMD_TRAN_FB
	printNormalTip "$1"
	waitUntilDone ${TRAN_FB_VERSION_INFO[2]}
	waitUntilDone ${TRAN_FB_LEVELS_INFO[2]}
	waitUntilDone ${TRAN_FB_INDEX_INFO[2]}
	previewStopGrabInfos $CMD_TRAN_FB
	previewInfosAnalysis $CMD_TRAN_FB
	
	getTranFbTime
	while true
	do
		printInteractTip "是否继续检测美颜？[Y/N][直接回车默认Y] "
		read detect
		printDivideLine
		if [ -z $detect ] || [ ${detect,,} == "y" ]; then
			adb logcat -c
			local pid=$(grabOneInfoWithTime "${TRAN_FB_CUR_INDEX_INFO[@]}")
			printNormalTip "请切换美颜等级"
			waitUntilDone ${TRAN_FB_CUR_INDEX_INFO[2]}
			kill $pid
			currLev=$(sed -n "/set Degree To Devices/p" ${TRAN_FB_CUR_INDEX_INFO[2]} | awk -F '=' '{print $2}')
			if [ ! $currLev ]; then
				currLev=$(sed -n "2 {/mCurrentEntryValue/p}" ${TRAN_FB_CUR_INDEX_INFO[2]} | awk -F '=' '{print $2}')
			fi
			printResult "[美颜当前的等级为:$currLev]"
			deleteFile ${TRAN_FB_CUR_INDEX_INFO[2]}
			if [ $currLev == 0 ]; then
				printInteractTip "当前美颜为关闭状态，请开启美颜后按下回车"
				read CMD
				printDivideLine
				continue
			fi
			getTranFbTime
		elif [ ${detect,,} == "n" ]; then
			break
		else
			printNormalTip "请输入[Y/N]"
		fi
	done
}

#==============================================================================
# 普通拍照模式下的美颜拍照算法功能检查
#==============================================================================
photoFaceBeauty() {
	if [ ${photo_fb,,} == "yes" ]; then
		printAlgoName "FaceBeauty"
		if [ ${fb_brand,,} == "tran" ]; then
			tranFbCheck "请打开美颜开关,并重新进入相机"
		else
			printErrorConfigMsgAndExit "美颜拍照" "FB_ALGO" "tran" "NULL"
		fi
	elif [ ${photo_fb,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "美颜拍照" "PHOTO_FB" "yes" "no"
	fi
}

#==============================================================================
# 滤镜算法检查
#==============================================================================
arcFilterCheck() {
	captureStartGrabInfos $CMD_ARC_FILTER
	printNormalTip "请开启滤镜后进行拍照"
	waitUntilDone ${ARC_FILTER_CAP_BEGIN_INFO[2]}
	waitUntilDone ${ARC_FILTER_CAP_END_INFO[2]}
	captureStopGrabInfos $CMD_ARC_FILTER
	captureInfosAnalysis $CMD_ARC_FILTER
}

#==============================================================================
# 任意模式下的滤镜算法功能检查
#==============================================================================
filterCheck() {
	if [ ${filter,,} == "yes" ]; then
		printAlgoName "Filter"
		if [ ${filter_brand,,} == "arc" ]; then
			arcFilterCheck
		else
			printErrorConfigMsgAndExit "滤镜拍照" "FILTER_ALGO" "arc" "NULL"
		fi
	elif [ ${filter,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "滤镜拍照" "FILTER" "yes" "no"
	fi
}

#==============================================================================
# 普通拍照模式下的算法功能检查
#==============================================================================
photoModeCheck() {
	printModeName "PhotoMode"
	sceneDetectCheck 	#自动场景检测算法检查
	photoHDRcheck		#HDR算法检查
	photoLowLight		#普通拍照模式暗光降噪算法
	photoFaceBeauty		#普通拍照模式美颜拍照算法
	filterCheck			#滤镜拍照算法检查
}

#==============================================================================
# 美颜拍照模式下的算法功能检查
#==============================================================================
fbModeCheck() {
	if [ ${fb_mode,,} == "yes" ]; then
		printModeName "FaceBeauty"
		if [ ${fb_brand,,} == "tran" ]; then
			tranFbCheck "请进入或重新进入美颜模式"
		else
			printErrorConfigMsgAndExit "美颜拍照" "FB_ALGO" "tran" "arc"
		fi
	elif [ ${fb_mode,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "美颜拍照" "FB_MODE" "yes" "no"
	fi
}

#==============================================================================
# 人像拍照模式下的算法功能检查
#==============================================================================
portraitModeCheck() {
	if [ ${portrait_mode,,} == "yes" ]; then
		printModeName "Portrait"
		if [ ${blur_brand,,} == "st" ]; then
			stPortraitCheck
		else
			printErrorConfigMsgAndExit "人像拍照" "BLUR_ALGO" "st" "NULL"
		fi
	elif [ ${portrait_mode,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "人像拍照" "PORTRAIT_MODE" "yes" "no"
	fi
}

#==============================================================================
# 夜景拍照模式下的算法功能检查
#==============================================================================
nightModeCheck() {
	if [ ${nightscene_mode,,} == "yes" ]; then
		printModeName "Night"
		if [ ${nightscene_mode_algo,,} == "mfnr" ]; then
			printNormalTip "请切换至夜景模式"
			mfnrCheck
		else
			printErrorConfigMsgAndExit "夜景拍照" "NIGHTSCENE_ALGO" "mfnr" "N/A"
		fi
	elif [ ${nightscene_mode,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "夜景拍照" "NIGHTSCENE_MODE" "yes" "no"
	fi
}

#==============================================================================
# HDR拍照模式下的算法功能检查
#==============================================================================
hdrModeCheck() {
	if [ ${hdr_mode,,} == "yes" ]; then
		printModeName "HDR"
		if [ ${hdr_brand,,} == "sprd" ]; then
			sprdHDRCheck "请切换至HDR模式"
		else
			printErrorConfigMsgAndExit "HDR拍照" "HDR_ALGO" "sprd" "NULL"
		fi
	elif [ ${hdr_mode,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "HDR拍照" "HDR_MODE" "yes" "no"
	fi
}

#==============================================================================
# 任意模式下的水印拍照算法功能检查
#==============================================================================
watermarkPhotoAlgoCheck() {
	if [ ${photo_wm,,} == "yes" ]; then
		printAlgoName "PHOTO_WATERMARK"
		if [ ${photo_wm_brand,,} == "tran" ]; then
			tranPhotoWMCheck
		else
			printErrorConfigMsgAndExit "水印拍照" "PHOTO_WM_ALGO" "tran" "NULL"
		fi
	elif [ ${photo_wm,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "水印拍照" "PHOTO_WM" "yes" "no"
	fi
}

#==============================================================================
# 任意模式下的水印录像算法功能检查
#==============================================================================
watermarkVideoAlgoCheck() {
	if [ ${video_wm,,} == "yes" ]; then
		printAlgoName "VIDEO_WATERMARK"
		if [ ${video_wm_brand,,} == "tran" ]; then
			tranVideoWMCheck
		else
			printErrorConfigMsgAndExit "水印录像" "PHOTO_WM_ALGO" "tran"
		fi
	elif [ ${video_wm,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "水印录像" "VIDEO_WM" "yes" "no"
	fi
}

#==============================================================================
# 特定模式下的连拍功能检查
#==============================================================================
continuousPhotoCheck() {
	if [ ${continuous_cap,,} == "yes" ]; then
		printAlgoName "ContinuousCap"
		continuousCapCheck
	elif [ ${continuous_cap,,} == "no" ]; then
		sleep $TIME_WAIT_NORMAL
	else
		printErrorConfigMsgAndExit "连拍" "CONTINUOUS_CAP" "yes" "no"
	fi
}

#==============================================================================
# 虚化算法检查
#==============================================================================
stPortraitCheck() {
	previewStartGrabInfos $CMD_ST_PORTRAIT
	printNormalTip "请重新进入人像模式"
	waitUntilDone ${ST_PORTRAIT_PREV_VERSION_INFO[2]}
	previewStopGrabInfos $CMD_ST_PORTRAIT
	previewInfosAnalysis $CMD_ST_PORTRAIT
	
	captureStartGrabInfos $CMD_ST_PORTRAIT
	printNormalTip "请识别到人脸后进行拍照"
	waitUntilDone ${ST_PORTRAIT_CAP_VERSION_INFO[2]}
	waitUntilDone ${ST_PORTRAIT_CAP_BEGIN_INFO[2]}
	waitUntilDone ${ST_PORTRAIT_CAP_END_INFO[2]}
	captureStopGrabInfos $CMD_ST_PORTRAIT
	captureInfosAnalysis $CMD_ST_PORTRAIT
}

#==============================================================================
# 水印拍照算法检查
#==============================================================================
tranPhotoWMCheck() {
	#TODO（版本号）
	captureStartGrabInfos $CMD_TRAN_WATERMARK
	printNormalTip "请开启水印后进行拍照"
	waitUntilDone ${TRAN_PHOTO_WM_BEGIN_TIME[2]}
	waitUntilDone ${TRAN_PHOTO_WM_END_TIME[2]}
	captureStopGrabInfos $CMD_TRAN_WATERMARK
	captureInfosAnalysis $CMD_TRAN_WATERMARK
}

#==============================================================================
# 水印录像算法检查
#==============================================================================
tranVideoWMCheck() {
	echo ""
	printDivideLine
	#TODO（版本，时间）
}

#==============================================================================
# 连拍异常检查
#==============================================================================
continuousCapCheck() {
	printInteractTip "请确保关闭[AI]、[美颜]、[滤镜]、[闪光灯]等不支持与连拍同时开启的设置项后回车确认"
	read CMD
	printDivideLine
	captureStartGrabInfos $CMD_TRAN_FB $CMD_ST_PORTRAIT $CMD_SPRD_MFNR
	printNormalTip "请进行连拍"
	printInteractTip "请在完成连拍后回车确认"
	read CMD
	printDivideLine
	captureStopGrabInfos $CMD_TRAN_FB $CMD_ST_PORTRAIT $CMD_SPRD_MFNR
	captureInfosAnalysis $CMD_TRAN_FB $CMD_ST_PORTRAIT $CMD_SPRD_MFNR
	if ! [ -s ${TRAN_FB_CAP_BEGIN_INFO[2]} ]
	then
		printResult "[连拍时未执行美颜算法]"
	else
		printErrorResult "ERROR：连拍时可能执行了美颜算法"
	fi
	if ! [ -s ${ST_PORTRAIT_CAP_BEGIN_INFO[2]} ]
	then
		printResult "[连拍时未执行虚化算法]"
	else
		printErrorResult "ERROR：连拍时可能执行了虚化算法"
	fi
	if ! [ -s ${SPRD_MFNR_CAP_BEGIN_INFO[2]} ]
	then
		printResult "[连拍时未执行MFNR算法]"
	else
		printErrorResult "ERROR：连拍时可能执行了MFNR算法"
	fi
}

#==============================================================================
# 算法检查入口函数
#==============================================================================
camCheck() {
	photoModeCheck 				#拍照模式检查
	fbModeCheck 				#美颜模式检查
	portraitModeCheck			#人像模式检查
	nightModeCheck				#夜景模式检查
	hdrModeCheck				#HDR模式检查
	
	watermarkPhotoAlgoCheck		#水印拍照算法检查
	#watermarkVideoAlgoCheck		#水印录像算法检查
	
	continuousPhotoCheck		#连拍功能检查
}

#==============================================================================
# 检查结束后询问用户是否删除中间文件
#==============================================================================
interactDeleteFiles() {
	while true
	do
		printInteractTip "是否需要删除所有中间文件？[Y/N][直接回车默认Y] "
		read delete
		printDivideLine
		if [ -z $delete ] || [ ${delete,,} == "y" ]; then
			printNormalTip "删除中......"
			deleteFile ${SPRD_AISCENE_VERSION_INFO[2]}
			deleteFile ${SPRD_AISCENE_RESULT_INFO[2]}
			deleteFile ${TRAN_ASD_VERSION_INFO[2]}
			deleteFile ${TRAN_ASD_RESULT_INFO[2]}
			deleteFile ${SPRD_HDR_VERSION_INFO[2]}
			deleteFile ${SPRD_HDR_CAP_TIME_INFO[2]}
			deleteFile ${SPRD_MFNR_VERSION_INFO[2]}
			deleteFile ${SPRD_MFNR_CAP_BEGIN_INFO[2]}
			deleteFile ${SPRD_MFNR_CAP_END_INFO[2]}
			deleteFile ${TRAN_FB_VERSION_INFO[2]}
			deleteFile ${TRAN_FB_LEVELS_INFO[2]}
			deleteFile ${TRAN_FB_INDEX_INFO[2]}
			deleteFile ${TRAN_FB_PREV_PERF_INFO[2]}
			deleteFile ${TRAN_FB_CAP_BEGIN_INFO[2]}
			deleteFile ${TRAN_FB_CAP_END_INFO[2]}
			deleteFile ${TRAN_FB_CUR_INDEX_INFO[2]}
			deleteFile ${ST_PORTRAIT_PREV_VERSION_INFO[2]}
			deleteFile ${ST_PORTRAIT_CAP_VERSION_INFO[2]}
			deleteFile ${ST_PORTRAIT_CAP_BEGIN_INFO[2]}
			deleteFile ${ST_PORTRAIT_CAP_END_INFO[2]}
			deleteFile ${ARC_FILTER_CAP_BEGIN_INFO[2]}
			deleteFile ${ARC_FILTER_CAP_END_INFO[2]}
			deleteFile ${TRAN_PHOTO_WM_BEGIN_TIME[2]}
			deleteFile ${TRAN_PHOTO_WM_END_TIME[2]}
			printNormalTip "删除完成"
			break
		elif [ ${delete,,} == "n" ]; then
			printNormalTip "中间文件未删除"
			break
		else
			printNormalTip "请输入[Y/N]"
		fi
	done
}

main() {
	hint 						#脚本功能展示提示语部分
	getProductList 				#加载同级目录下的配置文件
	chooseProduct				#提示用户选择需要检查的项目
	camCheck					#算法检查入口
	interactDeleteFiles			#检查结束询问用户是否删除中间文件
}

main
