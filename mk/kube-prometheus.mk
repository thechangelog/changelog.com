# k delete -f tmp/kube-prometheus/manifests
# If deleting namespace gets stuck: https://github.com/kubernetes/kubernetes/issues/60807#issuecomment-572615776
METRICS_NAMESPACE := metrics
.PHONY: lke-metrics
lke-metrics: | lke-ctx kube-prometheus $(YTT)
	$(KUBECTL) apply --filename tmp/kube-prometheus/manifests/setup \
	&& $(KUBECTL) apply --filename tmp/kube-prometheus/manifests \
	&& $(YTT) \
	    --data-value namespace=$(METRICS_NAMESPACE) \
	    --file $(CURDIR)/k8s/metrics-changelog > $(CURDIR)/k8s/metrics-changelog.yml \
	&& $(KUBECTL) apply --filename k8s/metrics-changelog.yml
lke-provision:: lke-metrics

# https://github.com/coreos/kube-prometheus#compatibility
KUBE_PROMETHEUS_VERSION := master
ifeq ($(LKE_VERSION),1.16)
KUBE_PROMETHEUS_VERSION := release-0.4
endif
ifneq ($(filter $(LKE_VERSION), 1.17 1.18),)
KUBE_PROMETHEUS_VERSION := release-0.5
endif
.PHONY: kube-prometheus
kube-prometheus: tmp/kube-prometheus/manifests

.PHONY: kube-prometheus-update
kube-prometheus-update: | tmp/kube-prometheus/jsonnetfile.lock.json $(JB)
	@printf "\n$(BOLD)Update kube-prometheus@$(KUBE_PROMETHEUS_VERSION) ...$(NORMAL)\n"
	cd tmp/kube-prometheus \
	&& $(JB) update

METRICS_GITHUB_ORG := thechangelog
# http://fabian-kostadinov.github.io/2015/01/16/how-to-find-a-github-team-id/
# https://github.com/settings/tokens
# curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/orgs/thechangelog/teams | view -c "set ft=json" -
METRICS_GITHUB_TEAM_ID := 3796119
METRICS_ROOT_URL := https://metrics.changelog.com
tmp/kube-prometheus/manifests: k8s/kube-prometheus.jsonnet | tmp/kube-prometheus/jsonnetfile.lock.json $(JSONNET) $(LPASS) $(YQ)
	@printf "\n$(BOLD)Generate kube-prometheus manifests ...$(NORMAL)\n"
	cd tmp/kube-prometheus \
	&& rm -fr manifests \
	&& mkdir -p manifests/setup \
	&& $(JSONNET) \
		  --jpath vendor \
		  --multi manifests \
		  --ext-str NAMESPACE="$(METRICS_NAMESPACE)" \
		  --ext-str GITHUB_OAUTH_APP_CLIENT_ID="$$($(LPASS) show --notes 6262503396338294422)" \
		  --ext-str GITHUB_OAUTH_APP_CLIENT_SECRET="$$($(LPASS) show --notes 6396745408918286971)" \
		  --ext-str GITHUB_ORG=$(METRICS_GITHUB_ORG) \
		  --ext-str GITHUB_TEAM_ID=$(METRICS_GITHUB_TEAM_ID) \
		  --ext-str ROOT_URL=$(METRICS_ROOT_URL) \
		  $(CURDIR)/k8s/kube-prometheus.jsonnet \
	   | while read file; do $(YQ) read --prettyPrint $$file > $$file.yml && rm $$file; done

tmp/kube-prometheus/jsonnetfile.lock.json: | tmp/kube-prometheus/jsonnetfile.json $(JB)
	@printf "\n$(BOLD)Install kube-prometheus@$(KUBE_PROMETHEUS_VERSION) ...$(NORMAL)\n"
	cd tmp/kube-prometheus \
	&& $(JB) install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@$(KUBE_PROMETHEUS_VERSION)

tmp/kube-prometheus/jsonnetfile.json: | tmp/kube-prometheus $(JB)
	@printf "\n$(BOLD)Initialize Jsonnet bundle ...$(NORMAL)\n"
	cd tmp/kube-prometheus \
	&& rm -fr * \
	&& $(JB) init

tmp/kube-prometheus:
	mkdir -p $(@)
