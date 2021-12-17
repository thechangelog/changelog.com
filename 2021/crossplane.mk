UP_RELEASES := https://cli.upbound.io/stable
UP_VERSION := 0.5.0
UP_BIN := up-$(UP_VERSION)-$(platform)-amd64
https://cli.upbound.io/stable/v0.5.0/bin/darwin_amd64/up
UP_URL := $(UP_RELEASES)/v$(UP_VERSION)/bin/$(platform)_amd64/up
UP := $(LOCAL_BIN)/$(UP_BIN)
$(UP): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(UP) "$(UP_URL)"
	touch $(UP)
	chmod +x $(UP)
	$(UP) --version | grep $(UP_VERSION)
	ln -sf $(UP) $(LOCAL_BIN)/up
.PHONY: up
up: $(UP)
.PHONY: releases-up
releases-up:
	$(OPEN) $(UP_RELEASES)

# christmas-2021-gift: https://cloud.upbound.io/changelogmedia/controlPlanes/bd465974-fb45-47a4-b9a5-001db23c89c8
UPBOUND_CONTROLPLANE_ID := bd465974-fb45-47a4-b9a5-001db23c89c8
UPBOUND_KUBECONFIG := $(XDG_CONFIG_HOME)/upbound.$(UPBOUND_CONTROLPLANE_ID).yml
UPBOUND_CONTROLPLANE_NAMESPACE := upbound-system
$(UPBOUND_KUBECONFIG):
	touch $(UPBOUND_KUBECONFIG)

env:: | $(LPASS)
	@$(LPASS) status --quiet \
	|| ( printf "$(RED)LastPass session expired, run $(BOLD)lpass login <YOUR_EMAIL_ADDRESS>$(NORMAL)\n" ; exit 1 )
	@echo 'export UP_TOKEN="$(shell $(LPASS) show --notes Shared-changelog/secrets/UPBOUND_CLOUD_USER_TOKEN)"'
	@echo 'export UP_ACCOUNT="changelogmedia"'
	@echo 'export UP_PROFILE="default"'

$(HOME)/.up/config.json: | $(UP)
	$(UP) login

.PHONY: up-connect
up-connect: $(HOME)/.up/config.json $(UPBOUND_KUBECONFIG)
ifndef UP_TOKEN
	$(call env_not_set,UP_TOKEN)
endif
	@printf "Connecting to Upbound Cloud Control Plane $(BOLD)$(UPBOUND_CONTROLPLANE_ID)$(NORMAL) ... "
	@KUBECONFIG=$(UPBOUND_KUBECONFIG) $(UP) controlplane kubeconfig get \
		   --token=$(UP_TOKEN) $(UPBOUND_CONTROLPLANE_ID)
	@printf "$(BOLD)$(GREEN)OK!$(NORMAL)\n"
	@printf "To use this control plane, run: $(BOLD)export KUBECONFIG=$(UPBOUND_KUBECONFIG)$(NORMAL)\n"

# STORY ########################################################################
#
# 1. Why did we do this?
# - We wanted our Kubernetes clusters to not be provisioned via UI or CLI.
# - We wanted to apply a config and have the cluster be continuously reconciled
# - If one of us accidentally deletes it, the cluster should be automatically re-created and everything restored
#
# 2. How did we do this?
# - We mentioned in episode 15 about wanting to make Crossplane part of the Changelog 2022 setup
# - We are running our Kubernetes clusters of Linode, and there is no Crossplane provider for Linode that works + Marques
# - We have heard of this new and easy ways of generating new Crossplane providers: Terrajet
# - Muvaffak Onus is here today to tells us about it!
#   - Why did you create Terrajet?
#   - How many providers have been generated with Terrajet?
#   - What is coming next for Terrajet?
# - We generated a new Linode Provider using Terrajet which is now in crossplane-contrib
# - Anyone can use this provider to have Crossplane manage K8s clusters on Linode (a.k.a. LKE)
#
# 3. This is how we are doing it
# - Install Crossplane
# - Install Provider
# - Provision LKE cluster with Provider
# - Target LKE cluster
# - What happens if someone "accidentally" deletes a cluster? 😎
#
# 4. What happens next?
# - Install everything that is needed on the LKE cluster using a Composition
#   - base composition:
#     - grafana-agent (sed + envsubst + kubectl)
#     - honeycomb-agent (helm)
#     - metrics-server (curl + gsed + kubectl)
#     - external-dns (envsubst + kubectl)
#     - cert-manager (helm)
#     - ingress-nginx (helm)
#     - local-path-provisioner (helm)
#     - keel (helm)
#   - changelog composition (envsubst + kubectl)
# - Move Crossplane to Upbound Cloud
#   - developer consoles
#   - UI
#   - team permissions
#   - compositions
CROSSPLANE_VERSION := 1.5.1
CROSSPLANE_NAMESPACE := crossplane-system
CROSSPLANE_RELEASES := https://charts.crossplane.io/stable
.PHONY: lke-crossplane
lke-crossplane: | lke-ctx $(HELM)
	@printf "\n$(MAGENTA)Installing Crossplane v$(CROSSPLANE_VERSION)...$(NORMAL)\n"
	$(HELM) repo add crossplane-stable $(CROSSPLANE_RELEASES)
	$(HELM) repo update
	$(HELM) upgrade crossplane crossplane-stable/crossplane \
		--install \
		--namespace $(CROSSPLANE_NAMESPACE) --create-namespace \
		--version $(CROSSPLANE_VERSION) \
		--wait

lke-bootstrap:: | lke-crossplane

.PHONY: releases-crossplane
releases-crossplane:
	$(OPEN) $(CROSSPLANE_RELEASES)

# Given:
# - a host with Docker installed:
# - a clone of https://github.com/crossplane-contrib/provider-jet-linode
#
# Run the following commands:
# make generate
# make build PLATFORMS=linux_amd64 DOCKER_REGISTRY=thechangelog
# make publish PLATFORMS=linux_amd64 DOCKER_REGISTRY=thechangelog
#
# And now re-tag both images without -amd64, e.g.
# docker tag build-d25cec7d/provider-jet-linode-controller-amd64 thechangelog/provider-jet-linode-controller:v0.0.0-8.g79d76b3
# docker push thechangelog/provider-jet-linode-controller:v0.0.0-8.g79d76b3
# docker tag build-d25cec7d/provider-jet-linode-amd64 thechangelog/provider-jet-linode:v0.0.0-8.g79d76b3
# docker push thechangelog/provider-jet-linode:v0.0.0-8.g79d76b3
#
# Update the provider version below:
CROSSPLANE_PROVIDER_LINODE_VERSION := v0.0.0-12.ge4dcf7e
.PHONY: crossplane-linode-provider
crossplane-linode-provider: | lke-ctx
	@printf "\n$(MAGENTA)Adding Linode Token...$(NORMAL)\n"
	$(KUBECTL) create secret generic linode \
	  --from-literal=token="$$($(LPASS) show --notes Shared-changelog/secrets/LINODE_CLI_TOKEN)" --dry-run=client --output json \
	| $(KUBECTL) $(K_CMD) --namespace $(CROSSPLANE_NAMESPACE) --filename -
	@printf "\n$(MAGENTA)Installing Crossplane Provider Linode v$(CROSSPLANE_PROVIDER_LINODE_VERSION)...$(NORMAL)\n"
	export NAMESPACE=$(CROSSPLANE_NAMESPACE) \
	; export PROVIDER_LINODE_VERSION=$(CROSSPLANE_PROVIDER_LINODE_VERSION) \
	; cat $(CURDIR)/manifests/crossplane/provider-jet-linode/{controller-config,provider}.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) $(K_CMD) --filename -
	$(KUBECTL) wait --for=condition=healthy provider/jet-linode --timeout=60s --namespace $(CROSSPLANE_NAMESPACE)
	@printf "\n$(MAGENTA)Configuring Crossplane Provider Linode...$(NORMAL)\n"
	export NAMESPACE=$(CROSSPLANE_NAMESPACE) \
	; cat $(CURDIR)/manifests/crossplane/provider-jet-linode/provider-config.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) $(K_CMD) --filename -

CROSSPLANE_LKE_NAME ?= lke-$(shell date -u +'%Y-%m-%d')
CROSSPLANE_LKE_K8S_VERSION ?= 1.22
CROSSPLANE_LKE_REGION ?= us-east
CROSSPLANE_LKE_WORKER_NODES_TYPE ?= g6-dedicated-4
CROSSPLANE_LKE_WORKER_NODES_COUNT ?= 1
CROSSPLANE_RUNNING_IN ?= $(LKE_LABEL)
.PHONY: crossplane-lke
crossplane-lke: | $(KUBECTL)
	@printf "\n$(MAGENTA)Creating $(BOLD)$(CROSSPLANE_LKE_NAME)$(NORMAL)$(MAGENTA) running K8s $(BOLD)v$(CROSSPLANE_LKE_K8S_VERSION)$(NORMAL)$(MAGENTA) in $(BOLD)$(CROSSPLANE_LKE_REGION)$(NORMAL) ...$(NORMAL)\n"
	export NAME=$(CROSSPLANE_LKE_NAME) \
	; export NAMESPACE=$(CROSSPLANE_NAMESPACE) \
	; export K8S_VERSION=$(CROSSPLANE_LKE_K8S_VERSION) \
	; export REGION=$(CROSSPLANE_LKE_REGION) \
	; export WORKER_NODES_COUNT=$(CROSSPLANE_LKE_WORKER_NODES_COUNT) \
	; export WORKER_NODES_TYPE=$(CROSSPLANE_LKE_WORKER_NODES_TYPE) \
	; export CROSSPLANE_RUNNING_IN=$(CROSSPLANE_RUNNING_IN) \
	; export CROSSPLANE_VERSION=$(CROSSPLANE_VERSION) \
	; export PROVIDER_LINODE_VERSION=$(CROSSPLANE_PROVIDER_LINODE_VERSION) \
	; cat $(CURDIR)/manifests/crossplane/lke.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) $(K_CMD) --filename -

.PHONY: crossplane-lke-kubeconfig
crossplane-lke-kubeconfig: | $(KUBECTL)
	@printf "\n$(MAGENTA)Saving $(BOLD)$(CROSSPLANE_LKE_NAME)$(NORMAL)$(MAGENTA) LKE cluster config to $(BOLD)$(LKE_CONFIGS)/$(CROSSPLANE_LKE_NAME).yml$(NORMAL)$(MAGENTA)...$(NORMAL)\n"
	$(KUBECTL) get secret/$(CROSSPLANE_LKE_NAME) \
		--namespace $(CROSSPLANE_NAMESPACE) \
		--template={{.data.kubeconfig}} \
	| base64 --decode > $(LKE_CONFIGS)/$(CROSSPLANE_LKE_NAME).yml
	@printf "\nTo use this config, run $(BOLD)export KUBECONFIG=$(LKE_CONFIGS)/$(CROSSPLANE_LKE_NAME).yml$(NORMAL)\n"
