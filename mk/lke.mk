# https://www.linode.com/docs/kubernetes/deploy-and-manage-lke-cluster-with-api-a-tutorial/
LKE_CONFIGS := $(CURDIR)/.kube/configs
LKE_NAME ?= prod
LKE_LABEL ?= $(LKE_NAME)-$(shell date -u +'%Y%m%d')
LKE_REGION := us-east
LKE_VERSION := 1.17
LKE_NODE_TYPE := g6-dedicated-2
LKE_NODE_COUNT := 3

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

OCTANT := /usr/local/bin/octant
$(OCTANT):
	brew install octant

K9S := /usr/local/bin/k9s
$(K9S):
	brew install derailed/k9s/k9s

POPEYE := /usr/local/bin/popeye
$(POPEYE):
	brew install derailed/popeye/popeye

KREW := /usr/local/bin/kubectl-krew
$(KREW):
	brew install krew
krew: $(KREW)

JSONNET := /usr/local/bin/jsonnet
$(JSONNET):
	brew install jsonnet

YQ := /usr/local/bin/yq
$(YQ):
	brew install yq
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

JSONNET ?= /usr/bin/jsonnet
$(JSONNET):
	$(error Please install jsonnet: https://github.com/google/jsonnet#packages)

YQ ?= /usr/bin/yq
$(YQ):
	$(error Please install yq: https://github.com/mikefarah/yq#install)
endif

# https://github.com/ahmetb/kubectl-tree
KUBETREE := $(HOME)/.krew/bin/kubectl-tree
$(KUBETREE): $(KUBECTL) $(KREW)
	$(KUBECTL) krew install tree

# Make krew plugins available to kubectl
PATH := $(HOME)/.krew/bin:$(PATH)
export PATH

YTT_RELEASES := https://github.com/k14s/ytt/releases
YTT_VERSION := 0.27.1
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
.PHONY: releases-ytt
releases-ytt:
	@$(OPEN) $(YTT_RELEASES)

JB_RELEASES := https://github.com/jsonnet-bundler/jsonnet-bundler/releases
JB_VERSION := 0.3.1
JB_BIN := jb-$(JB_VERSION)-$(platform)-amd64
JB_URL := https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v$(JB_VERSION)/jb-$(platform)-amd64
JB := $(LOCAL_BIN)/$(JB_BIN)
$(JB): $(CURL)
	@mkdir -p $(LOCAL_BIN) \
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

.PHONY: kubectx
kubectx: | $(KUBECTX)
.PHONY: kubens
kubens: | $(KUBENS)

LINODE := $(LINODE_CLI) --no-defaults

.PHONY: linode
linode: | $(LINODE_CLI) linode-cli-token

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

.PHONY: lke-provision
lke-provision::

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

.PHONY: lke-ctx
lke-ctx: $(KUBECTL) lke-config-hint

.PHONY: lke-nodes
lke-nodes: lke-ctx
	$(KUBECTL) get --output=wide nodes

.PHONY: lke-show-all
lke-show-all: lke-ctx
	$(KUBECTL) get all --all-namespaces

# https://github.com/kubernetes-sigs/external-dns/releases
EXTERNAL_DNS_VERSION := v0.7.1
EXTERNAL_DNS_IMAGE := us.gcr.io/k8s-artifacts-prod/external-dns/external-dns:$(EXTERNAL_DNS_VERSION)
EXTERNAL_DNS_DEPLOYMENT := external-dns
EXTERNAL_DNS_NAMESPACE := $(EXTERNAL_DNS_DEPLOYMENT)
EXTERNAL_DNS_TREE := $(KUBETREE) deployments $(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE)
.PHONY: lke-external-dns
lke-external-dns: lke-ctx dnsimple-creds $(YTT) $(KUBETREE)
	$(YTT) \
	  --data-value namespace=$(EXTERNAL_DNS_NAMESPACE) \
	  --data-value image=$(EXTERNAL_DNS_IMAGE) \
	  --file $(CURDIR)/k8s/external-dns > $(CURDIR)/k8s/external-dns.yml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/external-dns.yml \
	&& $(KUBECTL) create secret generic dnsimple \
	    --from-literal=token="$(DNSIMPLE_TOKEN)" --dry-run --output json \
	   | $(KUBECTL) apply --namespace $(EXTERNAL_DNS_NAMESPACE) --filename - \
	&& $(KUBETREE) deployments $(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE)
lke-provision:: lke-external-dns

.PHONY: lke-external-dns-tree
lke-external-dns-tree: lke-ctx $(KUBETREE)
	$(EXTERNAL_DNS_TREE)

.PHONY: lke-external-dns-logs
lke-external-dns-logs: lke-ctx
	$(KUBECTL) logs deployments/$(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE) --follow

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
NGINX_INGRESS_VERSION := 0.30.0
NGINX_INGRESS_NAMESPACE := ingress-nginx
.PHONY: lke-nginx-ingress
lke-nginx-ingress: lke-ctx
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-$(NGINX_INGRESS_VERSION)/deploy/static/mandatory.yaml \
	  --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-$(NGINX_INGRESS_VERSION)/deploy/static/provider/cloud-generic.yaml \
	&& $(KUBECTL) scale --replicas=$(LKE_NODE_COUNT) deployment/nginx-ingress-controller --namespace $(NGINX_INGRESS_NAMESPACE) \
	&& $(KUBETREE) deployments nginx-ingress-controller --namespace $(NGINX_INGRESS_NAMESPACE)
lke-provision:: lke-nginx-ingress

.PHONY: lke-nginx-ingress-verify
lke-nginx-ingress-verify: lke-ctx
	 $(KUBECTL) get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch

.PHONY: lke-nginx-ingress-logs
lke-nginx-ingress-logs: lke-ctx
	$(KUBECTL) logs deployments/nginx-ingress-controller --namespace $(NGINX_INGRESS_NAMESPACE) --follow

# https://github.com/jetstack/cert-manager/releases
CERT_MANAGER_VERSION := 0.14.2
CERT_MANAGER_NAMESPACE := cert-manager
.PHONY: lke-cert-manager
lke-cert-manager: lke-ctx
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/jetstack/cert-manager/v$(CERT_MANAGER_VERSION)/deploy/manifests/01-namespace.yaml \
	  --filename https://github.com/jetstack/cert-manager/releases/download/v$(CERT_MANAGER_VERSION)/cert-manager.yaml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/cert-manager/letsencrypt-staging.yml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/cert-manager/letsencrypt-prod.yml
lke-provision:: lke-cert-manager

# https://kubernetes.io/docs/reference/kubectl/jsonpath/
.PHONY: lke-cert-manager-verify
lke-cert-manager-verify: lke-ctx
	$(KUBECTL) apply \
	   --filename $(CURDIR)/k8s/cert-manager/test-resources.yml \
	&& $(KUBECTL) get certificate --namespace cert-manager-test --output=jsonpath='$(BOLD){"\n"}{.items[0].status.conditions[0].message}{"\n\n"}$(NORMAL)' \
	&& $(KUBECTL) get certificate --namespace cert-manager-test --output=yaml

.PHONY: lke-cert-manager-verify-clean
lke-cert-manager-verify-clean: lke-ctx
	$(KUBECTL) delete \
	   --filename $(CURDIR)/k8s/cert-manager/test-resources.yml

.PHONY: lke-cert-manager-logs
lke-cert-manager-logs: lke-ctx
	$(KUBECTL) logs deployments/cert-manager --namespace $(CERT_MANAGER_NAMESPACE) --follow

.PHONY: lke-monitoring-grafana
lke-monitoring-grafana: lke-ctx
	$(KUBECTL) --namespace monitoring port-forward svc/grafana 3000

# https://github.com/openshift/cluster-monitoring-operator/blob/947f882593badbc3946853201ef6a82c9627f7de/jsonnet/grafana.jsonnet#L33
# https://github.com/coreos/kube-prometheus/blob/master/examples/prometheus-pvc.jsonnet
# https://github.com/coreos/kube-prometheus/issues/98#issuecomment-491782065

.PHONY: lke-monitoring
lke-monitoring: | lke-ctx kube-prometheus
	$(KUBECTL) apply --filename tmp/kube-prometheus/manifests/setup \
	&& $(KUBECTL) apply --filename tmp/kube-prometheus/manifests
lke-provision:: lke-monitoring

# https://github.com/coreos/kube-prometheus#compatibility
KUBE_PROMETHEUS_VERSION := master
ifeq ($(LKE_VERSION),1.16)
KUBE_PROMETHEUS_VERSION := release-0.4
endif
ifneq ($(filter $(LKE_VERSION), 1.17 1.18),)
KUBE_PROMETHEUS_VERSION := release-0.5
endif
.PHONY: kube-prometheus
kube-prometheus: tmp/kube-prometheus/manifests

.PHONY: kube-prometheus-update
kube-prometheus-update: | tmp/kube-prometheus/jsonnetfile.lock.json $(JB)
	@printf "\n$(BOLD)Update kube-prometheus@$(KUBE_PROMETHEUS_VERSION) ...$(NORMAL)\n"
	cd tmp/kube-prometheus \
	&& $(JB) update

tmp/kube-prometheus/manifests: k8s/kube-prometheus.jsonnet | tmp/kube-prometheus/jsonnetfile.lock.json $(JSONNET) $(LPASS)
	@printf "\n$(BOLD)Generate kube-prometheus manifests ...$(NORMAL)\n"
	cd tmp/kube-prometheus \
	&& rm -fr manifests \
	&& mkdir -p manifests/setup \
	&& time $(JSONNET) \
		  --jpath vendor \
		  --multi manifests \
		  --ext-str METRICS_GITHUB_OAUTH_APP_CLIENT_ID="$$($(LPASS) show --notes 6262503396338294422)" \
		  --ext-str METRICS_GITHUB_OAUTH_APP_CLIENT_SECRET="$$($(LPASS) show --notes 6396745408918286971)" \
		  $(CURDIR)/k8s/kube-prometheus.jsonnet \
	&& /usr/bin/find manifests -type f -exec mv {} {}.json \;

tmp/kube-prometheus/jsonnetfile.lock.json: | tmp/kube-prometheus/jsonnetfile.json $(JB)
	@printf "\n$(BOLD)Install kube-prometheus@$(KUBE_PROMETHEUS_VERSION) ...$(NORMAL)\n"
	cd tmp/kube-prometheus \
	&& $(JB) install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@$(KUBE_PROMETHEUS_VERSION)

tmp/kube-prometheus/jsonnetfile.json: | tmp/kube-prometheus $(JB)
	@printf "\n$(BOLD)Initialize Jsonnet bundle ...$(NORMAL)\n"
	cd tmp/kube-prometheus \
	&& rm -fr * \
	&& $(JB) init


tmp/kube-prometheus:
	mkdir -p $(@)

include $(CURDIR)/mk/ten.mk
