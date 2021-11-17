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

# @lizthegrey: "Instead of boards, start from queries, and keep refining those until you find your answer"
define honeycomb_board_save
@printf "Adding Honeycomb board $(BOLD)$(1)$(NORMAL) to this repository... "
@$(CURL) --fail --location --silent https://api.honeycomb.io/1/boards/$(2) \
	--header "X-Honeycomb-Team: $(HONEYCOMB_API_KEY)" \
| $(JQ) . \
> $(CURDIR)/../priv/honeycomb_boards/$(1).json
@printf "$(BOLD)$(GREEN)OK!$(NORMAL)\n"
endef

honeycomb-boards-save:: | $(CURL) $(LPASS) $(JQ)

honeycomb-board-save-ingress-nginx:
	$(call honeycomb_board_save,ingress-nginx,qGFoG4oBrJ)
honeycomb-boards-save:: honeycomb-board-save-ingress-nginx

honeycomb-board-save-fastly-content-stats:
	$(call honeycomb_board_save,Fastly.Content.Stats,GBTjsTkY7A5)
honeycomb-boards-save:: honeycomb-board-save-fastly-content-stats

honeycomb-board-save-fastly-service-stats:
	$(call honeycomb_board_save,Fastly.Service.Stats,FX2Pg5y6NDw)
honeycomb-boards-save:: honeycomb-board-save-fastly-service-stats

# - [ ] Answer https://github.com/thechangelog/changelog.com/issues/383
# - [ ] Integrate CircleCI using https://circleci.com/developer/orbs/orb/honeycombio/buildevents
# - [ ] Integrate Phoenix using https://github.com/open-telemetry/opentelemetry-erlang-contrib/tree/main/instrumentation/opentelemetry_phoenix
# - [ ] Use derived columns in boards
#   	- time_elapsed_seconds in https://ui.honeycomb.io/changelog/datasets/fastly/schema
#   	- https://docs.honeycomb.io/working-with-your-data/customizing-your-query/derived-columns/reference/
#   	- https://www.honeycomb.io/resources/derived-columns/
