#!/usr/bin/env ruby

require 'socket'
require 'faraday'
require 'json'
require 'pp'

LOGIN_TOKEN = ENV['DNSPOD_LOGIN_TOKEN']
DOMAIN = ENV['DNSPOD_DOMAIN']
SUB_DOMAIN = ENV['DNSPOD_SUB_DOMAIN']

def synchorize_myip
    resp = connection.post '/Record.Modify', { 
        format: 'json',
        record_id: dns_record_id,
        value: myip,
        domain: DOMAIN, 
        sub_domain: SUB_DOMAIN,
        login_token: LOGIN_TOKEN,
        record_type: 'A',
        record_line: '默认'
    }
    pp resp.body
end

def myip
    socket = TCPSocket.new 'ns1.dnspod.net', 6666
    begin
        # socket.recv(16)
        socket.read
    ensure
        socket.close
    end
end

def dns_record_id
    resp = connection.post '/Record.List', { 
        format: 'json', 
        domain: DOMAIN, 
        sub_domain: SUB_DOMAIN,
        login_token: LOGIN_TOKEN,
        record_type: 'A'
    }
    JSON.parse(resp.body)['records'][0]['id']
end

private
def connection
    @connection ||= Faraday.new(url: 'https://dnsapi.cn') do |faraday|
        faraday.headers['User-Agent'] = 'DNSPod-DDNS/1.0.0'
        faraday.request :url_encoded # form-encode POST params
        faraday.response :logger # log requests to STDOUT
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
end


synchorize_myip