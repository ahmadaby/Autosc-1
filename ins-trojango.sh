#!/bin/bash
# Wiki: https://github.com/p4gefau1t/trojan-go

domain=$(cat /root/domain)

#install bbr
wget https://raw.githubusercontent.com/Endka22/Autosc/main/bbr.sh &&  chmod +x bbr.sh && ./bbr.sh

# Install Trojan-GO
	mkdir /etc/trojan-go
	mkdir /usr/lib/trojan-go
	wget -N --no-check-certificate https://github.com/p4gefau1t/trojan-go/releases/download/$(curl -fsSL https://api.github.com/repos/p4gefau1t/trojan-go/releases | grep '"tag_name":' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')/trojan-go-linux-amd64.zip && unzip -d /usr/lib/trojan-go/ ./trojan-go-linux-amd64.zip && mv /usr/lib/trojan-go/trojan-go /usr/bin/ && chmod +x /usr/bin/trojan-go && rm -rf ./trojan-go-linux-amd64.zip
	cp /usr/lib/trojan-go/example/server.json /etc/trojan-go/config.json
	cp /usr/lib/trojan-go/example/trojan-go.service /etc/systemd/system/trojan-go.service
	systemctl daemon-reload
	systemctl enable trojan-go
	echo Done!

cat <<EOF> /etc/systemd/system/trojan-go.service
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target nss-lookup.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/trojan-go/config.json << EOF
{
  "run_type": "server",
    "disable_http_check": true,
    "local_addr": "127.0.0.1",
    "local_port": 13003,
    "remote_addr": "1.1.1.1",
    "remote_port": 81,
    "fallback_addr": "1.1.1.1",
    "fallback_port": 443,
    "log_file": "/var/log/trojan-go/trojan-go.log",
    "transport_plugin": {
    "enabled": true,
    "type": "plaintext"
  "password": [
    "endka"
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
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 81 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 81 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

systemctl daemon-reload
systemctl enable trojan-go.service
systemctl start trojan-go.service
