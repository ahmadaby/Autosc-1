#!/bin/bash
# Trojan Go Auto Setup 
# =========================

# Installing Wget & Curl
apt update -y
apt upgrade -y
apt install wget -y
apt install screen -y
apt install curl -y
apt install zip

# Domain # Silakan Berpikir Sendri caranya
domain=$(cat /root/domain)

# Installing Trojan Go
mkdir -p /etc/trojan-go-mini/
chmod 755 /etc/trojan-go-mini/
touch /etc/trojan-go-mini/trojan-go.pid
wget -O /usr/bin/trojan-go-mini https://raw.githubusercontent.com/Endka22/Autosc/main/trojan-go
wget -O /usr/bin/geoip.dat https://raw.githubusercontent.com/Endka22/Autosc/main/geoip.dat
wget -O /usr/bin/geosite.dat https://raw.githubusercontent.com/Endka22/Autosc/main/geosite.dat
chmod +x /usr/bin/trojan-go-mini

# Config
cat <<EOF> /etc/trojan-go-mini/config.json
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 2096,
  "remote_addr": "127.0.0.1",
  "remote_port": 85,
  "log_level": 1,
  "log_file": "/var/log/trojan-go/trojan-go.log",
  "password": [
    "$uuid",
    "$uuid",
    ""
  ],
  "ssl": {
    "cert": "/etc/v2ray/v2ray.crt",
    "key": "/etc/v2ray/v2ray.key"
  },
  "websocket": {
    "enabled": true,
    "path": "/Endka22"
    "hostname": "$domain"
  }
}
EOF

# Service
cat > /etc/systemd/system/trojan-go-mini.service << END
[Unit]
Description=Trojan-Go Mini Service
Documentation=https://p4gefau1t.github.io/trojan-go/
Documentation=https://github.com/trojan-gfw/trojan
Documentation=https://endka.net
After=network.target

[Service]
Type=simple
PIDFile=/etc/trojan-go-mini/trojan-go.pid
ExecStart=/usr/bin/trojan-go-mini -c /etc/trojan-go-mini/config.json -l /var/log/trojan-go/trojan-go.log
KillMode=process
Restart=no
RestartSec=42s

[Install]
WantedBy=multi-user.target
END

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2096 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 85 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2096 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 85 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl enable trojan-go-mini
systemctl start trojan-go-mini
systemctl enable trojan-go-mini.service
systemctl start trojan-go-mini.service

# Starting
systemctl daemon-reload
systemctl enable trojan-go-mini
systemctl start trojan-go-mini
