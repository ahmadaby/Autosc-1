#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
IZIN=$( curl http://akses.endka.ga:81/aksesku | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permission Accepted${NC}"
else
echo -e "${red}Permission Denied!${NC}";
echo "Only For Premium Users"
exit 0
fi
clear
uuid=$(cat /proc/sys/kernel/random/uuid)
source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/v2ray/domain)
else
domain=$IP
fi
trojango="$(cat ~/log-install.txt | grep -i TrojanGO | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
		read -rp "Password : " -e user
		user_EXISTS=$(grep -w $user /etc/trojan-go/akun.conf | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
read -p "Expired (days) : " masaaktif
sed -i '/"'""$uuid""'"$/a\,"'""$user""'"' /etc/trojan-go/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
echo -e "### $user $exp" >> /etc/trojan-go/akun.conf
systemctl restart trojan-go-mini
trojangolink="trojan-go://${uuid}@${domain}:${trojango}/?sni=${domain}&type=ws&host=${domain}&path=/trojango&encryption=none#${user}"
clear
echo -e "---------------TROJAN-GO ACCOUNT-------------"
echo -e "Remarks        = ${user}"
echo -e "IP / Host      = ${domain}"
echo -e "Port           = ${trojango}"
echo -e "Key            = ${user}"
echo -e "Expired        = $exp"
echo -e "-------------------------------------------------------------------"
echo -e "Link TROJAN-GO : ${trojangolink}"
echo -e "-------------------------------------------------------------------"