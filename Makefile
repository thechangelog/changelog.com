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

STACK_VERSION ?= 202201
HOSTNAME ?= 21.changelog.com

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
COMPOSE ?= $(DOCKER)-compose
$(DOCKER) $(COMPOSE):
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
COMPOSE ?= /usr/local/bin/docker-compose
$(COMPOSE):
	@sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose && \
	sudo chmod a+x /usr/local/bin/docker-compose
endif

CURL ?= /usr/bin/curl
ifeq ($(PLATFORM),Linux)
$(CURL):
	@sudo apt-get update && sudo apt-get install curl
endif

ifeq ($(PLATFORM),Darwin)
JQ := /usr/local/bin/jq
$(JQ):
	@brew install jq
endif
ifeq ($(PLATFORM),Linux)
JQ ?= /snap/bin/jq
$(JQ):
	@sudo snap install jq
endif

ifeq ($(PLATFORM),Darwin)
LPASS := /usr/local/bin/lpass
$(LPASS):
	@brew install lastpass-cli
endif
ifeq ($(PLATFORM),Linux)
LPASS := /usr/bin/lpass
$(LPASS):
	@sudo apt-get update && sudo apt-get install lastpass-cli
endif

ifeq ($(PLATFORM),Darwin)
WATCH := /usr/local/bin/watch
$(WATCH):
	@brew install watch
endif
ifeq ($(PLATFORM),Linux)
WATCH := /usr/bin/watch
endif
WATCH_MAKE_TARGET = $(WATCH) --color $(MAKE) --makefile $(MAKEFILE) --no-print-directory

SECRETS := mkdir -p $(XDG_CONFIG_HOME)/.config && $(LPASS) ls "Shared-changelog/secrets"

ifeq ($(PLATFORM),Darwin)
AWS := /usr/local/bin/aws
$(AWS):
	@brew install awscli
endif
ifeq ($(PLATFORM),Linux)
AWS := /usr/bin/aws
$(AWS):
	$(error $(RED)Please install $(BOLD)AWS CLI v2$(NORMAL): https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
endif



### TARGETS ###
#
.DEFAULT_GOAL := help

colours:
	@echo "$(BOLD)BOLD $(RED)RED $(GREEN)GREEN $(YELLOW)YELLOW $(NORMAL)"

define MAKE_TARGETS
  awk -F: '/^[^\.%\t][a-zA-Z\._\-]*:+.*$$/ { printf "%s\n", $$1 }' $(MAKEFILE_LIST)
endef
define BASH_AUTOCOMPLETE
  complete -W \"$$($(MAKE_TARGETS) | sort | uniq)\" make gmake m
endef
.PHONY: autocomplete
autocomplete: ## ac  | Configure shell autocomplete - eval "$(make autocomplete)"
	@echo "$(BASH_AUTOCOMPLETE)"
.PHONY: ac
ac: autocomplete
# Continuous Feedback for the ac target - run in a split window while iterating on it
.PHONY: CFac
CFac: $(WATCH)
	@$(WATCH_MAKE_TARGET) ac

.PHONY: create-dirs-mounted-as-volumes
create-dirs-mounted-as-volumes:
	@mkdir -p $(CURDIR)/priv/{uploads,db}

.PHONY: help
help:
	@awk -F"[:#]" '/^[^\.][a-zA-Z\._\-]+:+.+##.+$$/ { printf "\033[36m%-24s\033[0m %s\n", $$1, $$4 }' $(MAKEFILE_LIST) \
	| sort
# Continuous Feedback for the help target - run in a split window while iterating on it
.PHONY: CFhelp
CFhelp: $(WATCH)
	@$(WATCH_MAKE_TARGET) help

.PHONY: contrib
contrib: $(COMPOSE) create-dirs-mounted-as-volumes ## c   | Contribute to changelog.com by running a local copy
	@bash -c "trap '$(COMPOSE) down' INT ; \
	  $(COMPOSE) up ; \
	  [[ $$? =~ 0|2 ]] || \
	    ( echo 'You might want to run $(BOLD)make clean contrib$(NORMAL) if app dependencies have changed' && exit 1 )"
.PHONY: c
c: contrib

.PHONY: clean
clean:
	@rm -fr deps _build assets/node_modules

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

priv/db:
	@mkdir -p priv/db

.PHONY: preview-readme
preview-readme: $(DOCKER) ## pre | Preview README & live reload on edit
	@$(DOCKER) run --interactive --tty --rm --name changelog_md \
	  --volume $(CURDIR):/data \
	  --volume $(HOME)/.grip:/.grip \
	  --expose 5000 --publish 5000:5000 \
	  mbentley/grip --context=. 0.0.0.0:5000
.PHONY: pre
pre: preview-readme

.PHONY: test
test: $(COMPOSE) ## t   | Run tests as they run on CircleCI
	@$(COMPOSE) run --rm -e MIX_ENV=test -e DB_NAME=changelog_test app mix test
.PHONY: t
t: test

test_flakes:
	@mkdir -p test_flakes

TEST_RUNS ?= 10
.PHONY: find-flaky-tests
find-flaky-tests: test_flakes
	@for TEST_RUN_NO in {1..$(TEST_RUNS)}; do \
	  echo "RUNNING TEST $$TEST_RUN_NO ... " ; \
	  ($(MAKE) --no-print-directory test >> test_flakes/$$TEST_RUN_NO && \
	    rm test_flakes/$$TEST_RUN_NO && \
	    echo -e "$(GREEN)PASS$(NORMAL)\n") || \
	  echo -e "$(RED)FAIL$(NORMAL)\n"; \
	done

.PHONY: ssl-report
ssl-report: ## ssl | Run an SSL report via SSL Labs
	@open "https://www.ssllabs.com/ssltest/analyze.html?d=$(HOSTNAME)&latest"
.PHONY: ssl
ssl: ssl-report

.PHONY: on-app-start
on-app-start: sentry-release

.PHONY: sentry-release
sentry-release: | $(CURL)
	@$(CURL) --silent --fail --request POST --url https://sentry.io/api/0/organizations/changelog-media/releases/ \
        	--header 'Authorization: Bearer $(SENTRY_AUTH_TOKEN)' \
         	--header 'Content-type: application/json' \
         	--data '{"version":"$(APP_VERSION)","ref":"$(GIT_SHA)","url":"$(GIT_REPOSITORY)/commit/$(GIT_SHA)","projects":["changelog-com"]}'

.PHONY: backups-image
backups-image: build-backups-image publish-backups-image
.PHONY: bi
bi: backups-image

.PHONY: build-backups-image
build-backups-image: $(DOCKER)
	@cd docker && \
	$(DOCKER) build --progress plain \
	  --tag thechangelog/backups:$(BUILD_VERSION) \
	  --tag thechangelog/backups:$(STACK_VERSION) \
	  --file Dockerfile.backups .
.PHONY: bbi
bbi: build-backups-image

.PHONY: publish-backups-image
publish-backups-image: $(DOCKER)
	@$(DOCKER) push thechangelog/backups:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/backups:$(STACK_VERSION)

.PHONY: runtime-image
runtime-image: build-runtime-image publish-runtime-image
.PHONY: ri
ri: runtime-image

.PHONY: build-runtime-image
build-runtime-image: $(DOCKER)
	@$(DOCKER) build --progress plain --no-cache \
		--tag thechangelog/runtime:$(BUILD_VERSION) \
		--tag thechangelog/runtime:$(STACK_VERSION) \
		--tag thechangelog/runtime:latest \
		--file docker/Dockerfile.runtime .
.PHONY: bri
bri: build-runtime-image

.PHONY: publish-runtime-image
publish-runtime-image: $(DOCKER)
	$(DOCKER) push thechangelog/runtime:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/runtime:$(STACK_VERSION) && \
	$(DOCKER) push thechangelog/runtime:latest

APP_VERSION ?= $(shell date -u +'%y.%-m.%-d')
export APP_VERSION

.PHONY: dev
dev:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
	cd assets && yarn install
	mix do ecto.create, ecto.migrate, phx.server

.PHONY: format
format:
	mix format
	MIX_ENV=test mix test

PG_MAJOR ?= 12
PG_INSTALL ?= /usr/local/opt/postgresql@$(PG_MAJOR)
PG_DIR ?= $(CURDIR)/tmp/postgres@$(PG_MAJOR)

$(PG_INSTALL):
	brew install postgresql@$(PG_MAJOR)

$(PG_DIR):
	$(PG_INSTALL)/bin/pg_ctl -D $(PG_DIR) init

db-ctl-%: $(PG_INSTALL) $(PG_DIR)
	$(PG_INSTALL)/bin/pg_ctl $(*) -D $(PG_DIR)
