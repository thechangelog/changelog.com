GRAFANA_CLOUD_NAMESPACE := grafana-cloud

.PHONY: lke-promtail
lke-promtail: | lke-ctx $(CURL) $(LPASS)
	curl -fsS https://raw.githubusercontent.com/grafana/loki/master/tools/promtail.sh \
	| sh -s 8521 "$$($(LPASS) show --notes 1212835959730479797)" logs-prod-us-central1.grafana.net default | kubectl apply --namespace=default -f  -

lke-provision:: lke-promtail

GRAFANA_AGENT_API_KEY := "$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_AGENT_API_KEY)"
.PHONY: lke-grafana-cloud
lke-grafana-cloud: | $(YTT) lke-ctx $(LPASS)
	$(YTT) \
	    --data-value namespace=$(GRAFANA_CLOUD_NAMESPACE) \
	    --data-value password=$(GRAFANA_AGENT_API_KEY) \
	    --file $(CURDIR)/k8s/grafana-cloud \
	| $(KUBECTL) apply --filename -
