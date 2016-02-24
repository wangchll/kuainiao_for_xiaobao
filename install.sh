#!/bin/sh

cd /tmp
wget --no-check-certificate --tries=1 --timeout=15 https://raw.githubusercontent.com/wangchll/kuainiao_for_xiaobao/master/kuainiao.tar.gz
tar -zxf kuainiao.tar.gz
chmod a+x /tmp/kuainiao/update.sh
sh /tmp/kuainiao/update.sh
echo "迅雷快鸟安装完成~~"
