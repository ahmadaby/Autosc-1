#!/bin/bash
read -rp "" Login
read -rp "" Pass
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
cat << EOF >> /etc/cron.d/trial
# BEGIN $Login
30 * * * * root printf "$Login" | del-trmnt
# END $Login
EOF
