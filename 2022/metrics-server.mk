METRICS_SERVER_RELEASES := https://github.com/kubernetes-sigs/metrics-server/releases
METRICS_SERVER_VERSION := 3.7.0
METRICS_SERVER_DIR := $(CURDIR)/tmp/metrics-server-$(METRICS_SERVER_VERSION)

$(METRICS_SERVER_DIR):
	git clone \
	  --branch metrics-server-helm-chart-$(METRICS_SERVER_VERSION) --single-branch --depth 1 \
	  https://github.com/kubernetes-sigs/metrics-server $(METRICS_SERVER_DIR)
tmp/metrics-server: $(METRICS_SERVER_DIR)

# Add metrics-server for k9s pulses view to work fully
.PHONY: lke-metrics-server
lke-metrics-server: | $(METRICS_SERVER_DIR) lke-ctx $(HELM)
	$(HELM) upgrade metrics-server $(METRICS_SERVER_DIR)/charts/metrics-server \
	  --install \
	  --namespace metrics-server --create-namespace \
	  --values $(METRICS_SERVER_DIR)/charts/metrics-server/values.yaml \
	  --set args[0]=--kubelet-insecure-tls \
	  --version $(METRICS_SERVER_VERSION)
lke-bootstrap:: | lke-metrics-server

.PHONY: releases-metrics-server
releases-metrics-server:
	$(OPEN) $(METRICS_SERVER_RELEASES)
