TRAEFIK_RELEASES := https://github.com/traefik/traefik-helm-chart/releases
# Chart 9.20.1 and below is compatible with K8s v1.16 - v1.21
# Chart 10 and above is compatible with K8s v1.22 and above
TRAEFIK_VERSION := 9.20.1
TRAEFIK_DIR := $(CURDIR)/tmp/traefik-$(TRAEFIK_VERSION)

$(TRAEFIK_DIR):
	git clone \
	  --branch v$(TRAEFIK_VERSION) --single-branch --depth 1 \
	  https://github.com/traefik/traefik-helm-chart.git $(TRAEFIK_DIR)
tmp/traefik: $(TRAEFIK_DIR)

lke-traefik: | $(TRAEFIK_DIR) lke-ctx $(HELM)
	$(HELM) upgrade traefik $(TRAEFIK_DIR)/traefik \
	  --install \
	  --namespace traefik --create-namespace \
	  --values $(TRAEFIK_DIR)/traefik/values.yaml \
	  --set hostNetwork=true \
	  --set deployment.kind=DaemonSet \
	  --set deployment.dnsPolicy=ClusterFirstWithHostNet \
	  --set logs.access.enabled=true \
	  --set logs.access.format=json \
	  --set additionalArguments[0]="--metrics.prometheus=true"

lke-bootstrap:: | lke-traefik

.PHONY: releases-traefik
releases-traefik:
	$(OPEN) $(TRAEFIK_RELEASES)
