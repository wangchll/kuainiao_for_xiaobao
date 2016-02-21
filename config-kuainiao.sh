#!/bin/sh
eval `dbus export kuainiao`
source /koolshare/scripts/base.sh
version="0.0.1"
dbus set kuainiao_warning=""
dbus set kuainiao_can_upgrade=0

TEST_URL="https://baidu.com"
if [ ! -z "`wget --no-check-certificate -O - $TEST_URL 2>&1|grep "100%"`" ]
	then
		HTTP_REQ="wget --no-check-certificate -O - "
		POST_ARG="--post-data="
	else
		command -v curl >/dev/null 2>&1 && curl -kI $TEST_URL >/dev/null 2>&1 || { echo >&2 "Xunlei-FastD1ck cannot find wget or curl installed with https(ssl) enabled in this system."; exit 1; }
		HTTP_REQ="curl -ks"
		POST_ARG="--data "
fi

#数据mock
uname=$kuainiao_config_uname
pwd=$kuainiao_config_pwd
nic=eth0
peerid=$(ifconfig $nic|grep $nic|awk 'gsub(/:/, "") {print $5}')004V
#peerid=ACBC32AF6EED004V
#uid_orig=$uid

#获取迅雷用户uid
get_xunlei_uid(){
	ret=`$HTTP_REQ https://login.mobile.reg2t.sandai.net:443/ $POST_ARG"{\"userName\": \""$uname"\", \"businessType\": 68, \"clientVersion\": \"1.1\", \"appName\": \"ANDROID-com.xunlei.vip.swjsq\", \"isCompressed\": 0, \"sequenceNo\": 1000001, \"sessionID\": \"\", \"loginType\": 0, \"rsaKey\": {\"e\": \"10001\", \"n\": \"D6F1CFBF4D9F70710527E1B1911635460B1FF9AB7C202294D04A6F135A906E90E2398123C234340A3CEA0E5EFDCB4BCF7C613A5A52B96F59871D8AB9D240ABD4481CCFD758EC3F2FDD54A1D4D56BFFD5C4A95810A8CA25E87FDC752EFA047DF4710C7D67CA025A2DC3EA59B09A9F2E3A41D4A7EFBB31C738B35FFAAA5C6F4E6F\"}, \"cmdID\": 1, \"verifyCode\": \"\", \"peerID\": \""$peerid"\", \"protocolVersion\": 101, \"platformVersion\": 1, \"passWord\": \""$pwd"\", \"extensionList\": \"\", \"verifyKey\": \"\"}"`
	#判断是否登陆成功
	session=`echo $ret|awk -F '"sessionID":' '{print $2}'|awk -F ',' '{print $1}'|grep -oE "[A-F,0-9]{32}"`

	if [ -z "$session" ]
	  then
		  dbus set kuainiao_warning="迅雷账号登陆失败，请检查输入的用户名密码!"
		  #echo "迅雷账号登陆失败，请检查输入的用户名密码!"
	  else
		  uid=`echo $ret|awk -F '"userID":' '{print $2}'|awk -F ',' '{print $1}'`
		  dbus set kuainiao_config_uid=$uid
	fi
}

#获取加速API
get_kuainiao_api(){
	portal=`$HTTP_REQ http://api.portal.swjsq.vip.xunlei.com:81/v2/queryportal`
	portal_ip=`echo $portal|grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`
	portal_port_temp=`echo $portal|grep -oE "port...[0-9]{1,5}"`
	portal_port=`echo $portal_port_temp|grep -oE '[0-9]{1,5}'`
	if [ -z "$portal_ip" ]
		then
			dbus set kuainiao_warning="迅雷快鸟服务API获取失败，请检查网络环境，或稍后再试!"
			#echo "迅雷快鸟服务API获取失败，请检查网络环境，或稍后再试!"
		else
			api_url="http://$portal_ip:$portal_port/v2"
	fi
}

#检测快鸟加速信息
get_bandwidth(){
	if [ -n "$api_url" ]; then
		band=$(bandwidth)
		can_upgrade=`echo $band|awk -F '"can_upgrade":' '{print $2}'|awk -F ',' '{print $1}'`
		dbus set kuainiao_can_upgrade=$can_upgrade
		#判断是否满足加速条件
		if [[ $can_upgrade -eq 1 ]]; then
			#echo "迅雷快鸟可以加速~~~愉快的开始加速吧~~"
			#获取加速详细信息
			old_downstream=`echo $band|awk -F '"bandwidth":' '{print $2}'|awk -F '"downstream":' '{print $2}'|awk -F ',' '{print $1}'`
			max_downstream=`echo $band|awk -F '"max_bandwidth":' '{print $2}'|awk -F '"downstream":' '{print $2}'|awk -F ',' '{print $1}'`
			dbus set kuainiao_warning="迅雷快鸟可以加速~~~愉快的开始加速吧~~"
			dbus set kuainiao_old_downstream=$old_downstream
			dbus set kuainiao_max_downstream=$max_downstream
		else
			dbus set kuainiao_warning="T_T 不能加速啊，不满足加速条件哦~~"
			#echo "T_T 不能加速啊，不满足加速条件哦~~"
		fi
	fi
}

#检测是否可以使用迅雷快鸟服务
check_kuainiao(){
	portal=`$HTTP_REQ http://api.portal.swjsq.vip.xunlei.com:81/v2/queryportal`
	portal_ip=`echo $portal|grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`
	portal_port_temp=`echo $portal|grep -oE "port...[0-9]{1,5}"`
	portal_port=`echo $portal_port_temp|grep -oE '[0-9]{1,5}'`
	if [ -z "$portal_ip" ]
		then
			#export kuainiao_warning="迅雷快鸟服务API获取失败，请检查网络环境，或稍后再试!"
			echo "迅雷快鸟服务API获取失败，请检查网络环境，或稍后再试!"
		else
			api_url="http://$portal_ip:$portal_port/v2"
			#开始尝试加速
			res=`$HTTP_REQ "$api_url/upgrade?peerid=$peerid&userid=$uid&user_type=1&sessionid=$session"`
			#echo $res
			errno=`echo $res|awk -F '"errno":' '{print $2}'|awk -F ',' '{print $1}'`
			#判断是否加速成功(errno=812的时候为:当前宽带已处于提速状态)
			if [ -n "$errno" ]
				then
					richmessage=`echo $res|awk -F '"richmessage":' '{print $2}'|awk -F ',' '{print $1}'|awk '{sub(/^"*/,"");sub(/"*$/,"")}1'`
					#export kuainiao_warning=$richmessage
					echo $richmessage
				else
					downstream=`echo $ret|awk -F '"downstream":' '{print $2}'|awk -F ',' '{print $1}'`
					upstream=`echo $ret|awk -F '"upstream":' '{print $2}'|awk -F ',' '{print $1}'`
			fi
	fi
}

#检测试用加速信息
query_try_info(){
	info=`$HTTP_REQ "$api_url/query_try_info?peerid=$peerid&userid=$uid&user_type=1&sessionid=$session"`
	echo $info
}
##{"errno":0,"message":"","number_of_try":0,"richmessage":"","sequence":0,"timestamp":1455936922,"try_duration":10}

#检测提速带宽
bandwidth(){
	width=`$HTTP_REQ "$api_url/bandwidth?peerid=$peerid&userid=$uid&user_type=1&sessionid=$session"`
	echo $width
}
##{"bandwidth":{"downstream":51200,"upstream":0},"can_upgrade":1,"dial_account":"100001318645","errno":0,"max_bandwidth":{"downstream":102400,"upstream":0},"message":"","province":"bei_jing","province_name":"北京","richmessage":"","sequence":0,"sp":"cnc","sp_name":"联通","timestamp":1455936922}

#迅雷快鸟加速心跳
kuainiao_keepalive(){
	keepalive=`$HTTP_REQ "$api_url/keepalive?peerid=$peerid&userid=$uid&user_type=1&sessionid=$session"`
	echo $keepalive
}

#快鸟加速注销
kuainiao_recover(){
	recover=`$HTTP_REQ "$api_url/recover?peerid=$peerid&userid=$uid&user_type=1&sessionid=$session"`
	echo $recover
}

##测试demo逻辑
get_xunlei_uid

if [ -n "$uid" ]; then
	get_kuainiao_api
	get_bandwidth
	#echo "本身带宽:"`expr $old_downstream / 1024`"M"
	#echo "最大提速带宽:"`expr $max_downstream / 1024`"M"
	#check_kuainiao
	#query_try_info
	#bandwidth
fi
