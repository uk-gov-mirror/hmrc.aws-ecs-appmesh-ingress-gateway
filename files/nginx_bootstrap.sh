#!/bin/sh

sed -ie "s/_APPLICATION_PORT/9901/" /etc/nginx/conf.d/app_nginx.conf

echo $SSL_CERT|base64 -d > /etc/ssl/certs/mdtp.pem
echo $SSL_KEY|base64 -d > /etc/ssl/private/mdtp.key

nginx -g "daemon off;"
