#!/bin/sh

# 10.10.10.10 is a fairly arbitrary default host.
# We use it as we know that traffic sent to it will get caught
# by the AppMesh iptables rules, unless APPLICATION_PORT is specifically
# configured as one of the egress ignored ports.
sed -i -e "s/_APP_HOST/${APPLICATION_HOST:-10.10.10.10}/" /etc/nginx/conf.d/app_nginx.conf
sed -i -e "s/_APP_PORT/${APPLICATION_PORT:-10001}/" /etc/nginx/conf.d/app_nginx.conf

nginx -g "daemon off;"
