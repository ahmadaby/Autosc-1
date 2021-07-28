#!/bin/bash
# Trojan Go Auto Setup 
# =========================

apt update -y
apt upgrade -y
apt install wget -y
apt install screen -y
apt install curl -y
apt install zip
# Domain 
domain=$(cat /etc/v2ray/domain)

# Installing Trojan Go
mkdir -p /etc/trojan-go/
chmod 755 /etc/trojan-go/
touch /etc/trojan-go/trojan-go.pid
touch /etc/trojan-go/akun.conf
wget -O /usr/local/bin/trojan-go https://raw.githubusercontent.com/Endka22/Autosc/main/trojan-go
wget -O /usr/local/bin/geoip.dat https://raw.githubusercontent.com/Endka22/Autosc/main/geoip.dat
wget -O /usr/local/bin/geosite.dat https://raw.githubusercontent.com/Endka22/Autosc/main//geosite.dat
chmod +x /usr/local/bin/trojan-go

# Service
cat > /etc/systemd/system/trojan-go.service << END
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
Documentation=https://endka-stores.xyz
After=network.target nss-lookup.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -c /etc/trojan-go/config.json -l /var/log/trojan-go/trojan-go.log
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
END

# Config
cat > /etc/trojan-go/config.json << END
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 2096,
  "remote_addr": "127.0.0.1",
  "remote_port": 81,
  "log_level": 1,
  "log_file": "/var/log/trojan-go.log",
  "password": [
    "endka"
  ],
  "disable_http_check": false,
  "udp_timeout": 60,
  "ssl": {
    "verify": true,
    "verify_hostname": true,
    "cert": "/etc/v2ray/v2ray.crt",
    "key": "/etc/v2ray/v2ray.key",
    "key_password": "",
    "cipher": "",
    "curves": "",
    "prefer_server_cipher": false,
    "sni": "$domain",
    "alpn": [
      "h2"
    ],
    "session_ticket": true,
    "reuse_session": true,
    "plain_http_response": "",
    "fallback_addr": "",
    "fallback_port": 0,
    "fingerprint": "firefox"
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "prefer_ipv4": true
  },
  "mux": {
    "enabled": true,
    "concurrency": 64,
    "idle_timeout": 60
  },
  "router": {
    "enabled": false,
    "bypass": [],
    "proxy": [],
    "block": [],
    "default_policy": "proxy",
    "domain_strategy": "as_is",
    "geoip": "/usr/local/bin/geoip.dat",
    "geosite": "/usr/local/bin/geosite.dat"
  },
  "websocket": {
    "enabled": true,
    "path": "/trojango",
    "host": "$domain"
  },
  "shadowsocks": {
    "enabled": false,
    "method": "AES-128-GCM",
    "password": ""
  },
  "transport_plugin": {
    "enabled": false,
    "type": "",
    "command": "",
    "plugin_option": "",
    "arg": [],
    "env": []
  },
  "forward_proxy": {
    "enabled": false,
    "proxy_addr": "",
    "proxy_port": 0,
    "username": "",
    "password": ""
  },
  "mysql": {
    "enabled": false,
    "server_addr": "localhost",
    "server_port": 3306,
    "database": "",
    "username": "",
    "password": "",
    "check_rate": 60
  },
  "api": {
    "enabled": false,
    "api_addr": "",
    "api_port": 0,
    "ssl": {
      "enabled": false,
      "key": "",
      "cert": "",
      "verify_client": false,
      "client_cert": []
    }
  }
}

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2096 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 81 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2096 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 81 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl enable trojan-go.service
systemctl start trojan-go.service
systemctl enable trojan-go
systemctl start trojan-go
