# Tip: https://github.com/dagger/dagger-action
# curl -L https://dl.dagger.io/dagger/latest_version
# ⚠️  Keep this in sync with .github/workflows/ship_it.yml
DAGGER_VERSION := 0.1.0
DAGGER_RELEASES := https://dl.dagger.io/dagger/releases
DAGGER_DIR := $(LOCAL_BIN)/dagger_v$(DAGGER_VERSION)_$(platform)_amd64
DAGGER_URL := $(DAGGER_RELEASES)/$(DAGGER_VERSION)/$(notdir $(DAGGER_DIR)).tar.gz
DAGGER ?= $(DAGGER_DIR)/dagger
$(DAGGER): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(DAGGER_DIR).tar.gz $(DAGGER_URL)
	mkdir -p $(DAGGER_DIR) && tar zxf $(DAGGER_DIR).tar.gz -C $(DAGGER_DIR)
	touch $(DAGGER)
	chmod +x $(DAGGER)
	$(DAGGER) version | grep $(DAGGER_VERSION)
	ln -sf $(DAGGER) $(LOCAL_BIN)/dagger
.PHONY: dagger
dagger: $(DAGGER)
.PHONY: releases-dagger
releases-dagger:
	$(OPEN) https://github.com/dagger/dagger/releases

DAGGER_GIT_DIR := $(CURDIR)/tmp/dagger-$(DAGGER_VERSION)
$(DAGGER_GIT_DIR):
	git clone \
	  --branch v$(DAGGER_VERSION) --single-branch --depth 1 \
	  git@github.com:dagger/dagger $(DAGGER_GIT_DIR)
.PHONY: tmp/dagger
tmp/dagger: $(DAGGER_GIT_DIR)

DAGGER_CTX = cd $(BASE_DIR)
# Log in plain format if DEBUG variable is set
ifneq (,$(DEBUG))
  DAGGER_CTX += && time $(DAGGER) --log-format plain
else
  DAGGER_CTX += && $(DAGGER)
endif
DAGGER_HOME := $(BASE_DIR)/.dagger
DAGGER_ENV := $(DAGGER_HOME)/env

$(DAGGER_HOME): | $(DAGGER)
	$(DAGGER_CTX) init
.PHONY: dagger-init
dagger-init: | $(DAGGER_HOME)

ifeq (,$(DOCKERHUB_USERNAME))
DOCKERHUB_USERNAME = NO_DOCKERHUB_USERNAME
endif
ifeq (,$(DOCKERHUB_PASSWORD))
DOCKERHUB_PASSWORD = NO_DOCKERHUB_PASSWORD
endif

DOCKER_SOCKET ?= /var/run/docker.sock

# https://tools.ietf.org/html/rfc3339 format - . instead of : - so that Docker tag is valid
APP_VERSION ?= $(shell date -u +'%y.%-m.%-d+'$(GITHUB_SHA))
BUILD_VERSION ?= $(shell date -u +'%Y-%m-%dT%H.%M.%SZ')
GITHUB_SERVER_URL ?= https://github.com
ifeq ($(GITHUB_REPOSITORY),)
GITHUB_REPOSITORY = thechangelog/changelog.com
endif
ifeq ($(BUILD_URL),)
BUILD_URL = $(GITHUB_SERVER_URL)/$(GITHUB_REPOSITORY)/actions/runs/$(GITHUB_RUN_ID)
endif
ifeq ($(GITHUB_ACTOR),)
GITHUB_ACTOR ?= $(USER)
endif
ifeq ($(GITHUB_REF_NAME),)
GITHUB_REF_NAME = $(shell git branch --show-current)
endif
GITHUB_REF_NAME_SAFE = $$(echo "$(GITHUB_REF_NAME)" | tr '/' '-')
ifeq ($(GITHUB_SHA),)
GITHUB_SHA = $(shell git rev-parse HEAD)
endif
ifeq ($(DAGGER_LOG_LEVEL),)
DAGGER_LOG_LEVEL = debug
endif
export DAGGER_LOG_LEVEL

define _convert_dockerignore_to_excludes
awk '{ print "--exclude " $$1 }' < $(BASE_DIR)/.dockerignore
endef

$(DAGGER_ENV)/ship_it: | dagger-init
	$(DAGGER_CTX) new ship_it --package $(CURDIR)/dagger/prod_image
	$(DAGGER_CTX) input dir app_src . $(shell $(_convert_dockerignore_to_excludes)) --exclude deps --exclude _build --exclude dagger --environment ship_it
	$(DAGGER_CTX) input text dockerhub_username $(DOCKERHUB_USERNAME) --environment ship_it
	@$(DAGGER_CTX) input secret dockerhub_password $(DOCKERHUB_PASSWORD) --environment ship_it
	$(DAGGER_CTX) input text app_version $(APP_VERSION) --environment ship_it
	$(DAGGER_CTX) input text build_url $(BUILD_URL) --environment ship_it
	$(DAGGER_CTX) input text build_version $(BUILD_VERSION) --environment ship_it
	$(DAGGER_CTX) input socket docker_socket $(DOCKER_SOCKET) --environment ship_it
ifneq (,$(findstring $(DOCKER_HOST), tcp://))
	$(DAGGER_CTX) input text docker_host $(DOCKER_HOST) --environment ship_it
endif
	$(DAGGER_CTX) input text git_author $(GITHUB_ACTOR) --environment ship_it
	$(DAGGER_CTX) input text git_branch $(GITHUB_REF_NAME_SAFE) --environment ship_it
	$(DAGGER_CTX) input text git_sha $(GITHUB_SHA) --environment ship_it
	$(DAGGER_CTX) input text prod_dockerfile --file docker/production.Dockerfile --environment ship_it

.PHONY: ship-it
ship-it: $(DAGGER_ENV)/ship_it
	$(DAGGER_CTX) up --environment ship_it

.PHONY: dagger-clean
dagger-clean:
	rm -fr $(DAGGER_HOME)
