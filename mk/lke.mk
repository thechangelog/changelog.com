# https://www.linode.com/docs/kubernetes/deploy-and-manage-lke-cluster-with-api-a-tutorial/

LKE_CONFIGS := $(CURDIR)/.kube/configs
LKE_NAME ?= dev
LKE_LABEL ?= $(LKE_NAME)-$(shell date -u +'%Y%m%d')
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

KUBECTX := /usr/local/bin/kubectx
KUBENS := /usr/local/bin/kubens
$(KUBECTX) $(KUBENS):
	@brew install kubectx

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

KUBECTX ?= /usr/bin/kubectx
KUBENS ?= /usr/bin/kubens
$(KUBECTX) $(KUBENS):
	$(error Please install kubectx: https://github.com/ahmetb/kubectx#installation)

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

# https://github.com/k14s/ytt/releases
YTT_VERSION := 0.23.0
YTT_BIN := ytt-$(YTT_VERSION)-$(platform)-amd64
YTT_URL := https://github.com/k14s/ytt/releases/download/v$(YTT_VERSION)/ytt-$(platform)-amd64
YTT := $(LOCAL_BIN)/$(YTT_BIN)
$(YTT): $(CURL)
	@mkdir -p $(LOCAL_BIN) \
	&& cd $(LOCAL_BIN) \
	&& $(CURL) --progress-bar --fail --location --output $(YTT) "$(YTT_URL)" \
	&& touch $(YTT) \
	&& chmod +x $(YTT) \
	&& $(YTT) version \
	   | grep $(YTT_VERSION) \
	&& ln -sf $(YTT) $(LOCAL_BIN)/ytt
.PHONY: ytt
ytt: $(YTT)
.PHONY: ytt-releases
ytt-releases:
	@$(OPEN) https://github.com/k14s/ytt/releases

.PHONY: kubectx
kubectx: $(KUBECTX)
.PHONY: kubens
kubens: $(KUBENS)

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
.PHONY: lke-config-hint
lke-config-hint:
ifneq ($(IS_KUBECONFIG_LKE_CONFIG), $(LKE_CONFIGS))
	@printf "You may want to set $(BOLD)KUBECONFIG$(NORMAL) " \
	; printf "to one of the configs stored in $(BOLD)$(LKE_CONFIGS)$(NORMAL)\n"
endif

.PHONY: lke-nodes
lke-nodes: $(KUBECTL) lke-config-hint
	@$(KUBECTL) get --output=wide nodes

.PHONY: lke-show-all
lke-show-all: $(KUBECTL) lke-config-hint
	@$(KUBECTL) get all --all-namespaces

# https://github.com/k14s/ytt/blob/master/examples/k8s-docker-secret/config.yml
.PHONY: lke-dnsimple-secret
lke-dnsimple-secret: $(KUBECTL) dnsimple-creds lke-config-hint
	@$(KUBECTL) create secret generic dnsimple \
	  --from-literal=token="$(DNSIMPLE_TOKEN)" --dry-run --output json \
	 | $(KUBECTL) apply --filename -

.PHONY: lke-external-dns
lke-external-dns: $(YTT) $(KUBECTL) lke-config-hint lke-dnsimple-secret
	@printf "$(BOLD)Configuring LKE cluster to manage DNS ...$(NORMAL)\n" \
	; $(YTT) --file k8s/external-dns \
	  | $(KUBECTL) apply --filename - \
	&& printf "$(BOLD)$(GREEN)OK!$(NORMAL)\n"

include $(CURDIR)/mk/ten.mk
# Copy of https://changelog.com/ten
.PHONY: lke-ten-changelog
lke-ten-changelog: $(YTT) $(KUBECTL) lke-config-hint
	@$(YTT) --file $(CURDIR)/k8s/ten \
	 | $(KUBECTL) apply --filename -

# https://octant.dev/
.PHONY: lke-inspect
lke-inspect: $(OCTANT) lke-config-hint
	@$(OCTANT)

# https://github.com/derailed/k9s
.PHONY: lke-cli
lke-cli: $(K9S) lke-config-hint
	@$(K9S)

# https://github.com/derailed/popeye
.PHONY: lke-sanitize
lke-sanitize: $(POPEYE) lke-config-hint
	@$(POPEYE)
