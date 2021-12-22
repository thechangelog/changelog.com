PARCA_SERVER_RELEASES := https://github.com/parca-dev/parca/releases
PARCA_SERVER_VERSION := 0.6.1

PARCA_AGENT_RELEASES := https://github.com/parca-dev/parca-agent/releases
PARCA_AGENT_VERSION := 0.3.0

.PHONY: lke-parca
lke-parca: | lke-ctx
	@printf "$(BOLD)PARCA ::: $(RESET)$(MAGENTA)Creating namespace to avoid any race conditions...$(RESET)\n"
	$(KUBECTL) get namespace parca || $(KUBECTL) create namespace parca
	@printf "\n$(BOLD)PARCA ::: $(RESET)$(MAGENTA)Installing agent...$(RESET)\n"
	$(KUBECTL) $(K_CMD) --filename https://github.com/parca-dev/parca-agent/releases/download/v$(PARCA_AGENT_VERSION)/kubernetes-manifest.yaml
	@printf "\n$(BOLD)PARCA ::: $(RESET)$(MAGENTA)Installing server...$(RESET)\n"
	$(KUBECTL) $(K_CMD) --filename https://github.com/parca-dev/parca/releases/download/v$(PARCA_SERVER_VERSION)/kubernetes-manifest.yaml
	@printf "\n$(BOLD)PARCA ::: $(RESET)$(MAGENTA)Limiting server CPU & memory...$(RESET)\n"
	$(KUBECTL) patch deploy parca --namespace parca --patch-file manifests/parca/server-limits.patch.yml
lke-bootstrap:: | lke-parca
