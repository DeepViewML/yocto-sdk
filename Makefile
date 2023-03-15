SONAR_SCANNER_VERSION ?= 4.8.0.2856
REPO ?= ghcr.io/deepviewml
IMAGE ?= yocto-sdk
MACHINE ?= imx8mpevk
VERSION ?= 5.15.y
TAG ?= $(MACHINE)-$(VERSION)

.PHONY: all build push

all: build

build:
	docker build . \
		-t $(REPO)/$(IMAGE):$(TAG) \
		--build-arg VERSION=$(VERSION) \
		--build-arg MACHINE=$(MACHINE) \
		--build-arg SONAR_SCANNER_VERSION=$(SONAR_SCANNER_VERSION)

push:
	docker push $(REPO)/$(IMAGE):$(TAG)
