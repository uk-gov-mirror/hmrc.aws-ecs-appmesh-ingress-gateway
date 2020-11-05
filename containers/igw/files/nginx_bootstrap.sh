#!/bin/sh

if [ -n "${NGINX_DEBUG+x}" ]; then
  set -x
fi
set -e

MAIN_CONFIG_FILE="/etc/nginx/nginx.conf"
# Workers
sed -i -e "s/_WORKER_PROCESSES/${WORKER_PROCESSES:-"1"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_WORKER_RLIMIT_NOFILE/${WORKER_RLIMIT_NOFILE:-"65535"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_WORKER_CONNECTIONS/${WORKER_CONNECTIONS:-"1024"}/" "${MAIN_CONFIG_FILE}"

# TCP
sed -i -e "s/_SENDFILE/${SENDFILE:-"on"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_TCP_NOPUSH/${TCP_NOPUSH:-"on"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_TCP_NODELAY/${TCP_NODELAY:-"on"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_KEEPALIVE_REQUESTS/${KEEPALIVE_REQUESTS:-"100"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_KEEPALIVE_TIMEOUT/${KEEPALIVE_TIMEOUT:-"65"}/" "${MAIN_CONFIG_FILE}"

# GZip
sed -i -e "s/_GZIP_MIN_LENGTH/${GZIP_MIN_LENGTH:-"20"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_GZIP_TYPES/${GZIP_TYPES:-"text\/plain application\/xml"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_GZIP/${GZIP:-"off"}/" "${MAIN_CONFIG_FILE}"

# Logs
sed -i -e "s/_BUFFER/${BUFFER:-"64k"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_FLUSH/${FLUSH:-"10s"}/" "${MAIN_CONFIG_FILE}"

if [ -n "${NGINX_DEBUG+x}" ]; then
  echo "Main config file: ${MAIN_CONFIG_FILE} content:"
  cat ${MAIN_CONFIG_FILE}
fi

APPLICATION_CONFIG_FILE="/etc/nginx/conf.d/app_nginx.conf"
# 10.10.10.10 is a fairly arbitrary default host.
# We use it as we know that traffic sent to it will get caught
# by the AppMesh iptables rules, unless APPLICATION_PORT is specifically
# configured as one of the egress ignored ports.
DEFAULT_APPLICATION_ENDPOINT="${APPLICATION_HOST:-"10.10.10.10"}:${APPLICATION_PORT:-"10001"}"
sed -i -e "s/_APPLICATION_ENDPOINT/${APPLICATION_ENDPOINT:-${DEFAULT_APPLICATION_ENDPOINT}}/" "${APPLICATION_CONFIG_FILE}"
sed -i -e "s/_UPSTREAM_KEEPALIVE_CONNECTIONS/${UPSTREAM_KEEPALIVE_CONNECTIONS:-"8"}/" "${APPLICATION_CONFIG_FILE}"

# Logs
sed -i -e "s/_BUFFER/${BUFFER:-"64k"}/" "${APPLICATION_CONFIG_FILE}"
sed -i -e "s/_FLUSH/${FLUSH:-"10s"}/" "${APPLICATION_CONFIG_FILE}"

if [ -n "${NGINX_DEBUG+x}" ]; then
  echo "Application config file: ${APPLICATION_CONFIG_FILE} content:"
  cat ${APPLICATION_CONFIG_FILE}
fi

nginx -g "daemon off;"
