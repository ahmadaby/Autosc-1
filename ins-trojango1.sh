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

# Uuid Service
uuid=$(cat /proc/sys/kernel/random/uuid)

# Trojan Go Akun 
mkdir -p /etc/trojan-go/
touch /etc/trojan-go/akun.conf

# Installing Trojan Go
mkdir -p /etc/trojan-go/
chmod 755 /etc/trojan-go/
CHECKVERSION="https://api.github.com/repos/p4gefau1t/trojan-go/releases"
    VERSION=$(curl -H 'Cache-Control: no-cache' -s "$CHECKVERSION" 2> /dev/null| grep 'tag_name' | cut -d\" -f4 | sed 's/v//g' | head -n 1)
    TARBALL="trojan-go-linux-amd64.zip"
    DOWNLOADURL="https://github.com/p4gefau1t/trojan-go/releases/download/v$VERSION/$TARBALL"

    curl -LO --progress-bar "$DOWNLOADURL"
    mkdir -p /etc/trojan-go/
    unzip "$TARBALL"
    if ! [[ -f "$TROJANCONF" ]] || prompt "The server config already exists in $TROJANCONF, overwrite?"; then
        cp "$SERVERJSON" "$TROJANCONF"
        sed -i "s#cert_path#$cert_path#" "$TROJANCONF"
        sed -i "s#key_path#$key_path#" "$TROJANCONF"
        sed -i "s#mysql_server_addr#$mysql_server_addr#" "$TROJANCONF"
        sed -i "s#mysql_database#$mysql_database#" "$TROJANCONF"
        sed -i "s#mysql_password#$mysql_password#" "$TROJANCONF"
        sed -i "s#domain_name#$DB_DOMAIN#" "$TROJANCONF"
    fi
    if [[ -d "$SYSTEMDPREFIX" ]]; then
        cp "$TROJANSERVICE" "$SYSTEMDPATH"
    fi
    install -Dm755 "trojan-go" "/usr/bin/"
    systemctl daemon-reload
wget -O /usr/local/bin/trojan-go https://raw.github.com/Endka22/Autosc/main/trojan-go
wget -O /usr/local/bin/geoip.dat https://raw.githubusercontent.com/Endka22/Autosc/main/geoip.dat
wget -O /usr/local/bin/geosite.dat https://raw.githubusercontent.com/Endka22/Autosc/main/geosite.dat
touch /etc/trojan-go/trojan-go.pid
chmod +x /usr/local/bin/trojan-go

# Service
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

# Config
cat > /etc/trojan-go/config.json <<END
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "log_level": 1,
    "log_file": "/var/log/trojan.log",
    "password": [],
    "ssl": {
        "cert": "cert_path",
        "key": "key_path"
    },
    "mysql": {
      "enabled": true,
      "server_addr": "mysql_server_addr",
      "server_port": 3306,
      "database": "mysql_database",
      "username": "root",
      "password": "mysql_password",
      "check_rate": 60
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
        "enabled": false,
        "path": "/qazxswedcvfr",
        "host": "domain_name"
    },
    "mux": {
        "enabled": true,
        "concurrency": 8,
        "idle_timeout": 60
    }
}

END
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2096 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p udp --dport 2096 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# Starting
systemctl daemon-reload
systemctl enable trojan-go
systemctl start trojan-go
