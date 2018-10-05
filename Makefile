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

### VARS ###
#
export LC_ALL := en_US.UTF-8
export LANG := en_US.UTF-8


### DEPS ###
#
CASK := brew cask

DOCKER := /usr/local/bin/docker
$(DOCKER):
	@$(CASK) install docker

COMPOSE := $(DOCKER)-compose
$(COMPOSE):
	@[ -f $(COMPOSE) ] || (\
	  echo "Please install Docker via $(BOLD)brew cask docker$(NORMAL) so that $(BOLD)docker-compose$(NORMAL) will be managed in lock-step with Docker" && \
	  exit 1 \
	)

### TARGETS ###
#
.DEFAULT_GOAL := help

.PHONY: build
build: $(COMPOSE) ## Build changelog.com Docker images (b)
	@$(COMPOSE) build
.PHONY: b
b: build

.PHONY: code
code: build run ## Code for changelog.com - builds all Docker images and runs them locally (c)
.PHONY: c
c: code

.PHONY: help
help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN { FS = "[:#]" } ; { printf "\033[36m%-10s\033[0m %s\n", $$1, $$4 }' | sort

.PHONY: run
run: $(COMPOSE) ## Run changelog.com locally (r)
	@$(COMPOSE) up
.PHONY: r
r: run

.PHONY: db
db: $(COMPOSE) ## Resets database with seed data
	@read -rp "The database will be re-created with seed data, $(RED)$(BOLD)all existing data will be lost$(NORMAL). Do you want to continue? (y|n) " -n 1 SEED_DB; echo; \
	if [[ $$SEED_DB =~ ^[Yy] ]]; \
	then \
	  $(COMPOSE) run app mix run priv/repo/seeds.exs; \
	else \
	  echo "Database was not re-created with seed data"; \
	fi

.PHONY: proxy
proxy: $(DOCKER) ## Builds & publishes thechangelog/proxy image
	@cd nginx && export BUILD_VERSION=$$(date +'%Y-%m-%d') ; \
	$(DOCKER) build -t thechangelog/proxy:$$BUILD_VERSION . && \
	$(DOCKER) push thechangelog/proxy:$$BUILD_VERSION && \
	$(DOCKER) tag thechangelog/proxy:$$BUILD_VERSION thechangelog/proxy:latest && \
	$(DOCKER) push thechangelog/proxy:latest

.PHONY: md
md: $(DOCKER) ## Preview Markdown locally, as it will appear on GitHub (m)
	@$(DOCKER) run --interactive --tty --rm --name changelog_md \
	  --volume $(CURDIR):/data \
	  --volume $(HOME)/.grip:/.grip \
	  --expose 5000 --publish 5000:5000 \
	  mbentley/grip --context=. 0.0.0.0:5000
.PHONY: m
m: md
