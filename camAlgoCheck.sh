configPath=./config.txt

hint() {
	echo " --------------------------------------------------------------- "
	echo "| Preconditions: 请在执行该脚本前确认并修改配置文件的信息，     |"
	echo "|                并将配置文件与该脚本放置在同一路径下。         |"
	echo " --------------------------------------------------------------- "
	echo "| Tips: 该脚本分为半自动化和全自动化两部分。                    |"
	echo "|       前半部分为半自动化测试，需根据提示信息寻找场景配合测试；|"
	echo "|       后半部分为全自动化测试，可将测试机放在一旁等待测试结果。|"
	echo " --------------------------------------------------------------- "
}

getProductList() {
	productList=($(grep "PRODUCT=" $configPath | awk -F= '{print $2}'))
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
	fi
	brand=$(sed -n "${startLine}, ${endLine} s/\(BRAND.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	photo_asd=$(sed -n "${startLine}, ${endLine} s/\(PHOTO_ASD.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	photo_hdr=$(sed -n "${startLine}, ${endLine} s/\(PHOTO_HDR.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	photo_mfnr=$(sed -n "${startLine}, ${endLine} s/\(PHOTO_MFNR.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	photo_fb=$(sed -n "${startLine}, ${endLine} s/\(PHOTO_FB.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	fb_level=$(sed -n "${startLine}, ${endLine} s/\(FB_LEVEL.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	fb_mode=$(sed -n "${startLine}, ${endLine} s/\(FB_MODE.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	portrait_mode=$(sed -n "${startLine}, ${endLine} s/\(PORTRAIT_MODE.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	lowlight_mode=$(sed -n "${startLine}, ${endLine} s/\(LOWLIGHT_MODE.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	hdr_mode=$(sed -n "${startLine}, ${endLine} s/\(HDR_MODE.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
	asd_brand=$(sed -n "${startLine}, ${endLine} s/\(ASD_ALGO.*=.*\)/\1/p" $configPath | awk -F= '{print $2}')
}

chooseProduct() {
	echo "请选择项目名：（若选项中无所需项目，请在配置文件中按要求添加）"
	local num=0
	for item in ${productList[*]}
	do
		num=$(($num+1))
		echo "$num、$item"
	done
	read num
	getConfig ${productList[$(($num-1))]}
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
}

main