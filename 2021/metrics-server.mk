METRICS_SERVER_RELEASES := https://github.com/kubernetes-sigs/metrics-server/releases
METRICS_SERVER_VERSION := v0.4.4

releases-metrics-server:
	$(OPEN) $(METRICS_SERVER_RELEASES)

# Add metrics-server for k9s pulses view to work fully
# TODO: replace gnu-sed with yq, ytt, or any tool that was BUILT to manipulate YAML
.PHONY: lke-metrics-server
lke-metrics-server: | lke-ctx
	$(CURL) --silent --location https://github.com/kubernetes-sigs/metrics-server/releases/download/$(METRICS_SERVER_VERSION)/components.yaml \
	| gsed '/- --secure-port/a\ \ \ \ \ \ \ \ - --kubelet-insecure-tls' \
	| $(KUBECTL) $(K_CMD) --filename -

lke-bootstrap:: | lke-metrics-server
