#!/bin/bash

Vless_Path="/s233"
Vless_UUID="5c301bb8-6c77-41a0-a606-4ba11bbab084"

Vmess_Path="/s244"
Vmess_UUID="5c301bb8-6c77-41a0-a606-4ba11bbab084"

Share_Path="/share233"


mkdir /xraybin
cd /xraybin
wget --no-check-certificate "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" 
unzip Xray-linux-64.zip
rm -f Xray-linux-64.zip
chmod +x ./xray

cd /wwwroot
tar xvf wwwroot.tar.gz
rm -rf wwwroot.tar.gz


sed -e "/^#/d"\
    -e "s/\${Vless_UUID}/${Vless_UUID}/g"\
    -e "s|\${Vless_Path}|${Vless_Path}|g"\
    -e "s/\${Vmess_UUID}/${Vmess_UUID}/g"\
    -e "s|\${Vmess_Path}|${Vmess_Path}|g"\
    /conf/Xray.template.json >  /xraybin/config.json
echo /xraybin/config.json
cat /xraybin/config.json

s="s/proxy_pass/#proxy_pass/g"

sed -e "/^#/d"\
    -e "s/\${PORT}/${PORT}/g"\
    -e "s|\${Vless_Path}|${Vless_Path}|g"\
    -e "s|\${Vmess_Path}|${Vmess_Path}|g"\
    -e "s|\${Share_Path}|${Share_Path}|g"\
    -e "$s"\
    /conf/nginx.template.conf > /etc/nginx/conf.d/ray.conf
echo /etc/nginx/conf.d/ray.conf
cat /etc/nginx/conf.d/ray.conf

[ ! -d /wwwroot/${Share_Path} ] && mkdir -p /wwwroot/${Share_Path}
sed -e "/^#/d"\
    -e "s|\${_Vless_Path}|${Vless_Path}|g"\
    -e "s|\${_Vmess_Path}|${Vmess_Path}|g"\
    -e "s/\${_Vless_UUID}/${Vless_UUID}/g"\
    -e "s/\${_Vmess_UUID}/${Vmess_UUID}/g"\
    -e "$s"\
    /conf/share.html > /wwwroot/${Share_Path}/index.html
echo /wwwroot/${Share_Path}/index.html
cat /wwwroot/${Share_Path}/index.html

cd /xraybin
./xray run -c ./config.json &
rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
