#!/bin/bash
set -o noglob

DnspodSubDomain=$1
DnspodDomain=$2
DnspodLoginToken=$3

if [ -z $DnspodSubDomain ]; then
    DnspodSubDomain=$DNSPOD_SUB_DOMAIN
fi

if [ -z $DnspodDomain ]; then
    DnspodDomain=$DNSPOD_DOMAIN
fi

if [ -z $DnspodLoginToken ]; then
    DnspodLoginToken=$DNSPOD_LOGIN_TOKEN
fi

PostData="login_token=$DnspodLoginToken&format=json&domain=$DnspodDomain&sub_domain=$DnspodSubDomain&record_type=A"

result=$(wget -qO- --no-check-certificate --content-on-error --post-data "$PostData" https://dnsapi.cn/Record.List)

echo $result