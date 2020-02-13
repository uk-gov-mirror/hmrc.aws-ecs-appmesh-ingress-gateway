
# aws-ecs-appmesh-ingress-gateway

Builds an nginx docker image to use as a sidecar that acts as a proxy to enable us to use appmesh on the MDTP platform.
It is built from the Nginx Alpine Docker image in order to minimise it's footprint.
https://hub.docker.com/_/nginx

### Notes

* Currently using the per zone MDTP wildcard certs, passed as environment variables
* Uses Packer Docker builder to build the image
* `nginx_bootstrap.sh` is copied to the image and used as the entrypoint; it updates the app port, copies the certs and starts Nginx
* Nginx listens on 8443 and proxies to a port passed as the environment variable APPLICATION_PORT
* Nginx allows access to /ping/ping from all to allow LB health checks
* Uses envoy as a sidecar

### Building and Testing

* Uses dgoss/goss to test the image https://github.com/aelsabbahy/goss/tree/master/extras/dgoss
* dgoss/goss can be installed using `make install_dgoss_linux` or `make install_dgoss_osx` for local testing
* There is a Makefile that controls the build of the container image; run using `make build`
* The Makefile generates a semver for the image to be built using `version-incrementor`
* Packer tags the images with this semver and `latest`
* The goss tests are run using `make test`. dgoss must be installed for this to succeed.
* The image and tags are pushed to the artifactory docker repository using `make push_image`. This requires artifactory credentials as ENVs `ARTIFACTORY_USERNAME` and `ARTIFACTORY_PASSWORD`

### TBD

* Jenkins Pipeline
