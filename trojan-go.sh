#!/bin/bash
# Wiki: https://github.com/p4gefau1t/trojan-go

domain=$(cat /root/domain)

#install bbr
wget https://raw.githubusercontent.com/Endka22/Autosc/main/bbr.sh &&  chmod +x bbr.sh && ./bbr.sh

# Install Trojan-GO
mkdir -p /etc/trojan-go/
cd /etc/trojan-go/
wget https://github.com/p4gefau1t/trojan-go/releases/download/v0.4.2/trojan-go-linux-amd64.zip
unzip trojan-go-linux-amd64.zip
rm -rf trojan-go-linux-amd64.zip
chmod +x /usr/local/bin/trojan-go
touch /etc/trojan-go/akun.conf
touch /etc/trojan-go/trojan-go.pid
cd /var/log/
mkdir -p trojan-go
uuid=$(cat /proc/sys/kernel/random/uuid)
cat <<EOF> /etc/systemd/system/trojan-go.service
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target nss-lookup.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/server.json
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/trojan-go/config.json << EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 2096,
  "remote_addr": "127.0.0.1",
  "remote_port": 81,
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
cat <<EOF > /etc/trojan-go/uuid.txt
$uuid
EOF
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2096 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2096 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 81 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 81 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

systemctl daemon-reload
systemctl enable trojan-go.service
systemctl start trojan-go.service
