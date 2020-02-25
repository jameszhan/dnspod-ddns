#!/bin/bash
set -o noglob

dnspodSubDomain=$1
dnspodDomain=$2
dnspodLoginToken=$3

if [ -z $dnspodSubDomain ]; then
    dnspodSubDomain=$DNSPOD_SUB_DOMAIN
fi

if [ -z $dnspodDomain ]; then
    dnspodDomain=$DNSPOD_DOMAIN
fi

if [ -z $dnspodLoginToken ]; then
    dnspodLoginToken=$DNSPOD_LOGIN_TOKEN
fi

postData="login_token=$dnspodLoginToken&format=json&domain=$dnspodDomain&sub_domain=$dnspodSubDomain&record_type=A"

records=$(wget -qO- --no-check-certificate --content-on-error --post-data "$postData" https://dnsapi.cn/Record.List)
recordId=$(echo $records | python -c "import sys,json; ret=json.load(sys.stdin); print(ret.get('records', [{}])[0].get('id', ''))")
recordIP=$(echo $records | python -c "import sys,json; ret=json.load(sys.stdin); print(ret.get('records', [{}])[0].get('value', ''))")

myIP=$(wget -qO- --no-check-certificate --content-on-error http://ns1.dnspod.net:6666)

if [ $recordIP = $myIP ]; then
    echo "IP not changed"
else
    updatePostData="$postData&record_id=$recordId&value=$myIP&record_line=默认"
    echo $(wget -qO- --no-check-certificate --content-on-error --post-data "$updatePostData" https://dnsapi.cn/Record.Modify)
fi

