#!/usr/bin/env python
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
    dns_record_id = get_dns_record_id()
    if dns_record_id > 0:
        myip = get_myip()
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
        print('{0}.{1} not exists or login token is invalid.'.format(dnspod_sub_domain, dnspod_domain))

def get_myip():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect(("ns1.dnspod.net", 6666))
        return s.recv(16)

def get_dns_record_id():
    r = requests.post('https://dnsapi.cn/Record.List', data = {
        'format': 'json',
        'domain': dnspod_domain,
        'sub_domain': dnspod_sub_domain,
        'login_token': login_token,
        'record_type': 'A'
    })
    return int(r.json().get('records', [{}])[0].get('id', '0'))

if __name__ == '__main__':
    synchorize_myip()