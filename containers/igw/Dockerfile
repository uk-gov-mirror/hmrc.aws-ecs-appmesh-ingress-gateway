ARG DOCKERHUB=dockerhub.tax.service.gov.uk
FROM ${DOCKERHUB}/nginx:1.19.3

ENV HOSTNAME appmesh-ingress-gateway

EXPOSE 10000

COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/app_nginx.conf /etc/nginx/conf.d/
COPY files/nginx_bootstrap.sh  /usr/local/bin/

RUN chmod 0755 /usr/local/bin/nginx_bootstrap.sh
RUN chmod 0644 /etc/nginx/nginx.conf
RUN chmod 0644 /etc/nginx/conf.d/app_nginx.conf

ENTRYPOINT ["/usr/local/bin/nginx_bootstrap.sh"]
