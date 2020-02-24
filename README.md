# DNSPod 配置 DDNS

## 使用方式

### 准备脚本

```bash
$ git clone git@github.com:jameszhan/dnspod-ddns.git
$ cd dnspod-ddns/
```

#### `Ruby`实现

> 本脚本执行依赖于Ruby

```bash
$ gem install faraday
$ cp dnspod_ddns.rb /opt/bin/dnspod_ddns
$ sudo chmod +x /opt/bin/dnspod_ddns
```

#### `Python`实现

> 本脚本执行依赖于Python3

```bash
$ pip3 install requests
$ cp dnspod_ddns.py /opt/bin/dnspod_ddns
$ sudo chmod +x /opt/bin/dnspod_ddns
```

### 测试脚本

```bash
$ export DNSPOD_LOGIN_TOKEN=id,token
$ export DNSPOD_DOMAIN=your.domain.com
$ export DNSPOD_SUB_DOMAIN=@
$ /opt/bin/dnspod_ddns
```

也可以通过命令行方式指定参数

```bash
$ export DNSPOD_LOGIN_TOKEN=id,token
$ export DNSPOD_DOMAIN=your.domain.com
$ /opt/bin/dnspod_ddns '*'
```

```bash
$ export DNSPOD_LOGIN_TOKEN=id,token
$ /opt/bin/dnspod_ddns '*' 'yourdomain.com'
```

```bash
/opt/bin/dnspod_ddns '*' 'yourdomain.com' 'id,token'
```

### 配置定时任务

#### 简单配置

```bash
$ crontab -e
```

进入编辑器，添加如下内容，每10分钟执行一次同步任务

```conf
*/10 * * * * /opt/bin/dnspod_ddns '@' 'yourdomain.com' 'id,token' > /dev/null
```

#### 使用环境变量

如果要使用系统环境变量，可以把如下配置加入到`/etc/environment`

```conf
DNSPOD_LOGIN_TOKEN=id,token
DNSPOD_DOMAIN=your.domain.com
DNSPOD_SUB_DOMAIN=@
```

```conf
*/10 * * * * /opt/bin/dnspod_ddns > /dev/null
```

也可以直接把依赖的环境变量，配置在`cron`配置文件当中

```conf
DNSPOD_LOGIN_TOKEN=id,token
DNSPOD_DOMAIN=your.domain.com
DNSPOD_SUB_DOMAIN=@
*/10 * * * * /opt/bin/dnspod_ddns > /dev/null
```

#### 同时配置多个任务

```conf
DNSPOD_LOGIN_TOKEN=id,token
DNSPOD_DOMAIN=your.domain.com
*/10 * * * * /opt/bin/dnspod_ddns '@' > /dev/null
*/10 * * * * /opt/bin/dnspod_ddns '*' > /dev/null
```

#### 启用cron日志

```bash
$ sudo vim /etc/rsyslog.d/50-default.conf
```

去掉`cron`前面的注释(#)。

```bash
$ sudo systemctl restart rsyslog
```

检查cron进程状态和任务配置

```bash
$ sudo systemctl restart cron

$ sudo service cron status
# 或
$ sudo systemctl status cron

$ crontab -l
```

## 任务脚本工作详解

- [创建`DNSPod`密钥](https://console.dnspod.cn/account/token)
- [`DNSPod`用户`API`文档](https://www.dnspod.cn/docs/index.html)

### 使用SHELL模拟脚本工作流程

```bash
$ export DNSPOD_LOGIN_TOKEN=id,token

# 查询目标DNS记录详情
$ curl -X POST https://dnsapi.cn/Record.List \
    -H "User-Agent: DNSPod-DDNS/1.0.0" \
    -d "login_token=${DNSPOD_LOGIN_TOKEN}&format=json&domain=zizhizhan.com&record_type=A&sub_domain=@" \
    | python3 -m json.tool

# 获取目标DNS记录ID
$ curl -X POST https://dnsapi.cn/Record.List \
    -H "User-Agent: DNSPod-DDNS/1.0.0" \
    -d "login_token=${DNSPOD_LOGIN_TOKEN}&format=json&domain=zizhizhan.com&record_type=A&sub_domain=@" \
    | python3 -c "import sys,json; ret=json.load(sys.stdin); print(ret.get('records', [{}])[0].get('id', ''))"

# 同步本地外网IP到DNSPod
$ curl -X POST https://dnsapi.cn/Record.Modify \
    -H "User-Agent: DNSPod-DDNS/1.0.0" \
    -d "login_token=${DNSPOD_LOGIN_TOKEN}&format=json&record_id=548361017&value=8.8.8.8&domain=zizhizhan.com&sub_domain=@&record_type=A&record_line=默认"
```

### 查询本机外网`IP`

```bash
$ telnet ns1.dnspod.net 6666
$ curl -i http://myip.ipip.net/
$ curl -i http://www.httpbin.org/ip
$ curl -i http://whatismyip.akamai.com
$ curl -i http://ipecho.net/plain
$ curl -i http://myip.dnsomatic.com
```