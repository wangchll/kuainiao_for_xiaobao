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

#从dbus中获取uid，pwd
uid=$kuainiao_config_uid
pwd=$kuainiao_config_pwd

#定义常量
nic=eth0
peerid=$(ifconfig $nic|grep $nic|awk 'gsub(/:/, "") {print $5}')004V
uid_orig=$uid

day_of_month_orig=`date +%d`
orig_day_of_month=`echo $day_of_month_orig|grep -oE "[1-9]{1,2}"`
portal=`$HTTP_REQ http://api.portal.swjsq.vip.xunlei.com:81/v2/queryportal`
portal_ip=`echo $portal|grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`
portal_port_temp=`echo $portal|grep -oE "port...[0-9]{1,5}"`
portal_port=`echo $portal_port_temp|grep -oE '[0-9]{1,5}'`
if [ -z "$portal_ip" ]
  then
	 sleep 30
	 portal=`$HTTP_REQ http://api.portal.swjsq.vip.xunlei.com:81/v2/queryportal`
     portal_ip=`echo $portal|grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`
     portal_port_temp=`echo $portal|grep -oE "port...[0-9]{1,5}"`
     portal_port=`echo $portal_port_temp|grep -oE '[0-9]{1,5}'`
	 if [ -z "$portal_ip" ]
          then
             portal_ip="119.147.41.210"
	         portal_port=80
	 fi
fi
api_url="http://$portal_ip:$portal_port/v2"
i=6
while true
do
    if test $i -ge 6
    then
        ret=`$HTTP_REQ https://login.mobile.reg2t.sandai.net:443/ $POST_ARG"{\"userName\": \""$uid"\", \"businessType\": 68, \"clientVersion\": \"1.1\", \"appName\": \"ANDROID-com.xunlei.vip.swjsq\", \"isCompressed\": 0, \"sequenceNo\": 1000001, \"sessionID\": \"\", \"loginType\": 1, \"rsaKey\": {\"e\": \"10001\", \"n\": \"D6F1CFBF4D9F70710527E1B1911635460B1FF9AB7C202294D04A6F135A906E90E2398123C234340A3CEA0E5EFDCB4BCF7C613A5A52B96F59871D8AB9D240ABD4481CCFD758EC3F2FDD54A1D4D56BFFD5C4A95810A8CA25E87FDC752EFA047DF4710C7D67CA025A2DC3EA59B09A9F2E3A41D4A7EFBB31C738B35FFAAA5C6F4E6F\"}, \"cmdID\": 1, \"verifyCode\": \"\", \"peerID\": \""$peerid"\", \"protocolVersion\": 101, \"platformVersion\": 1, \"passWord\": \""$pwd"\", \"extensionList\": \"\", \"verifyKey\": \"\"}"`
		session=`echo $ret|awk -F '"sessionID":' '{print $2}'|awk -F ',' '{print $1}'|grep -oE "[A-F,0-9]{32}"`
		uid=`echo $ret|awk -F '"userID":' '{print $2}' | awk -F ',' '{print $1}'`
        i=0
	  if [ -z "$session" ]
        then
              echo "session is empty"
              i=6
              sleep 5
              continue
        else
              echo "session is $session"
        fi

      if [ -z "$uid" ]
        then
	        echo "uid is empty"
			uid=$uid_orig
        else
            echo "uid is $uid"
        fi
        $HTTP_REQ "$api_url/upgrade?peerid=$peerid&userid=$uid&user_type=1&sessionid=$session"

    fi
    sleep 1
	day_of_month_orig=`date +%d`
    day_of_month=`echo $day_of_month_orig|grep -oE "[1-9]{1,2}"`
    if [[ -z $orig_day_of_month || $day_of_month -ne $orig_day_of_month ]]
     then
       orig_day_of_month=$day_of_month
       $HTTP_REQ "$api_url/recover?peerid=$peerid&userid=$uid&user_type=1&sessionid=$session"
       sleep 5
	fi
    ret=`$HTTP_REQ "$api_url/keepalive?peerid=$peerid&userid=$uid&user_type=1&sessionid=$session"`
    if [ ! -z "`echo $ret|grep "not exist channel"`" ]
    then
        i=6
    else
        let i=i+1
        sleep 270
    fi
done
