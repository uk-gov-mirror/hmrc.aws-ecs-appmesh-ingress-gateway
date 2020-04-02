#!/bin/sh

sed -i -e "s/_APP_PORT/${APPLICATION_PORT:-10001}/" /etc/nginx/conf.d/app_nginx.conf

nginx -g "daemon off;"
