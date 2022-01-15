UP_RELEASES := https://cli.upbound.io/stable
UP_VERSION := 0.5.0
UP_BIN := up-$(UP_VERSION)-$(platform)-amd64
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

# 2022: https://cloud.upbound.io/changelogmedia/controlPlanes/d9a7a122-fafe-4c06-a170-d0ad543f371c
UPBOUND_CONTROLPLANE_ID := d9a7a122-fafe-4c06-a170-d0ad543f371c
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

CROSSPLANE_VERSION ?= 1.5.1
CROSSPLANE_NAMESPACE ?= crossplane-system
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
	@printf "\n$(BOLD)✅ Crossplane v$(CROSSPLANE_VERSION) installed!$(NORMAL)\n\n"

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
	; cat $(CURDIR)/manifests/crossplane/provider-jet-linode/provider.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) $(K_CMD) --filename -
	$(KUBECTL) wait --for=condition=healthy provider/jet-linode --timeout=60s --namespace $(CROSSPLANE_NAMESPACE)
	@printf "\n$(MAGENTA)Configuring Crossplane Provider Linode...$(NORMAL)\n"
	export NAMESPACE=$(CROSSPLANE_NAMESPACE) \
	; cat $(CURDIR)/manifests/crossplane/provider-jet-linode/provider-config.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) $(K_CMD) --filename -
	@printf "\n$(BOLD)✅ Crossplane Provider Linode $(CROSSPLANE_PROVIDER_LINODE_VERSION) installed!$(NORMAL)\n\n"

CROSSPLANE_LKE_NAME ?= lke-$(shell date -u +'%Y-%m-%d')
CROSSPLANE_LKE_K8S_VERSION ?= 1.22
CROSSPLANE_LKE_REGION ?= us-east
CROSSPLANE_LKE_WORKER_NODES_TYPE ?= g6-dedicated-8
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
	$(KUBECTL) wait --for=condition=ready clusters/$(CROSSPLANE_LKE_NAME) --timeout=180s
	@printf "\n✅ $(BOLD)$(CROSSPLANE_LKE_NAME)$(NORMAL) running K8s $(BOLD)v$(CROSSPLANE_LKE_K8S_VERSION)$(NORMAL) in $(BOLD)$(CROSSPLANE_LKE_REGION)$(NORMAL) with $(BOLD)$(CROSSPLANE_LKE_WORKER_NODES_COUNT)$(NORMAL) worker node(s) of type $(BOLD)$(CROSSPLANE_LKE_WORKER_NODES_TYPE)$(NORMAL) created!$(NORMAL)\n\n"

.PHONY: crossplane-lke-kubeconfig
crossplane-lke-kubeconfig: | $(KUBECTL)
	@printf "\n$(MAGENTA)Saving $(BOLD)$(CROSSPLANE_LKE_NAME)$(NORMAL)$(MAGENTA) LKE cluster config to $(BOLD)$(LKE_CONFIGS)/$(CROSSPLANE_LKE_NAME).yml$(NORMAL)$(MAGENTA)...$(NORMAL)\n"
	$(KUBECTL) get secret/$(CROSSPLANE_LKE_NAME) \
		--namespace $(CROSSPLANE_NAMESPACE) \
		--template={{.data.kubeconfig}} \
	| base64 --decode > $(LKE_CONFIGS)/$(CROSSPLANE_LKE_NAME).yml
	@printf "\n✅ To use this config, run $(BOLD)export KUBECONFIG=$(LKE_CONFIGS)/$(CROSSPLANE_LKE_NAME).yml$(NORMAL)\n"
