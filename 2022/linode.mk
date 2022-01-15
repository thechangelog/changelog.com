# This has been already created via crossplane.mk & will be enabled on: eval "$(make env)"

LKE_LABEL ?= lke-2021-12-24
export LKE_LABEL
env::
	@echo 'export LKE_LABEL=$(LKE_LABEL)'

LKE_CONFIGS := $(XDG_CONFIG_HOME)/kube/configs
$(LKE_CONFIGS):
	mkdir -p $(LKE_CONFIGS)

env:: | $(LPASS)
	@$(LPASS) status --quiet \
	|| ( printf "$(RED)LastPass session expired, run $(BOLD)lpass login <YOUR_EMAIL_ADDRESS>$(NORMAL)\n" ; exit 1 )
	@echo 'export LINODE_CLI_TOKEN="$(shell $(LPASS) show --notes Shared-changelog/secrets/LINODE_CLI_TOKEN)"'

ifeq ($(PLATFORM),Darwin)
# Use Python3 for all Python-based CLIs, such as linode-cli
PATH := /usr/local/opt/python/libexec/bin:$(PATH)
export PATH

PIP := /usr/local/bin/pip3
$(PIP):
	@brew install python3 $(SILENT)

# https://github.com/linode/linode-cli
LINODE_CLI := /usr/local/bin/linode-cli
$(LINODE_CLI): $(PIP)
	@$(PIP) install linode-cli $(SILENT)
	@touch $(@) $(SILENT)


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


.PHONY: linode
linode: | $(LINODE_CLI)
ifndef LINODE_CLI_TOKEN
	$(call env_not_set,LINODE_CLI_TOKEN)
endif

env:: | linode
	@$(LINODE_CLI) completion bash

LINODE := $(LINODE_CLI) --no-defaults

.PHONY: regions
regions: | linode
	$(LINODE) regions list

.PHONY: linodes
linodes: | linode
	$(LINODE) linodes list

.PHONY: linodes-types
linodes-types: | linode
	$(LINODE) linodes types

.PHONY: linode-balancers
linode-balancers: | linode
	$(LINODE) nodebalancers list

.PHONY: linode-volumes
linode-volumes: | linode
	$(LINODE) volumes list

.PHONY: linode-resources
linode-resources: | linodes linode-volumes linode-balancers

LKE_LS = $(LINODE) --all lke clusters-list
.PHONY: lkes
lkes: | linode
	$(LKE_LS)

.PHONY: lke-versions
lke-versions: | linode
	$(LINODE) --all lke versions-list

.PHONY: lke-configs
lke-configs: | linode $(LKE_CONFIGS) $(JQ)
	@$(LKE_LS) --json \
	  | $(JQ) --raw-output --compact-output '.[] | [.id, .label] | join(" ")' \
	  | while read -r lke_id lke_name \
	    ; do \
	      printf "Saving $(BOLD)$$lke_name$(NORMAL) LKE cluster config to $(BOLD)$(LKE_CONFIGS)/$$lke_name.yml$(NORMAL) ...\n" \
	      ; $(LINODE) lke kubeconfig-view $$lke_id --no-headers --text \
	      | base64 --decode \
	      > $(LKE_CONFIGS)/$$lke_name.yml \
	      ; chmod 600 $(LKE_CONFIGS)/$$lke_name.yml \
	    ; done \
	  && printf "$(BOLD)$(GREEN)OK!$(NORMAL)\n" \
	  && printf "\nTo use a specific config with $(BOLD)kubectl$(NORMAL), run e.g. $(BOLD)export KUBECONFIG=$(NORMAL)\n"

KUBECONFIG ?= $(LKE_CONFIGS)/$(LKE_LABEL).yml
export KUBECONFIG
env::
	@echo 'export KUBECONFIG=$(KUBECONFIG)'

.PHONY: k9s
k9s: | $(K9S) lke-configs lke-ctx ## Interact with K8S via a terminal UI
	$(K9S) --all-namespaces --headless

IS_KUBECONFIG_LKE_CONFIG := $(findstring $(LKE_CONFIGS), $(KUBECONFIG))
.PHONY: lke-config-hint
lke-config-hint:
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@printf "You may want to set $(BOLD)KUBECONFIG$(NORMAL) " \
	; printf "to one of the configs stored in $(BOLD)$(LKE_CONFIGS)$(NORMAL)\n"
endif

KUBECTL_RELEASES := https://github.com/kubernetes/kubernetes/releases
# ⚠️  Use the same version as the server, look in crossplane.mk
KUBECTL_VERSION = 1.22.5
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

.PHONY: lke-ctx
lke-ctx: | $(KUBECTL) lke-config-hint

.PHONY: lke-debug
lke-debug: | lke-ctx
	$(KUBECTL) $(K_CMD) --filename $(CURDIR)/manifests/debug.yml

.PHONY: lke-bootstrap
lke-bootstrap:: | lke-debug
