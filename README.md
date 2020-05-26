
# aws-ecs-appmesh-ingress-gateway

Builds an nginx docker image to use as a sidecar that acts as a proxy to enable us to use appmesh on the MDTP platform.
It is built from the Nginx Alpine Docker image in order to minimise it's footprint.

[Dockerhub Nginx](https://hub.docker.com/_/nginx)

## Notes

* `nginx_bootstrap.sh` is copied to the image and used as the entrypoint; it updates the app port and starts Nginx
* Nginx listens on 10000 and proxies to a port passed as the environment variable APPLICATION_PORT
* Nginx can be healthchecked by Envoy via `/nginx-health`

## Building

* There is a Makefile that controls the build of the container image; run using `make build`
* The Makefile generates a semver for the image to be built using `version-incrementor`
* The image and tags are pushed to the artifactory docker repository using `make push_image`. This requires artifactory credentials as ENVs `ARTIFACTORY_USERNAME` and `ARTIFACTORY_PASSWORD`

## Jenkins Jobs

[PR builder](https://build.tax.service.gov.uk/job/build-and-deploy/job/aws-ecs-appmesh-ingress-gateway-docker-image-pr-builder/)

[Build and publish of Docker image](https://build.tax.service.gov.uk/job/build-and-deploy/job/aws-ecs-appmesh-ingress-gateway-docker-image/)
