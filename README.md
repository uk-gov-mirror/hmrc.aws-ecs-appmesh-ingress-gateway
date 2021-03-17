
# aws-ecs-appmesh-ingress-gateway

Builds an Nginx docker image from the [Nginx Debian Docker image](https://hub.docker.com/_/nginx). The image contains the necessary configuration for it to be used as the "app" container in an Ingress Gateway ECS task, enabling us to ingress traffic to the MDTP AppMesh.

## Notes

* `nginx_bootstrap.sh` is copied to the image and used as the entrypoint; it updates the app port and starts Nginx
* Nginx listens on 10000 and proxies to a port passed as the environment variable APPLICATION_PORT
* Nginx can be healthchecked by Envoy via `/nginx-health`
* Various bits of Nginx configuration can be set at container runtime through the use of environment variables. See [nginx_bootstrap.sh](containers/igw/files/nginx_bootstrap.sh) for details of these.

## Building

* There is a Makefile that controls the build of the container image; run using `make build`
* The Makefile generates a semver for the image to be built using `version-incrementor`
* The image and tags are pushed to the artifactory docker repository using `make push_image`. This requires artifactory credentials as ENVs `ARTIFACTORY_USERNAME` and `ARTIFACTORY_PASSWORD`

## Testing

### Integration Tests

Integration tests live in the [tests](test) directory. They configure the Ingress Gateway Docker image to proxy requests to a local `httpbin` container. The httpbin responses can then be used to make assertions on the behaviour of nginx.

To run the integration tests execute the `make test` task.

### Performance Tests

Also defined in the [tests](test) directory. To start the Locust web dashboard run `make run_locust`, then navigate to http://localhost:8089/ in a web browser. From there you can start a performance test run.

Note: The `host` value is the host as resolved by the `test-runner` Docker container, which is where `locust` is running. The correct value is therefore: http://igw:10000.

To tweak the Ingress Gateway configuration for performance tests use the [docker-compose.performance-testing.yaml](test/docker-compose.performance-testing.yaml) file. 

## Jenkins Jobs

[PR builder](https://build.tax.service.gov.uk/job/build-and-deploy/job/aws-ecs-appmesh-ingress-gateway-docker-image-pr-builder/)

[Build and publish of Docker image](https://build.tax.service.gov.uk/job/build-and-deploy/job/aws-ecs-appmesh-ingress-gateway-docker-image/)

## IntelliJ / PyCharm

Unfortunately there is currently no direct batect support in IntelliJ/ PyCharm. As such it is not possible to configure the `test-runner` container as a remote interpreter. However, it is possible to use the same poetry configuration to create a virtual environment on your local machine, from which you can run tests:

1. Create a virtual environment and populate it with the necessary dependencies:

    cd test/test-runner
    poetry install
    
2. Identify the path of the virtual env
    
    poetry env info -p 
    
3. Configure the Pycharm/ IntelliJ project SDK to use the the interpreter at the above path:
    
    Add Interpreter --> VirtualEnv Environent --> Existing Environment --> Paste VirtualEnv path.

Having done this you should now be able to run/ debug the project's tests within your IDE.

_Note:_ Tests use the `IN_CONTAINER` environment variable to detect if they are running inside or outside the `test-runner` container. This is necessary because the networks and ports are different in each context.

