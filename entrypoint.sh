#!/bin/bash

#Xray版本

if [[ -z "${Vless_Path}" ]]; then
  Vless_Path="/le"
fi
echo ${Vless_Path}

if [[ -z "${Vless_UUID}" ]]; then
  Vless_UUID="bbc709d0-0e3b-492d-b374-93b775bd7295"
fi
echo ${Vless_UUID}

if [[ -z "${Vmess_Path}" ]]; then
  Vmess_Path="/me"
fi
echo ${Vmess_Path}

if [[ -z "${Vmess_UUID}" ]]; then
  Vmess_UUID="bbc709d0-0e3b-492d-b374-93b775bd7295"
fi
echo ${Vmess_UUID}

if [[ -z "${Share_Path}" ]]; then
  Share_Path="/share"
fi
echo ${Share_Path}

cd /wwwroot
tar xvf wwwroot.tar.gz
rm -rf wwwroot.tar.gz


sed -e "/^#/d"\
    -e "s/\${Vless_UUID}/${Vless_UUID}/g"\
    -e "s|\${Vless_Path}|${Vless_Path}|g"\
    -e "s/\${Vmess_UUID}/${Vmess_UUID}/g"\
    -e "s|\${Vmess_Path}|${Vmess_Path}|g"\
    /conf/Xray.template.json >  /etc/config.json
echo /etc/config.json
cat /etc/config.json

if [[ -z "${ProxySite}" ]]; then
  s="s/proxy_pass/#proxy_pass/g"
  echo "site:use local wwwroot html"
else
  s="s|\${ProxySite}|${ProxySite}|g"
  echo "site: ${ProxySite}"
fi

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

/usr/bin/xray run -config /etc/config.json &
rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
