#!/usr/bin/env bash

if [ -n "${NGINX_DEBUG+x}" ]; then
  set -x
fi
set -e

MAIN_CONFIG_FILE="/etc/nginx/nginx.conf"
# Workers
sed -i -e "s/_WORKER_PROCESSES/${WORKER_PROCESSES:-"1"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_WORKER_CONNECTIONS/${WORKER_CONNECTIONS:-"1024"}/" "${MAIN_CONFIG_FILE}"

# TCP
sed -i -e "s/_SENDFILE/${SENDFILE:-"on"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_TCP_NOPUSH/${TCP_NOPUSH:-"on"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_TCP_NODELAY/${TCP_NODELAY:-"on"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_KEEPALIVE_REQUESTS/${KEEPALIVE_REQUESTS:-"100"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_KEEPALIVE_TIMEOUT/${KEEPALIVE_TIMEOUT:-"65"}/" "${MAIN_CONFIG_FILE}"

# GZip
sed -i -e "s/_GZIP_MIN_LENGTH/${GZIP_MIN_LENGTH:-"20"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_GZIP_TYPES/${GZIP_TYPES:-"text\\/plain application\\/xml"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_GZIP/${GZIP:-"off"}/" "${MAIN_CONFIG_FILE}"

# Logs
sed -i -e "s/_BUFFER/${BUFFER:-"64k"}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_FLUSH/${FLUSH:-"10s"}/" "${MAIN_CONFIG_FILE}"

# Upstreams
# 10.10.10.10 is a fairly arbitrary default host.
# We use it as we know that traffic sent to it will get caught
# by the AppMesh iptables rules, unless APPLICATION_PORT is specifically
# configured as one of the egress ignored ports.
DEFAULT_APPLICATION_ENDPOINT="${APPLICATION_HOST:-"10.10.10.10"}:${APPLICATION_PORT:-"10001"}"
sed -i -e "s/_APPLICATION_ENDPOINT/${APPLICATION_ENDPOINT:-${DEFAULT_APPLICATION_ENDPOINT}}/" "${MAIN_CONFIG_FILE}"
sed -i -e "s/_UPSTREAM_KEEPALIVE_CONNECTIONS/${UPSTREAM_KEEPALIVE_CONNECTIONS:-"8"}/" "${MAIN_CONFIG_FILE}"

if [ -n "${NGINX_DEBUG+x}" ]; then
  echo "Main config file: ${MAIN_CONFIG_FILE} content:"
  cat ${MAIN_CONFIG_FILE}
fi

# Provision each of the individual configuration files from their templates.
NGINX_CONF_DOT_D_DIRECTORY="/etc/nginx/conf.d"
API_PLATFORM_CONFIG_FILE="${NGINX_CONF_DOT_D_DIRECTORY}/api_platform_api_gateway_ingress.conf"
APPLICATION_CONFIG_FILE="${NGINX_CONF_DOT_D_DIRECTORY}/app_nginx.conf"
NGINX_CONFIG_FILES=("${API_PLATFORM_CONFIG_FILE}" "${APPLICATION_CONFIG_FILE}")

for config_file in "${NGINX_CONFIG_FILES[@]}"
do
  # Logs
  sed -i -e "s/_BUFFER/${BUFFER:-"64k"}/" "${config_file}"
  sed -i -e "s/_FLUSH/${FLUSH:-"10s"}/" "${config_file}"

  if [ -n "${NGINX_DEBUG+x}" ]; then
    echo "Application config file: ${config_file} content:"
    cat "${config_file}"
  fi
done

nginx -g "daemon off;"
