#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ifconfig.me/ip);
echo "Checking VPS"
IZIN=$( curl http://akses.endka.ga:81/aksesku | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permission Accepted...${NC}"
else
echo -e "${red}Permission Denied!${NC}";
echo "Only For Premium Users"
exit 0
fi
clear
cd /root
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install nodejs -y
apt install npm -y
npm install
apt install tmux -y
wget https://github.com/Endka22/Autosc/raw/main/oh.zip
unzip oh.zip


rm -f /oh.zip



"echo" Ketik Perintah node server
"echo" Buat Bot Di Bot Father
"echo" Masukan Token Bot Anda
"echo" Kembali Ke vps Ketik y
"echo" Ketik tmux Ketik Perintah node server
"echo" Ketik ctrl b  d