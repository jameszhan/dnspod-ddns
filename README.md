# DNSPod 配置 DDNS

## 使用方式

### 准备脚本

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
$ /opt/bin/dnspod_ddns '*' 'your.domain.com'
```

```bash
/opt/bin/dnspod_ddns '*' 'your.domain.com' 'id,token'
```

### 配置定时任务

