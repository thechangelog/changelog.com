GRAFANA_AGENT_NAMESPACE := grafana-agent

GRAFANA_AGENT_RELEASES := https://github.com/grafana/agent/releases
GRAFANA_AGENT_VERSION := v0.22.0
GRAFANA_AGENT_DIR := $(CURDIR)/tmp/grafana-agent-$(GRAFANA_AGENT_VERSION)

$(GRAFANA_AGENT_DIR):
	git clone \
	  --branch $(GRAFANA_AGENT_VERSION) --single-branch --depth 1 \
	  https://github.com/grafana/agent $(GRAFANA_AGENT_DIR)
tmp/grafana-agent: $(GRAFANA_AGENT_DIR)

releases-grafana-agent:
	$(OPEN) $(GRAFANA_AGENT_RELEASES)

GRAFANA_AGENT_REMOTE_WRITE_URL := https://prometheus-us-central1.grafana.net/api/prom/push
GRAFANA_AGENT_LOKI_HOSTNAME := logs-prod-us-central1.grafana.net

.PHONY: lke-grafana-agent
lke-grafana-agent: GRAFANA_AGENT_DIR_MANIFEST = $(GRAFANA_AGENT_DIR)/production/kubernetes/agent-bare.yaml
lke-grafana-agent: _lke-grafana-agent
lke-bootstrap:: | lke-grafana-agent

.PHONY: lke-grafana-agent-logs
lke-grafana-agent-logs: GRAFANA_AGENT_DIR_MANIFEST = $(GRAFANA_AGENT_DIR)/production/kubernetes/agent-loki.yaml
lke-grafana-agent-logs: _lke-grafana-agent
lke-bootstrap:: | lke-grafana-agent-logs

.PHONY: _lke-grafana-agent
_lke-grafana-agent: | lke-ctx $(ENVSUBST) $(GRAFANA_AGENT_DIR)
	$(KUBECTL) get namespace $(GRAFANA_AGENT_NAMESPACE) || $(KUBECTL) create namespace $(GRAFANA_AGENT_NAMESPACE)
	export NAMESPACE=$(GRAFANA_AGENT_NAMESPACE) \
	; export CLUSTER_NAME=$(LKE_LABEL) \
	; export REMOTE_WRITE_USERNAME="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_REMOTE_WRITE_USERNAME)" \
	; export REMOTE_WRITE_PASSWORD="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_REMOTE_WRITE_PASSWORD)" \
	; export REMOTE_WRITE_URL=$(GRAFANA_AGENT_REMOTE_WRITE_URL) \
	; export LOKI_USERNAME="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_LOKI_USERNAME)" \
	; export LOKI_PASSWORD="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_LOKI_PASSWORD)" \
	; export LOKI_HOSTNAME=$(GRAFANA_AGENT_LOKI_HOSTNAME) \
	; sed 's/$$1/$$$$1/g; s/$$3/$$$$3/g; s/$${1}/$$$${1}/g' $(GRAFANA_AGENT_DIR_MANIFEST) $(CURDIR)/manifests/grafana-agent.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) $(K_CMD) --filename -

