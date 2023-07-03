configPath=./config.txt

hint() {
	echo " --------------------------------------------------------------- "
	echo "| Preconditions: 请在执行该脚本前确认并修改配置文件的信息，     |"
	echo "|                并将配置文件与该脚本放置在同一路径下。         |"
	echo " --------------------------------------------------------------- "
	echo "| Tips: 该脚本为半自动化测试，请根据提示信息寻找场景配合测试。  |"
	echo " --------------------------------------------------------------- "
}

getProductList() {
	productList=($(grep "PRODUCT=" $configPath | awk -F '=' '{print $2}'))
}

getRegion() {
    local productName=$1
    cat -n $configPath | grep "PRODUCT=" | grep -A 1 "PRODUCT=$productName" | awk '{print $1}' | xargs
}

getConfig() {
    local productName=$1

    local region=$(getRegion $productName)
    local startLine=$(echo $region | awk '{print $1}')
    local endLine=$(echo $region | awk '{print $2}')
	if [ ! $endLine ]
	then
		endLine=$(cat -n $configPath | tail -n 1 | awk '{print $1}')
	else
		endLine=$(($endLine-1))
	fi
	product=$(sed -n "${startLine}, ${endLine} {/PRODUCT=.*/p}" $configPath | awk -F '=' '{print $2}')
	android_version=$(sed -n "${startLine}, ${endLine} {/ANDROID_VERSION=.*/p}" $configPath | awk -F '=' '{print $2}')
	brand=$(sed -n "${startLine}, ${endLine} {/BRAND=.*/p}" $configPath | awk -F '=' '{print $2}')
	photo_asd=$(sed -n "${startLine}, ${endLine} {/PHOTO_ASD=.*/p}" $configPath | awk -F '=' '{print $2}')
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
}

chooseProduct() {
	local num=0
	for item in ${productList[*]}
	do
		num=$(($num+1))
		echo "$num: $item"
	done
	echo -n "请选择项目名（若选项中无所需项目，请在配置文件中按要求添加）: "
	read num
	echo "读取配置文件中，请稍后。。。"
	getConfig ${productList[$(($num-1))]}
}

sprdAISceneCheck() {
	adb logcat -c
	adb logcat -v brief -b main AIC:I *:S --regex "CAM_ALGO_CV_SD_LIBVER" > logcat_ai_asd.txt &
	local pid=$!
	echo "   请进入或返回键退出后重新进入相机"
	while ! [ -s logcat_ai_asd.txt ]
	do
		continue
	done
	kill $pid
	local version=$(sed -n "/CAM_ALGO_CV_SD_LIBVER/p" logcat_ai_asd.txt | awk -F '[' '{print $3}' | awk -F ']' '{print $1}')
	echo -e "   [ASD版本为：$version]\n"
	rm logcat_ai_asd.txt
	sleep 1
	
	echo "   请确保开启快速功能栏中的AI"
	echo "   [0:Default][1:Food][2:Portrait][3:Plant][5:NightScene][7:Text][15:Flower]"
	sleep 1
	while true
	do
		adb logcat -c
		adb logcat -v brief -b main Cam3OEMIf:D *:S --regex "sprd_ai_scene_type_current" > logcat_ai_asd.txt &
		pid=$!
		echo "   ...场景检测中，请保持手机对准需要识别的场景..."
		while ! [ -s logcat_ai_asd.txt ]
		do
			continue
		done
		kill $pid
		local type=$(sed -n "/sprd_ai_scene_type_current/p" logcat_ai_asd.txt | awk -F ':' '{print $4}')
		echo -e "   [ASD识别到的场景为：$type]\n"
		rm logcat_ai_asd.txt
		while true
		do
			echo -n "   是否继续识别？（Y,y/N,n）"
			read detect
			if [[ ${detect,,} == "y" || ${detect,,} == "n" ]]
			then
				break
			else
				echo "   请输入 'Y/y' or 'N/n'"
			fi
		done
		if [ ${detect,,} == "n" ]
		then
			echo ""
			break
		else
			continue
		fi
	done
}

tranAsdCheck() {
	adb logcat -c
	adb logcat -v brief -b main TranCam-ASD:I *:S --regex "Version" > logcat_ai_asd.txt &
	local pid=$!
	echo "   请进入或返回键退出后重新进入相机"
	while ! [ -s logcat_ai_asd.txt ]
	do
		continue
	done
	kill $pid
	local version=$(sed -n "2 {/Version/p}" logcat_ai_asd.txt | awk -F ':' '{print $3}')
	echo -e "   [ASD版本为：$version]\n"
	rm logcat_ai_asd.txt
	sleep 1
	#TODO（current scene）
}

AICamAsdCheck() {
	echo " • AI_ASD"
	sleep 1
	if [ ${asd_brand,,} == "sprd" ]
	then
		sprdAISceneCheck
	elif [ ${asd_brand,,} == "tran" ]
	then
		tranAsdCheck
	else
		echo "   请检查配置文件中所选项目的ASD_ALGO值，目前只支持sprd或tran，可不区分大小写"
		echo "   [AI CAM模式下的ASD未成功检测，请稍后重试]"
	fi
}

sprdHdrCheck() {
	adb logcat -c
	if [ ${android_version^^} == "T" ]
	then
		adb logcat -v brief -b main HDRNode:D *:S --regex "HDR lib version" > logcat_ai_hdr_version.txt &
		local pid1=$!
		adb logcat -v time -b main HDRNode:D *:S --regex "tuning param size" > logcat_ai_hdr_begin_time.txt &
		local pid2=$!
		adb logcat -v time -b main HDRNode:D *:S --regex "--LWP D-- X, ret =" > logcat_ai_hdr_end_time.txt &
		local pid3=$!
	elif [ ${android_version^^} == "S" ]
	then
		adb logcat -v brief -b main sprdhdr2:I *:S --regex "CAM_ALGO_CV_HDR2_LIBVER" > logcat_ai_hdr_version.txt &
		local pid1=$!
		adb logcat -v brief -b main sprdhdr2:I *:S --regex "CAM_ALGO_CV_HDR2_LIBVER" > logcat_ai_hdr_begin_time.txt &
		local pid2=$!
		adb logcat -v brief -b main sprdhdr2:I *:S --regex "CAM_ALGO_CV_HDR2_LIBVER" > logcat_ai_hdr_end_time.txt &
		local pid3=$!
	else
		echo "   请检查配置文件中所选项目的ANDROID_VERSION值，目前只支持T或S，可不区分大小写"
		echo "   [HDR未成功检测，请稍后重试]"
		return
	fi
	sleep 1
	echo "   $1"
	echo "   在识别到HDR的场景下拍摄一张照片"
	while ! [ -s logcat_ai_hdr_version.txt ]
	do
		continue
	done
	kill $pid1
	while ! [ -s logcat_ai_hdr_begin_time.txt ]
	do
		continue
	done
	kill $pid2
	while ! [ -s logcat_ai_hdr_end_time.txt ]
	do
		continue
	done
	kill $pid3
	if [ ${android_version^^} == "T" ]
	then
		local version=$(sed -n "/HDR lib version/p" logcat_ai_hdr_version.txt | awk -F ':' '{print $4}' | awk -F ',' '{print $1}')
		echo "   [HDR版本为：$version]"
		echo "   HDR拍照时间："
		echo -n "   "
		sed -n "2p" logcat_ai_hdr_begin_time.txt
		echo -n "   "
		sed -n "2p" logcat_ai_hdr_end_time.txt
		local startTime=$(sed -n "2p" logcat_ai_hdr_begin_time.txt | awk '{print $1 " " $2}')
		local endTime=$(sed -n "2p" logcat_ai_hdr_end_time.txt | awk '{print $1 " " $2}')
		local time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
		echo "   时间差：$time ms"
	elif [ ${android_version^^} == "S" ]
	then
		local version=$(sed -n "/CAM_ALGO_CV_HDR2_LIBVER/p" logcat_ai_hdr_version.txt | awk -F '[' '{print $2}' | awk -F ']' '{print $1}')
		echo "   [HDR版本为：$version]"
		#TODO（执行时间）
	else
		echo "   请检查配置文件中所选项目的ANDROID_VERSION值，目前只支持T或S，可不区分大小写"
		echo "   [HDR未成功检测，请稍后重试]"
		return
	fi
	echo ""
	rm logcat_ai_hdr_version.txt
	rm logcat_ai_hdr_begin_time.txt
	rm logcat_ai_hdr_end_time.txt
	sleep 1
}

AICamHdrCheck() {
	echo " • AI_HDR"
	if [ ${hdr_brand,,} == "sprd" ]
	then
		if [ ${brand,,} == "itel" ]
		then
			sprdHdrCheck "请确保开启快速功能栏中的AI开关"
		elif [[ ${brand,,} == "tecno" || ${brand,,} == "infinix" ]]
		then
			sprdHdrCheck "请确保开启快速功能栏中的HDR开关"
		fi
	else
		echo "   请检查配置文件中所选项目的HDR_ALGO值，目前只支持sprd，可不区分大小写"
		echo "   [HDR未成功检测，请稍后重试]"
	fi
}

mfnrCheck() {
	adb logcat -c
	adb logcat -v brief -b main TDNS_LOG:D *:S --regex "CAM_ALGO_CV_MFNR_LIBVER" > logcat_ai_mfnr.txt &
	local pid=$!
	sleep 1
	echo "   请关闭闪光灯，并使用后摄在暗环境下拍摄一张照片"
	while ! [ -s logcat_ai_mfnr.txt ]
	do
		continue
	done
	kill $pid
	local version=$(sed -n "/CAM_ALGO_CV_MFNR_LIBVER/p" logcat_ai_mfnr.txt | awk -F '[' '{print $2}' | awk -F ']' '{print $1}')
	echo -e "   [MFNR版本为：$version]\n"
	rm logcat_ai_mfnr.txt
	sleep 1
}

AICamMfnrCheck() {
	echo " • AI_MFNR"
	mfnrCheck
}

getFbTime() {
	read -p "   请将摄像头对准人脸后回车"
	if [ ${fb_brand,,} ==  "tran" ]
	then
		local TAG="TranCam-FaceBeauty"
	elif [ ${fb_brand,,} == "arc" ]
	then
		local TAG="TranCam-ArcFaceBeauty"
	else
		echo "   请检查配置文件中所选项目的FB_ALGO值，目前只支持tran或arc，可不区分大小写"
		echo "   [FaceBeauty时间未成功检测，请稍后重试]"
		return
	fi
	adb logcat -c
	adb logcat -v time -b main $TAG:D *:S --regex "\[processPreview\]E|\[processPreview\]X ret=0" > logcat_fb_prev_time.txt &
	local pid1=$!
	while ! [ -s logcat_fb_prev_time.txt ]
	do
		continue
	done
	kill $pid1
	echo "   预览美颜时间："
	if [ `tail -n 1 logcat_fb_prev_time.txt | grep -c "X ret=0"` -eq 0 ]
	then
		echo -n "   "
		tail -n 3 logcat_fb_prev_time.txt | head -n 1
		echo -n "   "
		tail -n 2 logcat_fb_prev_time.txt | head -n 1
		local startTime=$(tail -n 3 logcat_fb_prev_time.txt | head -n 1 | awk '{print $1 " " $2}')
		local endTime=$(tail -n 2 logcat_fb_prev_time.txt | head -n 1 | awk '{print $1 " " $2}')
	else
		echo -n "   "
		tail -n 2 logcat_fb_prev_time.txt | head -n 1
		echo -n "   "
		tail -n 1 logcat_fb_prev_time.txt
		local startTime=$(tail -n 2 logcat_fb_prev_time.txt | head -n 1 | awk '{print $1 " " $2}')
		local endTime=$(tail -n 1 logcat_fb_prev_time.txt | awk '{print $1 " " $2}')
	fi
	local time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
	echo "   时间差：$time ms"
	rm logcat_fb_prev_time.txt
	echo ""
	adb logcat -c
	adb logcat -v time -b main $TAG:D *:S --regex "\[processRaw\]E" > logcat_fb_cap_begin_time.txt &
	local pid2=$!
	adb logcat -v time -b main $TAG:D *:S --regex "\[processRaw\]X ret=0" > logcat_fb_cap_end_time.txt &
	local pid3=$!
	echo "   请在识别到人脸后进行拍照"
	while ! [ -s logcat_fb_cap_begin_time.txt ]
	do
		continue
	done
	kill $pid2
	while ! [ -s logcat_fb_cap_end_time.txt ]
	do
		continue
	done
	kill $pid3
	echo "   拍照美颜时间："
	echo -n "   "
	sed -n "2p" logcat_fb_cap_begin_time.txt
	echo -n "   "
	sed -n "2p" logcat_fb_cap_end_time.txt
	startTime=$(sed -n "2p" logcat_fb_cap_begin_time.txt | awk '{print $1 " " $2}')
	endTime=$(sed -n "2p" logcat_fb_cap_end_time.txt | awk '{print $1 " " $2}')
	time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
	echo "   时间差：$time ms"
	rm logcat_fb_cap_begin_time.txt
	rm logcat_fb_cap_end_time.txt
	echo ""
	sleep 1
}

tranFbCheck() {
	adb logcat -c
	adb logcat -v brief -b main TranCam-FaceBeauty:I *:S --regex "tran FB version" > logcat_fb_version.txt &
	local pid1=$!
	adb logcat -c
	adb logcat -v brief -b main CamAp_ItelFaceBeautySet:I *:S --regex "supportList" > logcat_fb_level_list.txt &
	local pid2=$!
	adb logcat -c
	adb logcat -v brief -b main CamAp_ItelFaceBeautySet:I *:S --regex "mCurrentEntryValue" > logcat_fb_current_level.txt &
	local pid3=$!
	echo "   $1"
	while ! [ -s logcat_fb_current_level.txt ]
	do
		continue
	done
	kill $pid3
	local currLev=$(sed -n "/mCurrentEntryValue/p" logcat_fb_current_level.txt | awk -F '=' '{print $2}' | awk -F ',' '{print $1}')
	echo "   [FB当前的等级为:$currLev]"
	rm logcat_fb_current_level.txt
	if [ $currLev == 0 ]
	then
		read -p "   当前美颜为关闭状态，请开启美颜后按下回车"
	fi
	while ! [ -s logcat_fb_version.txt ]
	do
		continue
	done
	kill $pid1
	local version=$(sed -n "/tran FB version/p" logcat_fb_version.txt | awk -F ':' '{print $3}')
	echo "   [FB版本为：$version]"
	rm logcat_fb_version.txt
	while ! [ -s logcat_fb_level_list.txt ]
	do
		continue
	done
	kill $pid2
	local levelList=$(sed -n "/supportList/p" logcat_fb_level_list.txt | awk -F ':' '{print $3}')
	echo "   [配置文件中配置的该项目FB支持的最高等级为：$fb_level]"
	echo -e "   [FB实际支持的等级有：$levelList]\n"
	rm logcat_fb_level_list.txt
	getFbTime
	while true
	do
		echo -n "   是否继续检测美颜？（Y,y/N,n）"
		read detect
		if [ ${detect,,} == "y" ]
		then
			adb logcat -c
			adb logcat -v brief -b main CamAp_ItelFaceBeautySet:D *:S --regex "set Degree To Devices|mCurrentEntryValue" > logcat_fb_current_level.txt &
			local pid=$!
			echo "   请切换美颜等级"
			while ! [ -s logcat_fb_current_level.txt ]
			do
				continue
			done
			kill $pid
			currLev=$(sed -n "/set Degree To Devices/p" logcat_fb_current_level.txt | awk -F '=' '{print $2}')
			if [ ! $currLev ]
			then
				currLev=$(sed -n "/mCurrentEntryValue/p" logcat_fb_current_level.txt | awk -F '=' '{print $2}')
			fi
			echo -e "   [FB当前的等级为:$currLev]\n"
			rm logcat_fb_current_level.txt
			if [ $currLev == 0 ]
			then
				read -p "   当前美颜为关闭状态，请开启美颜后按下回车"
			fi
			getFbTime
		elif [ ${detect,,} == "n" ]
		then
			echo ""
			break
		else
			echo "   请输入 'Y/y' or 'N/n'"
		fi
	done
}

arcFbCheck() {
	adb logcat -c
	adb logcat -v brief -b main TranCam-ArcFaceBeauty:I *:S --regex "version" > logcat_fb_version.txt &
	local pid1=$!
	adb logcat -c
	adb logcat -v brief -b main CamAp_FaceBeautyRoot:I *:S --regex "mCurrValue" > logcat_fb_current_level.txt &
	local pid2=$!
	echo "   $1"
	while ! [ -s logcat_fb_version.txt ]
	do
		continue
	done
	kill $pid1
	local version=$(sed -n "2 {/version/p}" logcat_fb_version.txt | awk -F ':' '{print $3}' | awk '{print $1}')
	echo "   [FB版本为：$version]"
	rm logcat_fb_version.txt
	#TODO（支持的等级列表）
	while ! [ -s logcat_fb_current_level.txt ]
	do
		continue
	done
	kill $pid2
	local currLev=$(sed -n "/mCurrValue/p" logcat_fb_current_level.txt | awk -F '=' '{print $2}')
	echo -e "   [FB当前的等级为:$currLev]\n"
	rm logcat_fb_current_level.txt
	getFbTime
	sleep 1
	while true
	do
		echo -n "   是否继续检测美颜？（Y,y/N,n）"
		read detect
		if [ ${detect,,} == "y" ]
		then
			adb logcat -c
			adb logcat -v brief -b main CamAp_FaceBeauty:I *:S --regex "onValueChanged" > logcat_fb_current_level.txt &
			local pid=$!
			echo "   请切换美颜等级"
			while ! [ -s logcat_fb_current_level.txt ]
			do
				continue
			done
			kill $pid
			currLev=$(sed -n "/onValueChanged/p" logcat_fb_current_level.txt | awk -F ':' '{print $3}')
			echo -e "   [FB当前的等级为:$currLev]\n"
			rm logcat_fb_current_level.txt
			getFbTime
		elif [ ${detect,,} == "n" ]
		then
			echo ""
			break
		else
			echo "   请输入 'Y/y' or 'N/n'"
		fi
	done
}

AICamFbCheck() {
	echo " • AI_FaceBeauty"
	if [ ${fb_brand,,} == "tran" ]
	then
		tranFbCheck "请重新进入相机"
	elif [ ${fb_brand,,} == "arc" ]
	then
		arcFbCheck "请重新进入相机"
	else
		echo "   请检查配置文件中所选项目的FB_ALGO值，目前只支持tran或arc，可不区分大小写"
		echo "   [AI CAM模式下的FaceBeauty未成功检测，请稍后重试]"
	fi
}

AICamCheck() {
	echo "◆ AI CAM"
	sleep 1
	if [ ${photo_asd,,} == "yes" ]
	then
		AICamAsdCheck
	elif [ ${photo_asd,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的PHOTO_ASD值，只能为yes或no，可不区分大小写"
		echo "   [AI CAM模式下的ASD未成功检测，请稍后重试]"
	fi
	if [ ${photo_hdr,,} == "yes" ]
	then
		AICamHdrCheck
	elif [ ${photo_hdr,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的PHOTO_HDR值，只能为yes或no，可不区分大小写"
		echo "   [AI CAM模式下的HDR未成功检测，请稍后重试]"
	fi
	if [ ${photo_lowlight,,} == "mfnr" ]
	then
		AICamMfnrCheck
	elif [ ${photo_lowlight,,} == "3dnr" ]
	then
		#TODO
		#AICam3dnrCheck
		sleep 1
	elif  [ ${photo_lowlight,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的PHOTO_MFNR值，只能为mfnr、3dnr或no，可不区分大小写"
		echo "   [AI CAM模式下的MFNR未成功检测，请稍后重试]"
	fi
	if [ ${photo_fb,,} == "yes" ]
	then
		AICamFbCheck
	elif [ ${photo_fb,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的PHOTO_FB值，只能为yes或no，可不区分大小写"
		echo "   [AI CAM模式下的FaceBeauty未成功检测，请稍后重试]"
	fi
}

stPortraitCheck() {
	adb logcat -c
	adb logcat -v brief -b main singlecam_blur_preview:I *:S --regex "version" > logcat_portrait_prev_version.txt &
	local pid1=$!
	adb logcat -c
	adb logcat -v brief -b main singlecam_blur_capture:I *:S --regex "version" > logcat_portrait_cap_version.txt &
	local pid2=$!
	sleep 1
	if [ ${product^^} == "A665L" ]
	then
		echo "  请进入或重新进入人像模式"
	elif [[ ${product^^} == "BF6" || ${product^^} == "X6516" ]]
	then
		echo "  请进入或重新进入人像模式后摄"
	else
		echo "   请检查配置文件中所选项目的PRODUCT值，目前只支持A665L、BF6或X6516，可不区分大小写"
		echo "   [Portrait模式未成功检测，请稍后重试]"
	fi
	while ! [ -s logcat_portrait_prev_version.txt ]
	do
		continue
	done
	kill $pid1
	local version=$(sed -n "/version/p" logcat_portrait_prev_version.txt | awk -F '=' '{print $2}')
	echo "  [Portrait预览虚化版本为：$version]"
	rm logcat_portrait_prev_version.txt
	if [ ${product^^} == "A665L" ]
	then
		echo ""
		echo "  请识别到人脸后进行拍照"
	fi
	while ! [ -s logcat_portrait_cap_version.txt ]
	do
		continue
	done
	kill $pid2
	version=$(sed -n "2 {/version/p}" logcat_portrait_cap_version.txt | awk -F '=' '{print $2}')
	echo -e "  [Portrait拍照虚化版本为：$version]\n"
	rm logcat_portrait_cap_version.txt
	#TODO（执行时间）
	sleep 1
}

nightSceneMfnrCheck() {
	echo "   请切换至夜景模式下"
	sleep 1
	mfnrCheck
}

arcFilterCheck() {
	adb logcat -c
	adb logcat -v time -b main TranCam-ArcFilter:I *:S --regex "\[processRaw\]\+" > logcat_filter_cap_begin_time.txt &
	local pid1=$!
	adb logcat -v time -b main TranCam-ArcFilter:I *:S --regex "\[processRaw\]\-" > logcat_filter_cap_end_time.txt &
	local pid2=$!
	echo "   请开启滤镜后进行拍照"
	while ! [ -s logcat_filter_cap_begin_time.txt ]
	do
		continue
	done
	kill $pid1
	while ! [ -s logcat_filter_cap_end_time.txt ]
	do
		continue
	done
	kill $pid2
	echo "   滤镜拍照时间："
	echo -n "   "
	sed -n "2p" logcat_filter_cap_begin_time.txt
	echo -n "   "
	sed -n "2p" logcat_filter_cap_end_time.txt
	local startTime=$(sed -n "2p" logcat_filter_cap_begin_time.txt | awk '{print $1 " " $2}')
	local endTime=$(sed -n "2p" logcat_filter_cap_end_time.txt | awk '{print $1 " " $2}')
	local time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
	echo "   时间差：$time ms"
	rm logcat_filter_cap_begin_time.txt
	rm logcat_filter_cap_end_time.txt
	echo ""
	sleep 1
}

tranPhotoWMCheck() {
	adb logcat -c
	adb logcat -v time -b main TranCam-WaterMark:I *:S --regex "\[processRaw\]\+|\[processRaw\]E" > logcat_photo_wm_cap_begin_time.txt &
	local pid1=$!
	adb logcat -v time -b main TranCam-WaterMark:I *:S --regex "\[processRaw\]\-|\[processRaw\]X" > logcat_photo_wm_cap_end_time.txt &
	local pid2=$!
	#TODO（版本号）
	echo "   请开启水印后进行拍照"
	while ! [ -s logcat_photo_wm_cap_begin_time.txt ]
	do
		continue
	done
	kill $pid1
	while ! [ -s logcat_photo_wm_cap_end_time.txt ]
	do
		continue
	done
	kill $pid2
	echo "   水印拍照时间："
	echo -n "   "
	sed -n "2p" logcat_photo_wm_cap_begin_time.txt
	echo -n "   "
	sed -n "2p" logcat_photo_wm_cap_end_time.txt
	local startTime=$(sed -n "2p" logcat_photo_wm_cap_begin_time.txt | awk '{print $1 " " $2}')
	local endTime=$(sed -n "2p" logcat_photo_wm_cap_end_time.txt | awk '{print $1 " " $2}')
	local time=$(($(date +%s%3N -d "2023-$endTime") - $(date +%s%3N -d "2023-$startTime")))
	echo "   时间差：$time ms"
	rm logcat_photo_wm_cap_begin_time.txt
	rm logcat_photo_wm_cap_end_time.txt
	echo ""
	sleep 1
}

tranVideoWMCheck() {
	adb logcat -c
	echo ""
	#TODO（版本，时间）
}

continuousCapCheck() {
	echo " • ContinuousCapExceptionCheck"
	adb logcat -c
	if [ ${fb_brand,,} ==  "tran" ]
	then
		local TAG="TranCam-FaceBeauty"
	elif [ ${fb_brand,,} == "arc" ]
	then
		local TAG="TranCam-ArcFaceBeauty"
	else
		echo "   请检查配置文件中所选项目的FB_ALGO值，目前只支持tran或arc，可不区分大小写"
		echo "   [连拍异常未成功检测，请稍后重试]"
		return
	fi
	read -p "   请确保关闭[AI]、[美颜]、[滤镜]、[闪光灯]等不支持与连拍同时开启的设置项后回车确认"
	echo "   请进行连拍"
	adb logcat -v brief -b main $TAG *:S --regex "not process" > logcat_continuous_cap_fb.txt &
	local pid1=$!
	adb logcat -v brief -b main singlecam_blur_capture *:S > logcat_continuous_cap_blur.txt &
	local pid2=$!
	adb logcat -v brief -b main MFNRNode *:S > logcat_continuous_cap_mfnr.txt &
	local pid3=$!
	read -p "   请在完成连拍后回车确认"
	echo ""
	sleep 1
	kill $pid1
	kill $pid2
	kill $pid3
	if [ -s logcat_continuous_cap_fb.txt ]
	then
		echo "   连拍时未执行美颜算法"
	else
		echo "   ERROR：连拍时可能执行了美颜算法"
	fi
	if ! [ -s logcat_continuous_cap_blur.txt ]
	then
		echo "   连拍时未执行虚化算法"
	else
		echo "   ERROR：连拍时可能执行了虚化算法"
	fi
	if ! [ -s logcat_continuous_cap_mfnr.txt ]
	then
		echo "   连拍时未执行MFNR算法"
	else
		echo "   ERROR：连拍时可能执行了MFNR算法"
	fi
	rm logcat_continuous_cap_fb.txt
	rm logcat_continuous_cap_blur.txt
	rm logcat_continuous_cap_mfnr.txt
	echo ""
}

exceptionCheck() {
	echo "◆ ExceptionCheck"
	if [ ${continuous_cap,,} == "yes" ]
	then
		continuousCapCheck
	elif [ ${continuous_cap,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的CONTINUOUS_CAP值，只能为yes或no，可不区分大小写"
		echo "   [连拍异常未成功检测，请稍后重试]"
	fi
	#TODO
}

camCheck() {
	AICamCheck
	if [ ${fb_mode,,} == "yes" ]
	then
		echo "◆ FaceBeauty"
		if [ ${fb_brand,,} == "tran" ]
		then
			tranFbCheck "请进入或重新进入美颜模式"
		elif [ ${fb_brand,,} == "arc" ]
		then
			arcFbCheck "请进入或重新进入美颜模式"
		else
			echo "   请检查配置文件中所选项目的FB_ALGO值，目前只支持tran或arc，可不区分大小写"
			echo "   [FaceBeauty模式未成功检测，请稍后重试]"
		fi
	elif [ ${fb_mode,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的FB_MODE值，只能为yes或no，可不区分大小写"
		echo "   [FaceBeauty模式未成功检测，请稍后重试]"
	fi
	if [ ${portrait_mode,,} == "yes" ]
	then
		echo "◆ Portrait"
		if [ ${blur_brand,,} == "st" ]
		then
			stPortraitCheck
		else
			echo "   请检查配置文件中所选项目的BLUR_ALGO值，目前只支持st，可不区分大小写"
			echo "   [Portrait模式未成功检测，请稍后重试]"
		fi
	elif [ ${portrait_mode,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的PORTRAIT_MODE值，只能为yes或no，可不区分大小写"
		echo "   [Portrait模式未成功检测，请稍后重试]"
	fi
	if [ ${nightscene_mode,,} == "yes" ]
	then
		echo "◆ NightScene"
		if [ ${nightscene_mode_algo,,} == "mfnr" ]
		then
			nightSceneMfnrCheck
		elif [ ${nightscene_mode_algo,,} == "3dnr" ]
		then
			#TODO
			#nightScene3dnrCheck
			sleep 1
		else
			echo "   请检查配置文件中所选项目的NIGHTSCENE_ALGO值，目前只支持mfnr或3dnr，可不区分大小写"
			echo "   [NightScene模式未成功检测，请稍后重试]"
		fi
	elif [ ${nightscene_mode,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的NIGHTSCENE_MODE值，只能为yes或no，可不区分大小写"
		echo "   [NightScene模式未成功检测，请稍后重试]"
	fi
	if [ ${hdr_mode,,} == "yes" ]
	then
		echo "◆ HDR"
		if [ ${hdr_brand,,} == "sprd" ]
		then
			sprdHdrCheck "请切换至HDR模式"
		else
			echo "   请检查配置文件中所选项目的HDR_ALGO值，目前只支持sprd，可不区分大小写"
			echo "   [HDR未成功检测，请稍后重试]"
		fi
	elif [ ${hdr_mode,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的HDR_MODE值，只能为yes或no，可不区分大小写"
		echo "   [HDR模式未成功检测，请稍后重试]"
	fi
	if [ ${filter,,} == "yes" ]
	then
		echo "◆ FILTER"
		if [ ${filter_brand,,} == "arc" ]
		then
			arcFilterCheck
		else
			echo "   请检查配置文件中所选项目的FILTER_ALGO值，目前只支持arc，可不区分大小写"
			echo "   [滤镜未成功检测，请稍后重试]"
		fi
	elif [ ${filter,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的FILTER值，只能为yes或no，可不区分大小写"
		echo "   [滤镜未成功检测，请稍后重试]"
	fi
	if [ ${photo_wm,,} == "yes" ]
	then
		echo "◆ PHOTO_WATERMARK"
		if [ ${photo_wm_brand,,} == "tran" ]
		then
			tranPhotoWMCheck
		else
			echo "   请检查配置文件中所选项目的PHOTO_WM_ALGO值，目前只支持tran，可不区分大小写"
			echo "   [照片水印未成功检测，请稍后重试]"
		fi
	elif [ ${photo_wm,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的PHOTO_WM值，只能为yes或no，可不区分大小写"
		echo "   [照片水印未成功检测，请稍后重试]"
	fi
	if [ ${video_wm,,} == "yes" ]
	then
		echo "◆ VIDEO_WATERMARK"
		if [ ${video_wm_brand,,} == "tran" ]
		then
			tranVideoWMCheck
		else
			echo "   请检查配置文件中所选项目的PHOTO_WM_ALGO值，目前只支持tran，可不区分大小写"
			echo "   [视频水印未成功检测，请稍后重试]"
		fi
	elif [ ${video_wm,,} == "no" ]
	then
		sleep 1
	else
		echo "   请检查配置文件中所选项目的VIDEO_WM值，只能为yes或no，可不区分大小写"
		echo "   [视频水印未成功检测，请稍后重试]"
	fi
	exceptionCheck
}

main() {
	hint
	getProductList
	chooseProduct
	
	if [ ${brand,,} == "tecno" ]
	then
		echo "当前相机brand为TECNO"
	elif [ ${brand,,} == "itel" ]
	then
		echo "当前相机brand为ITEL"
	elif [ ${brand,,} == "infinix" ]
	then
		echo "当前相机brand为INFINIX"
	else
		echo "ERROR！请检查配置文件中的brand配置，目前该脚本只支持检查TECNO、ITEL或INFINIX其中一种。"
	fi
	camCheck
}

main
