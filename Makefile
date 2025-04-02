# vowpalwabbit

SHELL := /bin/bash
ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VOWPALWABBIT_VERSION = 9.10.0

DOCKER_NAME    = vowpalwabbit
DOCKER_VERSION = $(VOWPALWABBIT_VERSION)-rev00

# -----------------------------------------------------------------------------
# welcome
# -----------------------------------------------------------------------------

.DEFAULT_GOAL = info

.PHONY: info
info:
	@echo "vowpalwabbit project: $(ROOT)"

# -----------------------------------------------------------------------------
# docker
# -----------------------------------------------------------------------------

.PHONY: docker-prune
docker-prune:
	@docker image prune --force

.PHONY: docker-build
docker-build:
	@docker build \
		--progress=plain \
		--build-arg VOWPALWABBIT_VERSION=$(VOWPALWABBIT_VERSION) \
		-t "${DOCKER_NAME}:${DOCKER_VERSION}" \
		.

.PHONY: docker-pull
docker-pull:
	@docker pull "${DOCKER_NAME}:${DOCKER_VERSION}"

.PHONY: docker-push
docker-push:
	@docker push "${DOCKER_NAME}:${DOCKER_VERSION}"

.PHONY: docker-deploy
docker-deploy: docker-build docker-push

.PHONY: docker-run
docker-run:
	@docker run \
		--name "vowpalwabbit" \
		--hostname="vowpalwabbit" \
		--rm \
		--interactive \
		--tty \
		--env VOWPALWABBIT_VERSION=$(VOWPALWABBIT_VERSION) \
		"${DOCKER_NAME}:${DOCKER_VERSION}"

# -----------------------------------------------------------------------------
# extract
# -----------------------------------------------------------------------------

.PHONY: extract
extract:
	@docker create --name vowpalwabbit_temp "${DOCKER_NAME}:${DOCKER_VERSION}"
	@docker cp "vowpalwabbit_temp:/usr/local/bin/vw" "$(ROOT)/target/vw"
	@docker rm vowpalwabbit_temp
