SHELL := bash# we want bash behaviour in all shell invocations

PLATFORM := $(shell uname)
platform := $(shell echo $(PLATFORM) | tr A-Z a-z)
ifeq ($(PLATFORM),Darwin)
platform_alt := macOS
else
platform_alt := $(platform)
endif

architecture := $(shell uname -m)
ifeq ($(architecture),x86_64)
architecture_alt := amd64
else
architecture_alt := $(architecture)
endif

# https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
RED := \033[0;31m
GREEN := \033[0;32m
BOLD := \033[1m
NORMAL := \033[0m

BASE_DIR := $(CURDIR)/..

LOCAL_BIN := $(CURDIR)/bin
$(LOCAL_BIN):
	mkdir -p $@

PATH := $(LOCAL_BIN):$(PATH)
export PATH

.PHONY: env
env::
	@echo 'alias m=make'
	@echo 'export PATH="$(LOCAL_BIN):$$PATH"'

.envrc:
	$(MAKE) --no-print-directory env > .envrc

XDG_CONFIG_HOME := $(CURDIR)/.config
export XDG_CONFIG_HOME
env::
	@echo 'export XDG_CONFIG_HOME="$(XDG_CONFIG_HOME)"'

.PHONY: clean
clean:
	rm -fr $(XDG_CONFIG_HOME) $(LOCAL_BIN) .envrc

CURL ?= /usr/local/opt/curl/bin/curl
PATH := /usr/local/opt/curl/bin:$(PATH)
export PATH
ifneq ($(PLATFORM),Darwin)
$(CURL):
	$(error Please install curl)
endif

# https://github.com/dagger/dagger/releases
DAGGER_VERSION := 0.2.4
DAGGER ?= $(LOCAL_BIN)/dagger
$(DAGGER): | $(CURL) $(LOCAL_BIN)
	$(CURL) --fail --location https://dl.dagger.io/dagger/install.sh \
	| DAGGER_VERSIION=$(DAGGER_VERSION) sh -ex
	$(DAGGER) version | grep $(DAGGER_VERSION)

.DEFAULT_GOAL := dagger
.PHONY: dagger
dagger: | $(DAGGER) .envrc
	@printf "\nRun $(BOLD)dagger do$(NORMAL) to discover what actions are available\n\n"

FLY_VERSION := 0.0.333
FLY_DIR ?= $(LOCAL_BIN)/fly-$(FLY_VERSION)
FLY ?= $(FLY_DIR)/bin/fly
$(FLY): | $(CURL) $(LOCAL_BIN)
	mkdir -p $(FLY_DIR)
	$(CURL) --fail --location https://fly.io/install.sh | FLYCTL_INSTALL=$(FLY_DIR) sh -ex
	$(FLY) version | grep $(FLY_VERSION)
	ln -sf $(FLY) $(LOCAL_BIN)/fly
.PHONY: fly
fly: | $(FLY) .envrc

env::
	@echo 'export DAGGER_LOG_FORMAT=plain'
	@echo 'export DAGGER_LOG_LEVEL=debug'

env::
	@$(MAKE) --directory $(CURDIR)/../2021 --no-print-directory env-secrets

secrets: .envrc | $(FLY)
	$(MAKE) --directory $(CURDIR)/../2021 --no-print-directory env-secrets \
	| awk '! /FLY|PG_DOTCOM/ { print $$2 }' \
	| $(FLY) secrets import
