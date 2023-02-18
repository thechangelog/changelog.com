SHELL := bash# we want bash behaviour in all shell invocations
PLATFORM := $(shell uname)
platform = $(shell echo $(PLATFORM) | tr A-Z a-z)
MAKEFILE := $(firstword $(MAKEFILE_LIST))

# https://linux.101hacks.com/ps1-examples/prompt-color-using-tput/
RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)

ifneq (4,$(firstword $(sort $(MAKE_VERSION) 4)))
  $(warning $(BOLD)$(RED)GNU Make v4 or newer is required$(NORMAL))
  $(info On macOS it can be installed with $(BOLD)brew install make$(NORMAL) and run as $(BOLD)gmake$(NORMAL))
  $(error Please run with GNU Make v4 or newer)
endif



### VARS ###
#
# https://tools.ietf.org/html/rfc3339 format - s/:/./g so that Docker tag is valid
export BUILD_VERSION := $(shell date -u +'%Y-%m-%dT%H.%M.%SZ')

HOSTNAME ?= changelog-2022-03-13.fly.dev

GIT_REPOSITORY ?= https://github.com/thechangelog/changelog.com
GIT_SHA ?= $(shell git rev-parse HEAD)
GIT_BRANCH ?= master

LOCAL_BIN := $(CURDIR)/bin
$(LOCAL_BIN):
	mkdir -p $@

PATH := $(LOCAL_BIN):$(PATH)
export PATH

ifeq ($(PLATFORM),Darwin)
OPEN := open
else
OPEN := xdg-open
endif

XDG_CONFIG_HOME := $(CURDIR)/.config
export XDG_CONFIG_HOME



### DEPS ###
#
ifeq ($(PLATFORM),Darwin)
DOCKER ?= /usr/local/bin/docker
$(DOCKER):
	brew cask install docker \
	&& open -a Docker
endif
ifeq ($(PLATFORM),Linux)
DOCKER ?= /usr/bin/docker
$(DOCKER): $(CURL)
	@sudo apt-get update && \
	sudo apt-get install apt-transport-https gnupg-agent && \
	$(CURL) -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
	APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key finger | \
	  grep --quiet "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88" && \
	echo "deb https://download.docker.com/linux/ubuntu $$(lsb_release -c -s) stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list && \
	sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io && \
	sudo adduser $$USER docker && newgrp docker && sudo service restart docker
endif

CURL ?= /usr/bin/curl
ifeq ($(PLATFORM),Linux)
$(CURL):
	@sudo apt-get update && sudo apt-get install curl
endif



### TARGETS ###
#
.DEFAULT_GOAL := help

colours:
	@echo "$(BOLD)BOLD $(RED)RED $(GREEN)GREEN $(YELLOW)YELLOW $(NORMAL)"

.PHONY: help
help:
	@awk -F"[:#]" '/^[^\.][a-zA-Z\._\-]+:+.+##.+$$/ { printf "\033[36m%-24s\033[0m %s\n", $$1, $$4 }' $(MAKEFILE_LIST) \
	| sort
# Continuous Feedback for the help target - run in a split window while iterating on it
.PHONY: CFhelp
CFhelp: $(WATCH)
	@$(WATCH_MAKE_TARGET) help

define VERSION_CHECK
VERSION="$$($(CURL) --silent --location \
  --write-out '$(NORMAL)HTTP/%{http_version} %{http_code} in %{time_total}s' \
  http://$(HOSTNAME)/static/version.txt)" && \
echo $(BOLD)$(GIT_COMMIT)$$VERSION @ $$(date)
endef
.PHONY: check-deployed-version
check-deployed-version: GIT_COMMIT = $(GIT_REPOSITORY)/commit/
check-deployed-version: $(CURL) ## cdv | Check the currently deployed git sha
	@$(VERSION_CHECK)
.PHONY: cdv
cdv: check-deployed-version

.PHONY: ssl-report
ssl-report: ## ssl | Run an SSL report via SSL Labs
	@open "https://www.ssllabs.com/ssltest/analyze.html?d=$(HOSTNAME)&latest"
.PHONY: ssl
ssl: ssl-report

.PHONY: runtime-image
runtime-image: build-runtime-image publish-runtime-image
.PHONY: ri
ri: runtime-image

.PHONY: build-runtime-image
build-runtime-image: $(DOCKER) ## bri | Build runtime container image
	@$(DOCKER) build --progress plain --no-cache \
		--tag thechangelog/runtime:$(BUILD_VERSION) \
		--tag thechangelog/runtime:latest \
		--file docker/runtime.Dockerfile .
.PHONY: bri
bri: build-runtime-image

.PHONY: publish-runtime-image
publish-runtime-image: $(DOCKER)
	$(DOCKER) push thechangelog/runtime:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/runtime:latest
