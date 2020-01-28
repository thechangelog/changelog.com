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
	brew install python3

# https://github.com/linode/linode-cli
LINODE_CLI ?= /usr/local/bin/linode-cli
$(LINODE_CLI): $(PIP)
	$(PIP) install linode-cli
	touch $(@)

linode-cli-upgrade: $(PIP)
	$(PIP) install --upgrade linode-cli

# Do not use kubectl installed by Docker for Desktop, this will typically be an older version than kubernetes-cli
KUBECTL := $(lastword /usr/local/Cellar/kubernetes-cli/$(LKE_VERSION).0/bin/kubectl $(wildcard /usr/local/Cellar/kubernetes-cli/*/bin/kubectl))
$(KUBECTL):
	brew install kubernetes-cli
bin/kubectl: $(KUBECTL)
	mkdir -p $(LOCAL_BIN) \
	&& ln -sf $(KUBECTL) $(LOCAL_BIN)/kubectl

KUBECTX := /usr/local/bin/kubectx
KUBENS := /usr/local/bin/kubens
$(KUBECTX) $(KUBENS):
	brew install kubectx

OCTANT ?= /usr/local/bin/octant
$(OCTANT):
	brew install octant

K9S ?= /usr/local/bin/k9s
$(K9S):
	brew install derailed/k9s/k9s

POPEYE ?= /usr/local/bin/popeye
$(POPEYE):
	brew install derailed/popeye/popeye

KREW ?= /usr/local/bin/kubectl-krew
$(KREW):
	brew install krew
krew: $(KREW)
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

KREW ?= /usr/bin/kubectl-krew
$(KREW):
	$(error Please install krew: https://github.com/kubernetes-sigs/krew#installation)
endif

# https://github.com/ahmetb/kubectl-tree
KUBETREE := $(HOME)/.krew/bin/kubectl-tree
$(KUBETREE): $(KUBECTL) $(KREW)
	$(KUBECTL) krew install tree

# Make krew plugins available to kubectl
PATH := $(HOME)/.krew/bin:$(PATH)
export PATH

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
	$(LINODE) linodes list

.PHONY: nodebalancers
nodebalancers: linode
	$(LINODE) nodebalancers list

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
	$(LKE_LS)

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

.PHONY: lke
lke: $(KUBECTL) lke-config-hint

.PHONY: lke-nodes
lke-nodes: lke
	$(KUBECTL) get --output=wide nodes

.PHONY: lke-show-all
lke-show-all: lke
	$(KUBECTL) get all --all-namespaces

EXTERNAL_DNS_DEPLOYMENT := external-dns
EXTERNAL_DNS_NAMESPACE := $(EXTERNAL_DNS_DEPLOYMENT)
EXTERNAL_DNS_TREE := $(KUBETREE) deployments $(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE)
# https://github.com/k14s/ytt/blob/master/examples/k8s-docker-secret/config.yml
.PHONY: lke-external-dns
lke-external-dns: lke dnsimple-creds $(YTT) $(KUBETREE)
	$(YTT) \
	  --data-value namespace=$(EXTERNAL_DNS_NAMESPACE) \
	  --file $(CURDIR)/k8s/external-dns > $(CURDIR)/k8s/external-dns.yml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/external-dns.yml \
	&& $(KUBECTL) create secret generic dnsimple \
	    --from-literal=token="$(DNSIMPLE_TOKEN)" --dry-run --output json \
	   | $(KUBECTL) apply --namespace $(EXTERNAL_DNS_NAMESPACE) --filename - \
	&& $(KUBETREE) deployments $(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE)

.PHONY: lke-external-dns-tree
lke-external-dns-tree: lke $(KUBETREE)
	$(EXTERNAL_DNS_TREE)

.PHONY: lke-external-dns-logs
lke-external-dns-logs: lke
	$(KUBECTL) logs deployments/$(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE)

include $(CURDIR)/mk/ten.mk

# https://octant.dev/
.PHONY: lke-browse
lke-browse: $(OCTANT) lke-config-hint
	$(OCTANT)

# https://github.com/derailed/k9s
.PHONY: lke-cli
lke-cli: $(K9S) lke-config-hint
	$(K9S)

# https://github.com/derailed/popeye
.PHONY: lke-sanitize
lke-sanitize: $(POPEYE) lke-config-hint
	$(POPEYE)

# https://github.com/kubernetes/ingress-nginx/releases
NGINX_INGRESS_VERSION := 0.27.1
.PHONY: lke-nginx-ingress
lke-nginx-ingress: lke
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-$(NGINX_INGRESS_VERSION)/deploy/static/mandatory.yaml \
	  --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-$(NGINX_INGRESS_VERSION)/deploy/static/provider/cloud-generic.yaml

.PHONY: lke-nginx-ingress-verify
lke-nginx-ingress-verify: lke
	 $(KUBECTL) get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch

# https://github.com/jetstack/cert-manager/releases
CERT_MANAGER_VERSION := 0.13.0
CERT_MANAGER_NAMESPACE := cert-manager
.PHONY: lke-cert-manager
lke-cert-manager: lke
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/jetstack/cert-manager/v$(CERT_MANAGER_VERSION)/deploy/manifests/01-namespace.yaml \
	  --filename https://github.com/jetstack/cert-manager/releases/download/v$(CERT_MANAGER_VERSION)/cert-manager.yaml

.PHONY: lke-cert-manager-verify
lke-cert-manager-verify: lke
	$(KUBECTL) apply \
	   --filename $(CURDIR)/k8s/cert-manager/test-resources.yml \
	&& $(KUBECTL) get certificate --namespace cert-manager-test --output=jsonpath='$(BOLD){"\n"}{.items[0].status.conditions[0].message}{"\n\n"}$(NORMAL)' \
	&& $(KUBECTL) get certificate --namespace cert-manager-test --output=yaml

.PHONY: lke-cert-manager-verify-clean
lke-cert-manager-verify-clean: lke
	$(KUBECTL) delete \
	   --filename $(CURDIR)/k8s/cert-manager/test-resources.yml