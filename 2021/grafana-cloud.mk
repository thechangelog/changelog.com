GRAFANA_CLOUD_NAMESPACE := grafana-cloud

GRAFANA_AGENT_RELEASES := https://github.com/grafana/agent/releases
#TODO: >0.13.0
GRAFANA_AGENT_VERSION :=  0.13.0+pr.497
GRAFANA_AGENT_DIR := $(CURDIR)/tmp/grafana-agent-$(GRAFANA_AGENT_VERSION)

#TODO: Update to a version that has the ServiceAccount namespace in grafana-agent-logs fixed
$(GRAFANA_AGENT_DIR):
	git clone https://github.com/grafana/agent.git $(@)
	cd $(@) && git checkout 9b5a94b22d9c471befcd5f2d2e9983fbc52e9507
# $(GRAFANA_AGENT_DIR):
# 	git clone \
# 	  --branch v$(GRAFANA_AGENT_VERSION) --single-branch --depth 1 \
# 	  https://github.com/grafana/agent.git $(GRAFANA_AGENT_DIR)
tmp/grafana-agent: $(GRAFANA_AGENT_DIR)

releases-grafana-agent:
	$(OPEN) $(GRAFANA_AGENT_RELEASES)

GRAFANA_AGENT_REMOTE_WRITE_URL := https://prometheus-us-central1.grafana.net/api/prom/push
.PHONY: lke-grafana-agent
lke-grafana-agent: | lke-ctx $(ENVSUBST) $(GRAFANA_AGENT_DIR)
	$(KUBECTL) get namespace $(GRAFANA_CLOUD_NAMESPACE) \
	|| $(KUBECTL) create namespace $(GRAFANA_CLOUD_NAMESPACE)
	export NAMESPACE=$(GRAFANA_CLOUD_NAMESPACE) \
	; export REMOTE_WRITE_USERNAME="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_REMOTE_WRITE_USERNAME)" \
	; export REMOTE_WRITE_PASSWORD="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_REMOTE_WRITE_PASSWORD)" \
	; export REMOTE_WRITE_URL=$(GRAFANA_AGENT_REMOTE_WRITE_URL) \
	; sed 's/$$1/$$$$1/g; s/$$3/$$$$3/g; s/$${1}/$$$${1}/g' $(CURDIR)/manifests/grafana-agent/agent.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) apply --filename -

GRAFANA_AGENT_LOKI_HOSTNAME := logs-prod-us-central1.grafana.net
.PHONY: lke-grafana-agent-loki
lke-grafana-agent-loki: | lke-ctx $(ENVSUBST) $(GRAFANA_AGENT_DIR)
	$(KUBECTL) get namespace $(GRAFANA_CLOUD_NAMESPACE) \
	|| $(KUBECTL) create namespace $(GRAFANA_CLOUD_NAMESPACE)
	export NAMESPACE=$(GRAFANA_CLOUD_NAMESPACE) \
	; export LOKI_USERNAME="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_LOKI_USERNAME)" \
	; export LOKI_PASSWORD="$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_LOKI_PASSWORD)" \
	; export LOKI_HOSTNAME=$(GRAFANA_AGENT_LOKI_HOSTNAME) \
	; sed 's/$$1/$$$$1/g' $(CURDIR)/manifests/grafana-agent/agent-loki.yml \
	| $(ENVSUBST_SAFE) \
	| $(KUBECTL) apply --filename -

.PHONY: lke-grafana-cloud
lke-grafana-cloud: lke-grafana-agent lke-grafana-agent-loki
lke-bootstrap:: lke-grafana-cloud

#TODO: combine metrics & logs grafana-agent into a single one
