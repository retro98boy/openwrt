ROOT_DIR := $(shell pwd)
NPROC := $(shell nproc)

DOCKER := docker
DOCKER_IMAGE := retro98boy/openwrt-dev
DOCKER_IMAGE_TAG := latest

define DOCKER_RUN
	$(DOCKER) run -it --init --rm \
	-v $(ROOT_DIR):/workspace \
	-u 1000:1000 \
	$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG)
endef

%:
	@$(DOCKER_RUN) $*
