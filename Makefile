SHELL := /usr/bin/env bash
PYTHON_VERSION := $(shell cat .python-version)
DOCKER_OK := $(shell type -P docker)
PACKER_OK := $(shell type -P packer)
DGOSS_OK := $(shell type -P dgoss)
SSL_KEY := $(shell cat test_certs/fake_64.key)
SSL_CERT := $(shell cat test_certs/fake_64.cert)

install_dgoss_linux:
    ifeq ('$(DGOSS_OK)','')
		# Install latest version to /usr/local/bin
		curl -fsSL https://goss.rocks/install | sh
	else
	@echo 'dgoss already installed'
    endif

install_dgoss_osx:
    ifeq ('$(DGOSS_OK)','')
		# Install dgoss
		curl -L https://raw.githubusercontent.com/aelsabbahy/goss/master/extras/dgoss/dgoss -o /usr/local/bin/dgoss
		chmod +rx /usr/local/bin/dgoss
		# Download goss to your preferred location
		curl -L https://github.com/aelsabbahy/goss/releases/download/v0.3.6/goss-linux-amd64 -o ~/Downloads/goss-linux-amd64
		# Set your GOSS_PATH to the above location
		export GOSS_PATH=~/Downloads/goss-linux-amd64
	@echo 'You may want to add "export GOSS_PATH=~/Downloads/goss-linux-amd64" to your profile and/or move the binary'
    else
	@echo 'dgoss already installed'
    endif

check_docker:
    ifeq ('$(DOCKER_OK)','')
	    $(error package 'docker' not found!)
    endif

check_packer:
    ifeq ('$(PACKER_OK)','')
	    $(error package 'packer' not found!)
    endif

check_dgoss:
    ifeq ('$(DGOSS_OK)','')
	    $(error package 'dgoss' not found!)
    endif

build: check_dgoss check_packer check_docker prep_version_incrementor
	@echo '********** Building docker image ************'
	@pipenv run prepare-release
	@umask 0022
	@packer build --var image_version=$$(cat .version) proxy_packer.json

test:
	@echo '********** Running tests ************'
	dgoss run -d --env "APPLICATION_PORT=8080" --env SSL_CERT=$(SSL_CERT) --env SSL_KEY=$(SSL_KEY) artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:latest

authenticate_to_artifactory:
	@docker login --username ${ARTIFACTORY_USERNAME} --password "${ARTIFACTORY_PASSWORD}"  artefacts.tax.service.gov.uk

push_image: authenticate_to_artifactory
	@docker push artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:$$(cat .version)
	@pipenv run cut-release
	@docker push artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:latest

prep_version_incrementor:
	@echo "Renaming requirements to prevent pipenv trying to convert it"
	@echo "Installing version-incrementor with pipenv"
	@pip install pipenv --upgrade
	@pipenv --python $(PYTHON_VERSION)
	@pipenv run pip install -i https://artefacts.tax.service.gov.uk/artifactory/api/pypi/pips/simple version-incrementor==0.2.0

clean:
	@echo '********** Cleaning up ************'
	@docker rmi -f $$(docker images artefacts.tax.service.gov.uk/aws-ecs-appmesh-ingress-gateway:latest -q)

all: build test clean
