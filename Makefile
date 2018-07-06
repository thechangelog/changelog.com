SHELL := bash# we want bash behaviour in all shell invocations

RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)

PLATFORM := $(shell uname)
ifneq ($(PLATFORM),Darwin)
  $(error $(BOLD)$(RED)Only OS X is currently supported$(NORMAL), please contribute support for your OS)
endif

ifneq (4,$(firstword $(sort $(MAKE_VERSION) 4)))
  $(error $(BOLD)$(RED)GNU Make v4 or above is required$(NORMAL), please install with $(BOLD)brew install gmake$(NORMAL) and use $(BOLD)gmake$(NORMAL) instead of make)
endif

export LC_ALL := en_US.UTF-8
export LANG := en_US.UTF-8

### VARS ###
#

### DEPS ###
#
CASK := brew cask

DOCKER := /usr/local/bin/docker
docker: deps

COMPOSE := $(DOCKER)-compose
compose: $(DOCKER)

deps:
	@$(CASK) install docker

upgrade: ## Upgrade all dependencies (up)
	@($(CASK) outdated docker || $(CASK) upgrade docker)
up: upgrade

### TARGETS ###
#
.DEFAULT_GOAL := help

help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN { FS = "[:#]" } ; { printf "\033[36m%-10s\033[0m %s\n", $$1, $$4 }' | sort

build: compose
	@$(COMPOSE) build

run: compose
	@$(COMPOSE) up

dev: build compose run ## Run changelog.com locally and make it better (d)
d: dev
