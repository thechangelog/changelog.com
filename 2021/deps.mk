LOCAL_BIN := $(CURDIR)/bin
$(LOCAL_BIN):
	mkdir -p $@

PATH := $(LOCAL_BIN):$(PATH)
export PATH

.PHONY: env
env::
	@echo 'alias m=make'
	@echo 'export PATH="$(LOCAL_BIN):$$PATH"'

ifeq ($(PLATFORM),Darwin)
OPEN := open
else
OPEN := xdg-open
endif

XDG_CONFIG_HOME := $(CURDIR)/.config
export XDG_CONFIG_HOME
env::
	@echo 'export XDG_CONFIG_HOME="$(XDG_CONFIG_HOME)"'


CURL ?= /usr/bin/curl
ifeq ($(PLATFORM),Linux)
$(CURL):
	@sudo apt-get update && sudo apt-get install curl
endif

K9S_RELEASES := https://github.com/derailed/k9s/releases
K9S_VERSION := 0.24.2
K9S_BIN_DIR := $(LOCAL_BIN)/k9s-$(K9S_VERSION)-$(platform)-x86_64
K9S_URL := $(K9S_RELEASES)/download/v$(K9S_VERSION)/k9s_$(platform)_x86_64.tar.gz
K9S := $(K9S_BIN_DIR)/k9s
$(K9S): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(K9S_BIN_DIR).tar.gz "$(K9S_URL)"
	mkdir -p $(K9S_BIN_DIR) && tar zxf $(K9S_BIN_DIR).tar.gz -C $(K9S_BIN_DIR)
	touch $(K9S)
	chmod +x $(K9S)
	$(K9S) version | grep $(K9S_VERSION)
	ln -sf $(K9S) $(LOCAL_BIN)/k9s

.PHONY: k9s
k9s: | $(K9S) ## Interact with K8S via a terminal UI
	$(K9S)

KUBECTL_RELEASES := https://github.com/kubernetes/kubernetes/releases
KUBECTL_VERSION := $(LKE_VERSION).8
KUBECTL_BIN := kubectl-$(KUBECTL_VERSION)-$(platform)-amd64
KUBECTL_URL := https://storage.googleapis.com/kubernetes-release/release/v$(KUBECTL_VERSION)/bin/$(platform)/amd64/kubectl
KUBECTL := $(LOCAL_BIN)/$(KUBECTL_BIN)
$(KUBECTL): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(KUBECTL) "$(KUBECTL_URL)"
	touch $(KUBECTL)
	chmod +x $(KUBECTL)
	$(KUBECTL) version | grep $(KUBECTL_VERSION)
	ln -sf $(KUBECTL) $(LOCAL_BIN)/kubectl
.PHONY: kubectl
kubectl: $(KUBECTL)

.PHONY: releases-kubectl
releases-kubectl:
	$(OPEN) $(KUBECTL_RELEASES)

ifeq ($(PLATFORM),Darwin)
# Use Python3 for all Python-based CLIs, such as linode-cli
PATH := /usr/local/opt/python/libexec/bin:$(PATH)
export PATH

PIP := /usr/local/bin/pip3
$(PIP):
	brew install python3

# https://github.com/linode/linode-cli
LINODE_CLI := /usr/local/bin/linode-cli
$(LINODE_CLI): $(PIP)
	$(PIP) install linode-cli
	touch $(@)


linode-cli-upgrade: $(PIP)
	$(PIP) install --upgrade linode-cli
endif

ifeq ($(PLATFORM),Linux)
LINODE_CLI ?= /usr/bin/linode-cli
$(LINODE_CLI):
	$(error Please install linode-cli: https://github.com/linode/linode-cli)
endif

.PHONY: linode-cli
linode-cli: $(LINODE_CLI)

JQ_RELEASES := https://github.com/stedolan/jq/releases
JQ_VERSION := 1.6
JQ_BIN := jq-$(JQ_VERSION)-$(platform)-x86_64
JQ_URL := $(JQ_RELEASES)/download/jq-$(JQ_VERSION)/jq-$(platform)64
ifeq ($(platform),darwin)
JQ_URL := $(JQ_RELEASES)/download/jq-$(JQ_VERSION)/jq-osx-amd64
endif
JQ := $(LOCAL_BIN)/$(JQ_BIN)
$(JQ): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(JQ) "$(JQ_URL)"
	touch $(JQ)
	chmod +x $(JQ)
	$(JQ) --version | grep $(JQ_VERSION)
	ln -sf $(JQ) $(LOCAL_BIN)/jq
.PHONY: jq
jq: $(JQ)
.PHONY: releases-jq
releases-jq:
	$(OPEN) $(JQ_RELEASES)
