GRAFANA_CLOUD_NAMESPACE := grafana-cloud
.PHONY: lke-promtail
lke-promtail: | lke-ctx $(CURL) $(LPASS)
	curl -fsS https://raw.githubusercontent.com/grafana/loki/master/tools/promtail.sh \
	| sh -s 8521 "$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_lke-prod-20200426)" logs-prod-us-central1.grafana.net default | kubectl apply --namespace=default -f  -

lke-provision:: lke-promtail

# helm search repo --versions prometheus-community/kube-prometheus-stack
# See k8s/kube--porometheus-stack/default-values.yml
KUBE_PROMETHEUS_STACK_VERSION ?= 12.8.0
KUBE_PROMETHEUS_STACK_NAMESPACE := kube-prometheus-stack
GRAFANA_CLOUD_URL = https://prometheus-us-central1.grafana.net/api/prom/push
GRAFANA_FQDN := grafana.changelog.com
GITHUB_ORG := thechangelog
# http://fabian-kostadinov.github.io/2015/01/16/how-to-find-a-github-team-id/
# https://github.com/settings/tokens
# curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/orgs/thechangelog/teams | view -c "set ft=json" -
GITHUB_TEAM_ID := 3796119
GITHUB_OAUTH_APP_CLIENT_ID := "$$($(LPASS) show --notes Shared-changelog/secrets/METRICS_GITHUB_OAUTH_APP_CLIENT_ID)"
GITHUB_OAUTH_APP_CLIENT_SECRET := "$$($(LPASS) show --notes Shared-changelog/secrets/METRICS_GITHUB_OAUTH_APP_CLIENT_SECRET)"

.PHONY: kube-prometheus-stack
kube-prometheus-stack: | lke-ctx grafana-cloud-lke-secret $(HELM) $(YTT)
	$(HELM) repo add prometheus-community https://prometheus-community.github.io/helm-charts
	$(YTT) \
	  --data-value namespace=$(KUBE_PROMETHEUS_STACK_NAMESPACE) \
	  --data-value fqdn=$(GRAFANA_FQDN) \
	  --data-value grafana_cloud.url=$(GRAFANA_CLOUD_URL) \
	  --data-value github.client_id=$(GITHUB_OAUTH_APP_CLIENT_ID) \
	  --data-value github.client_secret=$(GITHUB_OAUTH_APP_CLIENT_SECRET) \
	  --data-value github.allowed_organizations=$(GITHUB_ORG) \
	  --data-value github.team_ids=$(GITHUB_TEAM_ID) \
	  --file $(CURDIR)/k8s/kube-prometheus-stack/config.yml \
	  --file $(CURDIR)/k8s/kube-prometheus-stack/values.yml > $(CURDIR)/tmp/kube-prometheus-stack.values.yml
	$(HELM) upgrade prometheus prometheus-community/kube-prometheus-stack \
	  --install \
	  --version $(KUBE_PROMETHEUS_STACK_VERSION) \
	  --values $(CURDIR)/tmp/kube-prometheus-stack.values.yml \
	  --create-namespace \
	  --namespace $(KUBE_PROMETHEUS_STACK_NAMESPACE)

lke-provision:: kube-prometheus-stack

GRAFANA_CLOUD_USERNAME := "$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_USERNAME)"
GRAFANA_CLOUD_PASSWORD := "$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_CLOUD_PASSWORD)"
.PHONY: grafana-cloud
.PHONY: grafana-cloud-lke-secret
grafana-cloud-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(KUBE_PROMETHEUS_STACK_NAMESPACE) --dry-run --output=yaml \
	  create secret generic grafana-cloud \
	  --from-literal=username=$(GRAFANA_CLOUD_USERNAME) \
	  --from-literal=password=$(GRAFANA_CLOUD_PASSWORD) \
	| $(KUBECTL) apply --filename -
