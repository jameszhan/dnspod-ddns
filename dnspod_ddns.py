#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import socket
import requests

args = sys.argv[1:]
if len(args) > 0:
    dnspod_sub_domain = args[0]
else:
    dnspod_sub_domain = os.environ['DNSPOD_SUB_DOMAIN']

if len(args) > 1:
    dnspod_domain = args[1]
else:
    dnspod_domain = os.environ['DNSPOD_DOMAIN']

if len(args) > 2:
    login_token = args[2]
else:
    login_token = os.environ['DNSPOD_LOGIN_TOKEN']

def synchorize_myip():
    dns_record_id, dns_record_value = get_dns_record_id()
    if dns_record_id > 0:
        myip = get_myip()
        if dns_record_value != myip:
            print("changed from {0} to {1}".format(dns_record_value, myip))
            r = requests.post('https://dnsapi.cn/Record.Modify', data = {
                'format': 'json',
                'record_id': dns_record_id,
                'value': myip,
                'domain': dnspod_domain,
                'sub_domain': dnspod_sub_domain,
                'login_token': login_token,
                'record_type': 'A',
                'record_line': '默认'
            })
            print(r.json())
        else:
            print("ip is {0}, not changed".format(myip))
    else:
        print('{0}.{1} not exists or login token is invalid.'.format(dnspod_sub_domain, dnspod_domain))

def get_myip():
    rsp = requests.get("http://ipecho.net/plain")
    return rsp.text

def get_dns_record_id():
    r = requests.post('https://dnsapi.cn/Record.List', data = {
        'format': 'json',
        'domain': dnspod_domain,
        'sub_domain': dnspod_sub_domain,
        'login_token': login_token,
        'record_type': 'A'
    })
    record = r.json().get('records', [{}])[0]
    return (int(record.get('id', '0')), record.get('value'))

if __name__ == '__main__':
    synchorize_myip()