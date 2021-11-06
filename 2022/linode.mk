# https://www.linode.com/docs/kubernetes/deploy-and-manage-lke-cluster-with-api-a-tutorial/
LKE_CONFIGS := $(XDG_CONFIG_HOME)/.kube/configs
LKE_NAME ?= prod

# This has been already created & will be enabled on: eval "$(make env)"

# LKE_LABEL ?= $(LKE_NAME)-20211106
export LKE_LABEL
env::
	@echo 'export LKE_LABEL=$(LKE_LABEL)'
# us-east, the only US region with all the bells & whistles in 2021.11:
# Linodes, NodeBalancers, Block Storage, Object Storage, GPU Linodes, Kubernetes
LKE_REGION ?= us-east
LKE_VERSION ?= 1.21
LKE_NODE_TYPE ?= g6-dedicated-8
LKE_NODE_COUNT ?= 1

### HOW LONG DOES IT TAKE FOR EVERYTHING TO RESTORE IF THE VM GETS DELETED?
#
# - 00:00 Linode deleted
# - 03:00 Linode boots
# - 05:30 LKE node ready
# - 07:10 Uploads restore started
# - 07:12 PostgreSQL db init from backup started
# - 08:20 PostgreSQL db init from backup finished (1')
# - 21:00 Uploads restore finished (13')
# - 21:16 PostgreSQL db backup started
# - 21:52 PostgreSQL db backup finished
# - 22:58 Sentry notify release
# - 22:58 Compiling
# - 23:27 App booting
# - 23:29 Migrations running - noop
# - 23:54 First HTTP request serviced (24')

### HOW LONG DOES IT TAKE FOR EVERYTHING TO RESTORE IF THE VM GETS REBOOTED?
#
# - 00:00 Linode reboot initiated
# - 01:37 Linode boots
# - 03:12 First HTTP request serviced (3')

$(LKE_CONFIGS):
	mkdir -p $(LKE_CONFIGS)

LINODE_CLI_TOKEN ?= $(shell $(LPASS) show --notes Shared-changelog/secrets/LINODE_CLI_TOKEN)
export LINODE_CLI_TOKEN
env:: | $(LPASS)
	@$(LPASS) status --quiet || $(LPASS) login
	@echo 'export LINODE_CLI_TOKEN="$(LINODE_CLI_TOKEN)"'

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

.PHONY: lke
lke: | linode
	$(LINODE) lke cluster-create \
	    --label $(LKE_LABEL) \
	    --region $(LKE_REGION) \
	    --k8s_version $(LKE_VERSION) \
	    --node_pools.type $(LKE_NODE_TYPE) \
	    --node_pools.count $(LKE_NODE_COUNT)

LKE_LS = $(LINODE) --all lke clusters-list
.PHONY: lkes
lkes: | linode
	$(LKE_LS)

.PHONY: lke-versions
lke-versions: | linode
	$(LINODE) --all lke versions-list

LKE_POOL_LS = $(LINODE) --all lke pools-list $(LKE_CLUSTER_ID)
define LKE_CLUSTER_ID
$$($(LKE_LS) --json \
| $(JQ) '.[] | select(.label == "$(LKE_LABEL)") | .id')
endef

.PHONY: lke-pool
lke-pool: | linode $(JQ)
	$(LINODE) lke pool-create \
	    --type $(LKE_NODE_TYPE) \
	    --count $(LKE_NODE_COUNT) \
	    $(LKE_CLUSTER_ID)

.PHONY: lke-pools
lke-pools: | linode $(JQ)
	$(LKE_POOL_LS)

define LKE_POOL_PUBLIC_IPv4s
$$($(LKE_POOL_LS) --json \
| $(JQ) --raw-output --compact-output '.[] | .nodes.instance_id' \
| while read -r linode_id \
  ; do \
    $(LINODE) linodes ips-list $$linode_id --json \
    | $(JQ) --raw-output --compact-output '.[] | .ipv4.public | .[] | .address' \
  ; done \
| tr '\n' ',' \
| sed 's/,$$//')
endef
.PHONY: lke-pool-public-ipv4s
lke-pool-public-ipv4s: | linode $(JQ)
	@echo $(LKE_POOL_PUBLIC_IPv4s)

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
# Use the same version as the server
KUBECTL_VERSION = $(LKE_VERSION).5
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
