GRAFANA_AGENT_NAMESPACE := grafana-agent

GRAFANA_AGENT_RELEASES := https://github.com/grafana/agent/releases
GRAFANA_AGENT_VERSION :=  0.14.0-rc.2
GRAFANA_AGENT_DIR := $(CURDIR)/tmp/grafana-agent-$(GRAFANA_AGENT_VERSION)

$(GRAFANA_AGENT_DIR):
	git clone \
	  --branch v$(GRAFANA_AGENT_VERSION) --single-branch --depth 1 \
	  https://github.com/grafana/agent.git $(GRAFANA_AGENT_DIR)
tmp/grafana-agent: $(GRAFANA_AGENT_DIR)

releases-grafana-agent:
	$(OPEN) $(GRAFANA_AGENT_RELEASES)

GRAFANA_AGENT_REMOTE_WRITE_URL := https://prometheus-us-central1.grafana.net/api/prom/push
GRAFANA_AGENT_LOKI_HOSTNAME := logs-prod-us-central1.grafana.net
OP ?= apply
.PHONY: lke-grafana-agent
lke-grafana-agent: | lke-ctx $(ENVSUBST) $(GRAFANA_AGENT_DIR)
	export NAMESPACE=$(GRAFANA_AGENT_NAMESPACE) \
	; export GRAFANA_AGENT_VERSION=$(GRAFANA_AGENT_VERSION) \
	; export REMOTE_WRITE_USERNAME="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_REMOTE_WRITE_USERNAME)" \
	; export REMOTE_WRITE_PASSWORD="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_REMOTE_WRITE_PASSWORD)" \
	; export REMOTE_WRITE_URL=$(GRAFANA_AGENT_REMOTE_WRITE_URL) \
	; export LOKI_USERNAME="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_LOKI_USERNAME)" \
	; export LOKI_PASSWORD="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_LOKI_PASSWORD)" \
	; export LOKI_HOSTNAME=$(GRAFANA_AGENT_LOKI_HOSTNAME) \
	; sed 's/$$1/$$$$1/g; s/$$3/$$$$3/g; s/$${1}/$$$${1}/g' $(CURDIR)/manifests/grafana-agent/agent+loki.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) $(OP) --filename -
