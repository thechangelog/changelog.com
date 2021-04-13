INGRESS_NGINX_RELEASES := https://github.com/kubernetes/ingress-nginx/releases
INGRESS_NGINX_VERSION := 3.29.0
INGRESS_NGINX_DIR := $(CURDIR)/tmp/ingress-nginx-$(INGRESS_NGINX_VERSION)

$(INGRESS_NGINX_DIR):
	git clone \
	  --branch helm-chart-$(INGRESS_NGINX_VERSION) --single-branch --depth 1 \
	  https://github.com/kubernetes/ingress-nginx.git $(INGRESS_NGINX_DIR)
tmp/ingress-nginx: $(INGRESS_NGINX_DIR)

.PHONY: lke-ingress-nginx
lke-ingress-nginx: | $(INGRESS_NGINX_DIR) lke-ctx $(HELM)
	$(HELM) upgrade ingress-nginx $(INGRESS_NGINX_DIR)/charts/ingress-nginx \
	  --install \
	  --namespace ingress-nginx --create-namespace \
	  --values $(INGRESS_NGINX_DIR)/charts/ingress-nginx/values.yaml \
	  --set controller.dnsPolicy=ClusterFirstWithHostNet \
	  --set controller.hostNetwork=true \
	  --set controller.kind=DaemonSet \
	  --version $(INGRESS_NGINX_VERSION)
	$(KUBECTL) apply --filename $(CURDIR)/manifests/ingress-nginx
lke-bootstrap:: lke-ingress-nginx

.PHONY: releases-ingress-nginx
releases-ingress-nginx:
	$(OPEN) $(INGRESS_NGINX_RELEASES)
