# https://www.linode.com/docs/kubernetes/deploy-and-manage-lke-cluster-with-api-a-tutorial/

LKE_CONFIGS := $(CURDIR)/.kube/configs
LKE_NAME ?= dev
LKE_LABEL := $(LKE_NAME)-$(shell date -u +'%Y%m%d')
LKE_REGION := us-central
LKE_VERSION := 1.16
LKE_NODE_TYPE := g6-dedicated-2
LKE_NODE_COUNT := 3
define LKE_CLUSTER
{ \
  "label": "$(LKE_LABEL)", \
  "region": "$(LKE_REGION)", \
  "version": "$(LKE_VERSION)", \
  "tags": ["$(USER)"], \
  "node_pools": [ \
    { "type": "$(LKE_NODE_TYPE)", "count": $(LKE_NODE_COUNT) } \
  ] \
}
endef

ifeq ($(PLATFORM),Darwin)
# Use Python3 for all Python-based CLIs, such as linode-cli
PATH := /usr/local/opt/python/libexec/bin:$(PATH)
export PATH

PIP ?= /usr/local/bin/pip3
$(PIP):
	@brew install python3

# https://github.com/linode/linode-cli
LINODE_CLI ?= /usr/local/bin/linode-cli
$(LINODE_CLI): $(PIP)
	@$(PIP) install linode-cli

linode-cli-upgrade: $(PIP)
	@$(PIP) install --upgrade linode-cli

KUBECTL := /usr/local/bin/kubectl
$(KUBECTL):
	@brew install kubernetes-cli

OCTANT ?= /usr/local/bin/octant
$(OCTANT):
	@brew install octant

K9S ?= /usr/local/bin/k9s
$(K9S):
	@brew install derailed/k9s/k9s

POPEYE ?= /usr/local/bin/popeye
$(POPEYE):
	@brew install derailed/popeye/popeye
endif
ifeq ($(PLATFORM),Linux)
LINODE_CLI ?= /usr/bin/linode-cli
$(LINODE_CLI):
	$(error Please install linode-cli: https://github.com/linode/linode-cli)

KUBECTL ?= /usr/bin/kubectl
$(KUBECTL):
	$(error Please install kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl)

OCTANT ?= /usr/bin/octant
$(OCTANT):
	$(error Please install octant: https://github.com/vmware-tanzu/octant#installation)

K9S ?= /usr/bin/k9s
$(K9S):
	$(error Please install k9s: https://github.com/derailed/k9s#installation)

POPEYE ?= /usr/bin/popeye
$(POPEYE):
	$(error Please install popeye: https://github.com/derailed/popeye#installation)
endif

LINODE := $(LINODE_CLI) --no-defaults

.PHONY: linode
linode: $(LINODE_CLI) linode-cli-token

.PHONY: linodes
linodes: linode
	@$(LINODE) linodes list

# https://developers.linode.com/api/v4/lke-clusters/#post
.PHONY: lke-new
lke-new: $(CURL) linode-cli-token
	@printf "Creating a new LKE cluster: \n$(BOLD)$(LKE_CLUSTER)$(NORMAL)\n" \
	; $(CURL) --fail --request POST \
	  --header "Content-Type: application/json" \
	  --header "Authorization: Bearer $$LINODE_CLI_TOKEN" \
	  --data '$(LKE_CLUSTER)' \
	  https://api.linode.com/v4beta/lke/clusters \
	&& printf "\n$(BOLD)$(GREEN)OK!$(NORMAL)\n" \
	&& printf "\nTo see all available LKE clusters, run $(BOLD)$(MAKE) lke-ls$(NORMAL)"

LKE_LS := $(LINODE) --all lke clusters-list
.PHONY: lke-ls
lke-ls: linode
	@$(LKE_LS)

$(LKE_CONFIGS):
	@mkdir -p $(LKE_CONFIGS)

.PHONY: lke-configs
lke-configs: linode $(LKE_CONFIGS)
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
define HINT_LKE_CONFIG
printf "You may want to set $(BOLD)KUBECONFIG$(NORMAL) " \
; printf "to one of the configs stored in $(BOLD)$(LKE_CONFIGS)$(NORMAL)\n"
endef

.PHONY: lke-nodes
lke-nodes: $(KUBECTL)
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@$(HINT_LKE_CONFIG)
endif
	@$(KUBECTL) get --output=wide nodes

.PHONY: lke-show-all
lke-show-all: $(KUBECTL)
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@$(HINT_LKE_CONFIG)
endif
	@$(KUBECTL) get all --all-namespaces

# https://octant.dev/
.PHONY: lke-inspect
lke-inspect: $(OCTANT)
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@$(HINT_LKE_CONFIG)
endif
	@$(OCTANT)

# https://github.com/derailed/k9s
.PHONY: lke-cli
lke-cli: $(K9S)
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@$(HINT_LKE_CONFIG)
endif
	@$(K9S)

# https://github.com/derailed/popeye
.PHONY: lke-sanitize
lke-sanitize: $(K9S)
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@$(HINT_LKE_CONFIG)
endif
	@$(POPEYE)
