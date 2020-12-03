# https://www.linode.com/docs/kubernetes/deploy-and-manage-lke-cluster-with-api-a-tutorial/
LKE_CONFIGS := $(CURDIR)/.kube/configs
LKE_NAME ?= prod
LKE_LABEL ?= $(LKE_NAME)-$(shell date -u +'%Y%m%d')
LKE_REGION ?= us-east
LKE_VERSION ?= 1.17
LKE_NODE_TYPE ?= g6-dedicated-8
LKE_NODE_COUNT ?= 3

K9S_RELEASES := https://github.com/derailed/k9s/releases
K9S_VERSION := 0.24.1
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
# Keep it in lock-step with LKE_VERSION
KUBECTL_VERSION := 1.17.14
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

HELM_RELEASES := https://github.com/helm/helm/releases
HELM_VERSION := 3.4.1
HELM_BIN_DIR := helm-v$(HELM_VERSION)-$(platform)-amd64
HELM_URL := https://get.helm.sh/$(HELM_BIN_DIR).tar.gz
HELM := $(LOCAL_BIN)/$(HELM_BIN_DIR)/$(platform)-amd64/helm
$(HELM): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(LOCAL_BIN)/$(HELM_BIN_DIR).tar.gz "$(HELM_URL)"
	mkdir -p $(LOCAL_BIN)/$(HELM_BIN_DIR) && tar zxf $(LOCAL_BIN)/$(HELM_BIN_DIR).tar.gz -C $(LOCAL_BIN)/$(HELM_BIN_DIR)
	touch $(HELM)
	chmod +x $(HELM)
	$(HELM) version | grep $(HELM_VERSION)
	ln -sf $(HELM) $(LOCAL_BIN)/helm
.PHONY: helm
helm: $(HELM)

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

KUBECTX := /usr/local/bin/kubectx
KUBENS := /usr/local/bin/kubens
$(KUBECTX) $(KUBENS):
	brew install kubectx

OCTANT := /usr/local/bin/octant
$(OCTANT):
	brew install octant

POPEYE := /usr/local/bin/popeye
$(POPEYE):
	brew install derailed/popeye/popeye

KREW := /usr/local/bin/kubectl-krew
$(KREW):
	brew install krew
krew: $(KREW)

JSONNET := /usr/local/bin/jsonnet
$(JSONNET):
	brew install go-jsonnet

YQ := /usr/local/bin/yq
$(YQ):
	brew install yq
endif
ifeq ($(PLATFORM),Linux)
LINODE_CLI ?= /usr/bin/linode-cli
$(LINODE_CLI):
	$(error Please install linode-cli: https://github.com/linode/linode-cli)

KUBECTX ?= /usr/bin/kubectx
KUBENS ?= /usr/bin/kubens
$(KUBECTX) $(KUBENS):
	$(error Please install kubectx: https://github.com/ahmetb/kubectx#installation)

OCTANT ?= /usr/bin/octant
$(OCTANT):
	$(error Please install octant: https://github.com/vmware-tanzu/octant#installation)

POPEYE ?= /usr/bin/popeye
$(POPEYE):
	$(error Please install popeye: https://github.com/derailed/popeye#installation)

KREW ?= /usr/bin/kubectl-krew
$(KREW):
	$(error Please install krew: https://github.com/kubernetes-sigs/krew#installation)

JSONNET ?= /usr/bin/jsonnet
$(JSONNET):
	$(error Please install go-jsonnet: https://github.com/google/go-jsonnet)

YQ ?= /usr/bin/yq
$(YQ):
	$(error Please install yq: https://github.com/mikefarah/yq#install)
endif

# https://github.com/ahmetb/kubectl-tree
KUBETREE := $(HOME)/.krew/bin/kubectl-tree
$(KUBETREE): | $(KUBECTL) $(KREW)
	$(KUBECTL) krew install tree \
	&& touch $(@)

# https://github.com/kubectl-plus/kcf
KUBEFLEET := $(HOME)/.krew/bin/kubectl-fleet
$(KUBEFLEET): | $(KUBECTL) $(KREW)
	$(KUBECTL) krew install fleet \
	&& touch $(@)
kubefleet: $(KUBEFLEET)

# https://github.com/eldadru/ksniff
KSNIFF := $(HOME)/.krew/bin/kubectl-sniff
$(KSNIFF): | $(KUBECTL) $(KREW)
	$(KUBECTL) krew install sniff \
	&& touch $(@)
ksniff: $(KSNIFF)

# Make krew plugins available to kubectl
PATH := $(HOME)/.krew/bin:$(PATH)
export PATH

YTT_RELEASES := https://github.com/k14s/ytt/releases
YTT_VERSION := 0.28.0
YTT_BIN := ytt-$(YTT_VERSION)-$(platform)-amd64
YTT_URL := https://github.com/k14s/ytt/releases/download/v$(YTT_VERSION)/ytt-$(platform)-amd64
YTT := $(LOCAL_BIN)/$(YTT_BIN)
$(YTT): $(CURL)
	mkdir -p $(LOCAL_BIN) \
	&& cd $(LOCAL_BIN) \
	&& $(CURL) --progress-bar --fail --location --output $(YTT) "$(YTT_URL)" \
	&& touch $(YTT) \
	&& chmod +x $(YTT) \
	&& $(YTT) version \
	   | grep $(YTT_VERSION) \
	&& ln -sf $(YTT) $(LOCAL_BIN)/ytt
.PHONY: ytt
ytt: $(YTT)
.PHONY: releases-ytt
releases-ytt:
	@$(OPEN) $(YTT_RELEASES)

JB_RELEASES := https://github.com/jsonnet-bundler/jsonnet-bundler/releases
JB_VERSION := 0.4.0
JB_BIN := jb-$(JB_VERSION)-$(platform)-amd64
JB_URL := https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v$(JB_VERSION)/jb-$(platform)-amd64
JB := $(LOCAL_BIN)/$(JB_BIN)
$(JB): $(CURL)
	mkdir -p $(LOCAL_BIN) \
	&& cd $(LOCAL_BIN) \
	&& $(CURL) --progress-bar --fail --location --output $(JB) "$(JB_URL)" \
	&& touch $(JB) \
	&& chmod +x $(JB) \
	&& $(JB) --version 2>&1 \
	   | grep "$(JB_VERSION)" \
	&& ln -sf $(JB) $(LOCAL_BIN)/jb
.PHONY: jb
jb: $(JB)
.PHONY: releases-jb
releases-jb:
	@$(OPEN) $(JB_RELEASES)

YQ_RELEASES := https://github.com/mikefarah/yq/releases
YQ_VERSION := 3.3.2
YQ_BIN := yq_$(platform)_amd64
YQ_URL := https://github.com/mikefarah/yq/releases/download/$(YQ_VERSION)/$(YQ_BIN)
YQ := $(LOCAL_BIN)/$(YQ_BIN)
$(YQ): $(CURL)
	mkdir -p $(LOCAL_BIN) \
	&& cd $(LOCAL_BIN) \
	&& $(CURL) --progress-bar --fail --location --output $(YQ) "$(YQ_URL)" \
	&& touch $(YQ) \
	&& chmod +x $(YQ) \
	&& $(YQ) --version 2>&1 \
	   | grep "$(YQ_VERSION)" \
	&& ln -sf $(YQ) $(LOCAL_BIN)/yq
.PHONY: yq
yq: $(YQ)
.PHONY: releases-yq
releases-yq:
	@$(OPEN) $(YQ_RELEASES)

.PHONY: kubectx
kubectx: | $(KUBECTX)
.PHONY: kubens
kubens: | $(KUBENS)

LINODE := $(LINODE_CLI) --no-defaults

.PHONY: linode
linode: | $(LINODE_CLI) linode-cli-token

.PHONY: regions
regions: | linode
	$(LINODE) regions list

.PHONY: linodes
linodes: | linode
	$(LINODE) linodes list

.PHONY: nodebalancers
nodebalancers: | linode
	$(LINODE) nodebalancers list

.PHONY: lke
lke: | linode
	$(LINODE) lke cluster-create \
	    --label $(LKE_LABEL) \
	    --region $(LKE_REGION) \
	    --k8s_version $(LKE_VERSION) \
	    --node_pools.type $(LKE_NODE_TYPE) \
	    --node_pools.count $(LKE_NODE_COUNT)

# Append target for configuring the base add-ons required by changelog.com
.PHONY: lke-provision
lke-provision::

.PHONY: lke-update
lke-update: | linode $(JQ)
	$(LKE_POOL_LS) --json \
	| $(JQ) --raw-output --compact-output 'unique_by(.id) | .[].id' \
	| while read -r lke_pool_id \
	  ; do \
	    printf "\n$(YELLOW)Initiating node pool update $(BOLD)$$lke_pool_id$(NORMAL) $(YELLOW)in cluster $(BOLD)$(LKE_LABEL)$(NORMAL)..." \
	    ; $(LINODE) lke pool-recycle $(LKE_CLUSTER_ID) $$lke_pool_id \
	  ; done \
	&& printf "$(BOLD)$(GREEN)OK!$(NORMAL)\n"

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

.PHONY: lke-pool-ls
lke-pool-ls: | linode $(JQ)
	$(LKE_POOL_LS)

LKE_LS = $(LINODE) --all lke clusters-list
.PHONY: lke-ls
lke-ls: linode
	$(LKE_LS)

.PHONY: lke-versions
lke-versions: linode
	$(LINODE) --all lke versions-list

.PHONY: lke-node-types
lke-node-types: | linode
	$(LINODE) linodes types

$(LKE_CONFIGS):
	mkdir -p $(LKE_CONFIGS)

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
	    ; done \
	  && printf "$(BOLD)$(GREEN)OK!$(NORMAL)\n" \
	  && printf "\nTo use a specific config with $(BOLD)kubectl$(NORMAL), run e.g. $(BOLD)export KUBECONFIG=$(NORMAL)\n"

IS_KUBECONFIG_LKE_CONFIG := $(findstring $(LKE_CONFIGS), $(KUBECONFIG))
.PHONY: lke-config-hint
lke-config-hint:
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@printf "You may want to set $(BOLD)KUBECONFIG$(NORMAL) " \
	; printf "to one of the configs stored in $(BOLD)$(LKE_CONFIGS)$(NORMAL)\n"
endif

.PHONY: lke-ctx
lke-ctx: $(KUBECTL) lke-config-hint

.PHONY: lke-nodes
lke-nodes: lke-ctx
	$(KUBECTL) get --output=wide nodes

.PHONY: lke-show-all
lke-show-all: lke-ctx
	$(KUBECTL) get all --all-namespaces

# https://octant.dev/
.PHONY: lke-browse
lke-browse: $(OCTANT) lke-config-hint
	$(OCTANT)

# https://github.com/derailed/k9s
.PHONY: lke-cli
lke-cli: $(K9S) lke-config-hint
	$(K9S) --all-namespaces

# https://github.com/derailed/popeye
.PHONY: lke-sanitize
lke-sanitize: $(POPEYE) lke-config-hint
	$(POPEYE)

# https://github.com/kubectl-plus/kcf
.PHONY: lke-details
lke-details: $(KUBEFLEET) lke-config-hint
	$(KUBEFLEET) details $$($(KUBECTL) config current-context | awk -F"-ctx" '{ print $$1 }')

include $(CURDIR)/mk/external-dns.mk
include $(CURDIR)/mk/cert-manager.mk
include $(CURDIR)/mk/ingress-nginx.mk
include $(CURDIR)/mk/kube-prometheus.mk
include $(CURDIR)/mk/postgres.mk
include $(CURDIR)/mk/changelog.mk
include $(CURDIR)/mk/keel.mk
include $(CURDIR)/mk/grafana-cloud.mk
