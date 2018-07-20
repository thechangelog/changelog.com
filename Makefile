SHELL := bash# we want bash behaviour in all shell invocations

RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)

PLATFORM := $(shell uname)
ifneq ($(PLATFORM),Darwin)
  $(error $(BOLD)$(RED)Only macOS is currently supported$(NORMAL), please contribute support for your OS)
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

build: compose ## Build changelog.com Docker images (b)
	@$(COMPOSE) build
b: build

code: build run ## Code for changelog.com - builds all Docker images and runs them locally (c)
c: code

help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN { FS = "[:#]" } ; { printf "\033[36m%-10s\033[0m %s\n", $$1, $$4 }' | sort

run: compose ## Run changelog.com locally (r)
	@$(COMPOSE) up
r: run

db: compose ## Resets database with seed data
	@read -rp "The database will be re-created with seed data, $(RED)$(BOLD)all existing data will be lost$(NORMAL). Do you want to continue? (y|n) " -n 1 SEED_DB; echo; \
	if [[ $$SEED_DB =~ ^[Yy] ]]; \
	then \
	  $(COMPOSE) run app mix run priv/repo/seeds.exs; \
	else \
	  echo "Database was not re-created with seed data"; \
	fi

proxy: docker ## Builds & publishes thechangelog/proxy image
	@cd nginx && export BUILD_VERSION=$$(date +'%Y-%m-%d') ; \
	$(DOCKER) build -t thechangelog/proxy:$$BUILD_VERSION . && \
	$(DOCKER) push thechangelog/proxy:$$BUILD_VERSION && \
	$(DOCKER) tag thechangelog/proxy:$$BUILD_VERSION thechangelog/proxy:latest && \
	$(DOCKER) push thechangelog/proxy:latest
