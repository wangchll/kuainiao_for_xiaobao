#!/bin/sh
eval `dbus export kuainiao`
source /koolshare/scripts/base.sh
version="0.0.1"

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

#从dbus中获取uid，pwd等
uid=$kuainiao_config_uid
pwd=$kuainiao_config_pwd
nic=$kuainiao_config_nic
peerid=$kuainiao_config_peerid
uid_orig=$uid
api_url=$kuainiao_config_api

#初始化计数器
if [ -z "$kuainiao_run_i" ]; then
	dbus ram kuainiao_run_i=6
fi

#初始化运行状态(kuainiao_run_status 0表示运行异常，1表示运行正常)
if [ -z "$kuainiao_run_status" ]; then
	dbus ram kuainiao_run_status=0
fi

#判断是否可以加速
if [[ ! $kuainiao_can_upgrade -eq 1 ]]; then
	dbus ram kuainiao_run_i=6
	dbus ram kuainiao_run_warnning="您的宽带不能使用讯鸟快鸟加速！"$(date "+%Y-%m-%d %H:%M:%S")
	dbus ram kuainiao_run_status=0
	exit 21
fi

#初始化日期
if [[ -z $kuainiao_run_orig_day ]]; then
	day_of_month_orig=`date +%d`
	orig_day_of_month=`echo $day_of_month_orig|grep -oE "[1-9]{1,2}"`
	dbus ram kuainiao_run_orig_day=$orig_day_of_month
fi

#开始执行逻辑
##判断是否跨天
day_of_month_orig=`date +%d`
day_of_month=`echo $day_of_month_orig|grep -oE "[1-9]{1,2}"`
if [[ -z $kuainiao_run_orig_day || $day_of_month -ne $kuainiao_run_orig_day ]]; then
	dbus ram kuainiao_run_orig_day=$day_of_month
	$HTTP_REQ "$api_url/recover?peerid=$peerid&userid=$uid&user_type=1&sessionid=$kuainiao_run_session"
	dbus ram kuainiao_run_i=6
	sleep 5
fi

#判断是否需要重新登陆
if test $kuainiao_run_i -ge 6; then
	ret=`$HTTP_REQ https://login.mobile.reg2t.sandai.net:443/ $POST_ARG"{\"userName\": \""$uid"\", \"businessType\": 68, \"clientVersion\": \"1.1\", \"appName\": \"ANDROID-com.xunlei.vip.swjsq\", \"isCompressed\": 0, \"sequenceNo\": 1000001, \"sessionID\": \"\", \"loginType\": 1, \"rsaKey\": {\"e\": \"10001\", \"n\": \"D6F1CFBF4D9F70710527E1B1911635460B1FF9AB7C202294D04A6F135A906E90E2398123C234340A3CEA0E5EFDCB4BCF7C613A5A52B96F59871D8AB9D240ABD4481CCFD758EC3F2FDD54A1D4D56BFFD5C4A95810A8CA25E87FDC752EFA047DF4710C7D67CA025A2DC3EA59B09A9F2E3A41D4A7EFBB31C738B35FFAAA5C6F4E6F\"}, \"cmdID\": 1, \"verifyCode\": \"\", \"peerID\": \""$peerid"\", \"protocolVersion\": 101, \"platformVersion\": 1, \"passWord\": \""$pwd"\", \"extensionList\": \"\", \"verifyKey\": \"\"}"`
	session=`echo $ret|awk -F '"sessionID":' '{print $2}'|awk -F ',' '{print $1}'|grep -oE "[A-F,0-9]{32}"`
	uid=`echo $ret|awk -F '"userID":' '{print $2}' | awk -F ',' '{print $1}'`
	#登陆完成重置计数器
	dbus ram kuainiao_run_i=0
	#判断登陆是否成功
	if [ -z "$session" ]; then
		#登陆失败重置计数器到6
		dbus ram kuainiao_run_i=6
		dbus ram kuainiao_run_warnning="迅雷账号登陆失败！请检查迅雷账号配置！"$(date "+%Y-%m-%d %H:%M:%S")
		dbus ram kuainiao_run_status=0
		exit 20
	else
		#登陆成功设置登陆日期和session
		day_of_month_orig=`date +%d`
		orig_day_of_month=`echo $day_of_month_orig|grep -oE "[1-9]{1,2}"`
		dbus ram kuainiao_run_orig_day=$orig_day_of_month
		dbus ram kuainiao_run_session=$session
	fi
	#判断返回的uid
	if [ -z "$uid" ]; then
		uid=$uid_orig
	fi
	#开始加速
	$HTTP_REQ "$api_url/upgrade?peerid=$peerid&userid=$uid&user_type=1&sessionid=$kuainiao_run_session"
fi

sleep 1

#保持心跳
ret=`$HTTP_REQ "$api_url/keepalive?peerid=$peerid&userid=$uid&user_type=1&sessionid=$kuainiao_run_session"`
if [ ! -z "`echo $ret|grep "not exist channel"`" ]; then
	dbus ram kuainiao_run_i=6
	dbus ram kuainiao_run_warnning="迅雷快鸟心跳保持失败！"$(date "+%Y-%m-%d %H:%M:%S")
	dbus ram kuainiao_run_status=0
	exit 22
else
	dbus ram kuainiao_run_i=$(expr $kuainiao_run_i + 1)
	dbus ram kuainiao_run_warnning="迅雷快鸟运行正常！"$(date "+%Y-%m-%d %H:%M:%S")
	dbus ram kuainiao_run_status=1
fi
