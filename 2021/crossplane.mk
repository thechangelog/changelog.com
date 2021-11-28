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

# christmas-2021-gift:
# https://cloud.upbound.io/changelogmedia/controlPlanes/bd465974-fb45-47a4-b9a5-001db23c89c8
UPBOUND_CONTROLPLANE_ID := bd465974-fb45-47a4-b9a5-001db23c89c8
UPBOUND_KUBECONFIG := $(XDG_CONFIG_HOME)/upbound.$(UPBOUND_CONTROLPLANE_ID).yml
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

up_connect: $(HOME)/.up/config.json $(UPBOUND_KUBECONFIG)
ifndef UP_TOKEN
	$(call env_not_set,UP_TOKEN)
endif
	@printf "Connecting to Upbound Cloud Control Plane $(BOLD)$(UPBOUND_CONTROLPLANE_ID)$(NORMAL) ... "
	@KUBECONFIG=$(UPBOUND_KUBECONFIG) $(UP) controlplane kubeconfig get \
		   --token=$(UP_TOKEN) $(UPBOUND_CONTROLPLANE_ID)
	@printf "$(BOLD)$(GREEN)OK!$(NORMAL)\n"
	@printf "To use this control plane, run: $(BOLD)export KUBECONFIG=$(UPBOUND_KUBECONFIG)$(NORMAL)\n"
