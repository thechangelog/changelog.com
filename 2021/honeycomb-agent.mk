HONEYCOMB_AGENT_RELEASES := https://github.com/honeycombio/helm-charts/releases
HONEYCOMB_AGENT_VERSION := 1.1.0
HONEYCOMB_AGENT_DIR := $(CURDIR)/tmp/honeycomb-agent-$(HONEYCOMB_AGENT_VERSION)

.PHONY: releases-honeycomb-agent
releases-honeycomb-agent:
	$(OPEN) $(HONEYCOMB_AGENT_RELEASES)

$(HONEYCOMB_AGENT_DIR):
	git clone \
	  --branch v$(HONEYCOMB_AGENT_VERSION)-honeycomb --single-branch --depth 1 \
	  https://github.com/honeycombio/helm-charts.git $(@)
tmp/honeycomb-agent: $(HONEYCOMB_AGENT_DIR)

HONEYCOMB_API_KEY = $$($(LPASS) show --notes Shared-changelog/secrets/HONEYCOMB_API_KEY)
lke-honeycomb-agent: | $(HONEYCOMB_AGENT_DIR) lke-ctx $(HELM) $(LPASS)
	$(HELM) upgrade honeycomb $(HONEYCOMB_AGENT_DIR)/charts/honeycomb \
	  --install \
	  --namespace honeycomb --create-namespace \
	  --values $(CURDIR)/manifests/honeycomb-agent.values.yml \
	  --set honeycomb.apiKey="$(HONEYCOMB_API_KEY)" \
	  --set metrics.clusterName=$(LKE_LABEL)

lke-bootstrap:: | lke-honeycomb-agent
