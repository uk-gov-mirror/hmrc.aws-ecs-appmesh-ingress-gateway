SHELL := /usr/bin/env bash
PYTHON_VERSION := $(shell cat .python-version)
DOCKER_OK := $(shell type -P docker)

.PHONY: check_docker build authenticate_to_artifactory push_image prep_version_incrementor clean help compose
.DEFAULT_GOAL := help

check_docker:
    ifeq ('$(DOCKER_OK)','')
	    $(error package 'docker' not found!)
    endif

build: check_docker prep_version_incrementor ## Build the docker image
	@echo '********** Building docker image ************'
	@prepare-release
	@docker build --no-cache --tag artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:$$(cat .version) containers/igw

authenticate_to_artifactory:
	@docker login --username ${ARTIFACTORY_USERNAME} --password "${ARTIFACTORY_PASSWORD}" artefacts.tax.service.gov.uk

push_image: ## Push the docker image to artifactory
	@docker push artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:$$(cat .version)
	@cut-release

push_latest: ## Push the latest tag to artifactory
	@docker tag artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:$$(cat .version) artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:latest
	@docker push artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:latest

prep_version_incrementor:
	@echo "Installing version-incrementor"
	@pip install -i https://artefacts.tax.service.gov.uk/artifactory/api/pypi/pips/simple 'version-incrementor<2.0.0'

clean: ## Remove the docker image
	@echo '********** Cleaning up ************'
	@docker rmi -f $$(docker images artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:$$(cat .version) -q)

run_integration_tests: ## Run Integration Tests
	@./batect integration-test

run_locust: ## Run Locust UI
	@./batect performance-test

test: run_integration_tests ## Alias for run_integration_tests

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
