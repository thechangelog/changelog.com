SHELL := bash# we want bash behaviour in all shell invocations

RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)

PLATFORM := $(shell uname)
ifneq ($(PLATFORM),Darwin)
ifneq ($(PLATFORM),Linux)
  $(warning $(RED)$(PLATFORM) is not supported$(NORMAL), only macOS and Linux are supported.)
  $(error $(BOLD)Please contribute support for your platform.$(NORMAL))
endif
endif

ifneq (4,$(firstword $(sort $(MAKE_VERSION) 4)))
  $(warning $(BOLD)$(RED)GNU Make v4 or newer is required$(NORMAL))
ifeq ($(PLATFORM),Darwin)
  $(info On macOS it can be installed with $(BOLD)brew install make$(NORMAL) and run as $(BOLD)gmake$(NORMAL))
endif
  $(error Please run with GNU Make v4 or newer)
endif

### VARS ###
#
export LC_ALL := en_US.UTF-8
export LANG := en_US.UTF-8

### DEPS ###
#
CURL := /usr/bin/curl

ifeq ($(PLATFORM),Darwin)
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

JQ := /usr/local/bin/jq
$(JQ):
	@brew install jq
endif

ifeq ($(PLATFORM),Linux)
DOCKER := /usr/bin/docker
$(DOCKER):
	$(error $(RED)Please install $(BOLD)docker$(NORMAL))

COMPOSE := $(DOCKER)-compose
$(COMPOSE):
	$(error $(RED)Please install $(BOLD)docker-compose$(NORMAL))

$(CURL):
	$(error $(RED)Please install $(BOLD)curl$(NORMAL))

JQ := /usr/bin/jq
$(JQ):
	$(error $(RED)Please install $(BOLD)jq$(NORMAL))
endif

### TARGETS ###
#
.DEFAULT_GOAL := help

.PHONY: build
build: $(COMPOSE) ## Re-build changelog.com app container
	@$(COMPOSE) build

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:+.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN { FS = "[:#]" } ; { printf "\033[36m%-12s\033[0m %s\n", $$1, $$4 }' | sort

.PHONY: contrib
contrib: $(COMPOSE) ## Contribute to changelog.com by running a local copy (c)
	@bash -c "trap '$(COMPOSE) down' INT; \
	  $(COMPOSE) up; \
	  [[ $$? =~ 0|2 ]] || \
	    ( echo 'You might want to run $(BOLD)make build contrib$(NORMAL) if app dependencies have changed' && exit 1 )"
.PHONY: c
c: contrib

.PHONY: proxy
proxy: $(DOCKER) ## Builds & publishes thechangelog/proxy image
	@cd nginx && export BUILD_VERSION=$$(date +'%Y-%m-%d') ; \
	$(DOCKER) build -t thechangelog/proxy:$$BUILD_VERSION . && \
	$(DOCKER) push thechangelog/proxy:$$BUILD_VERSION && \
	$(DOCKER) tag thechangelog/proxy:$$BUILD_VERSION thechangelog/proxy:latest && \
	$(DOCKER) push thechangelog/proxy:latest

.PHONY: md
md: $(DOCKER) ## Preview Markdown locally, as it will appear on GitHub
	@$(DOCKER) run --interactive --tty --rm --name changelog_md \
	  --volume $(CURDIR):/data \
	  --volume $(HOME)/.grip:/.grip \
	  --expose 5000 --publish 5000:5000 \
	  mbentley/grip --context=. 0.0.0.0:5000

.PHONY: list-secrets
list-secrets: $(CURL)  ## List secrets stored in CircleCI (lss)
ifndef CIRCLE_TOKEN
	@echo "$(RED)CIRCLE_TOKEN$(NORMAL) environment variable must be set" && \
	echo "Learn more about CircleCI API tokens $(BOLD)https://circleci.com/docs/2.0/managing-api-tokens/$(NORMAL) " && \
	echo "We like $(BOLD)https://direnv.net/$(NORMAL) to manage environment variables, but you do what works for you" && \
	echo "A good place to store personal environment variables for Changelog is $(BOLD)../.envrc$(NORMAL)" && \
	exit 1
endif
	@$(CURL) --silent --fail "https://circleci.com/api/v1.1/project/github/thechangelog/changelog.com/envvar?circle-token=$(CIRCLE_TOKEN)" | $(JQ) "."
.PHONY: lss
lss: list-secrets
