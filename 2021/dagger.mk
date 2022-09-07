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

$(DAGGER_ENV)/prod_image: | dagger-init
	$(DAGGER_CTX) new prod_image --package $(CURDIR)/dagger/prod_image
	printf "$(MAGENTA)Run this only once per environment$(NORMAL)\n"
	read -p "Enter your DockerHub username: " dockerhub_username \
	; $(DAGGER_CTX) input text dockerhub_username $$dockerhub_username --environment prod_image
	read -p "Enter your DockerHub password: " dockerhub_password \
	; $(DAGGER_CTX) input secret dockerhub_password $$dockerhub_password --environment prod_image

# https://tools.ietf.org/html/rfc3339 format - . instead of : - so that Docker tag is valid
BUILD_VERSION ?= $(shell date -u +'%Y-%m-%dT%H.%M.%SZ')
GIT_SHA ?= $(shell git rev-parse HEAD)
APP_VERSION ?= $(shell date -u +'%y.%-m.%-d+'$(GIT_SHA))
BUILD_URL ?= https://github.com/thechangelog/changelog.com/actions
GIT_AUTHOR ?= $(USER)

define _convert_dockerignore_to_excludes
awk '{ print "--exclude " $$1 }' < $(BASE_DIR)/.dockerignore
endef
.PHONY: ship-it
ship-it: $(DAGGER_ENV)/prod_image
	$(DAGGER_CTX) input dir app_src . $(shell $(_convert_dockerignore_to_excludes)) --exclude deps --exclude _build --exclude dagger --environment prod_image
	$(DAGGER_CTX) input text prod_dockerfile --file docker/Dockerfile.production --environment prod_image
	$(DAGGER_CTX) input text git_sha $(GIT_SHA) --environment prod_image
	$(DAGGER_CTX) input text git_author $(GIT_AUTHOR) --environment prod_image
	$(DAGGER_CTX) input text app_version $(APP_VERSION) --environment prod_image
	$(DAGGER_CTX) input text build_version $(APP_VERSION) --environment prod_image
	$(DAGGER_CTX) input text build_url $(BUILD_URL) --environment prod_image
	$(DAGGER_CTX) input text docker_host $(DOCKER_HOST) --environment prod_image
	$(DAGGER_CTX) up --log-level debug --environment prod_image

.PHONY: dagger-clean
dagger-clean:
	rm -fr $(DAGGER_HOME)
