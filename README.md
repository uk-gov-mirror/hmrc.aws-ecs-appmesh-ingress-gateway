
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

## Testing

### Integration Tests

Integration tests live in the [tests](./tests) folder. They configure the Ingress Gateway Docker image to proxy requests to a local `httpbin` container. The httpbin responses can then be used to make assertions on the behaviour of nginx.

To run the integration tests execute the `make test` task.

### Performance Tests

Also defined in the [tests](./tests) directory. To start the Locust web dashboard run `make locust_start`, then navigate to [http://0.0.0.0:8089/](http://0.0.0.0:8089/) in a web browser. From there you can start a performance test run.

To tweak the Ingress Gateway configuration for performance tests use the [docker-compose.performance-testing.yaml](./tests/docker-compose.performance-testing.yaml) file. 

## Jenkins Jobs

[PR builder](https://build.tax.service.gov.uk/job/build-and-deploy/job/aws-ecs-appmesh-ingress-gateway-docker-image-pr-builder/)

[Build and publish of Docker image](https://build.tax.service.gov.uk/job/build-and-deploy/job/aws-ecs-appmesh-ingress-gateway-docker-image/)
