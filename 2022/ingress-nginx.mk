INGRESS_NGINX_RELEASES := https://github.com/kubernetes/ingress-nginx/releases
INGRESS_NGINX_VERSION := 4.0.15
INGRESS_NGINX_DIR := $(CURDIR)/tmp/ingress-nginx-$(INGRESS_NGINX_VERSION)

$(INGRESS_NGINX_DIR):
	git clone \
	  --branch helm-chart-$(INGRESS_NGINX_VERSION) --single-branch --depth 1 \
	  https://github.com/kubernetes/ingress-nginx.git $(INGRESS_NGINX_DIR)
tmp/ingress-nginx: $(INGRESS_NGINX_DIR)

# Set to false if want the node public IP instead of a Node Balancer
INGRESS_NGINX_SERVICE ?= true
.PHONY: lke-ingress-nginx
lke-ingress-nginx: | $(INGRESS_NGINX_DIR) lke-ctx $(HELM)
	$(HELM) upgrade ingress-nginx $(INGRESS_NGINX_DIR)/charts/ingress-nginx \
	  --install \
	  --namespace ingress-nginx --create-namespace \
	  --values $(INGRESS_NGINX_DIR)/charts/ingress-nginx/values.yaml \
	  --set controller.dnsPolicy=ClusterFirstWithHostNet \
	  --set controller.hostNetwork=true \
	  --set controller.kind=DaemonSet \
	  --set controller.service.enabled=$(INGRESS_NGINX_SERVICE) \
	  --set controller.publishService.enabled=$(INGRESS_NGINX_SERVICE) \
	  --version $(INGRESS_NGINX_VERSION)
	$(KUBECTL) $(K_CMD) --filename $(CURDIR)/manifests/ingress-nginx
lke-bootstrap:: | lke-ingress-nginx

ifeq (true,$(INGRESS_NGINX_SERVICE))
define INGRESS_NGINX_SERVICE_EXTERNAL_IP
$$($(KUBECTL) get service ingress-nginx-controller \
	--namespace ingress-nginx \
	--output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
endef
else
INGRESS_NGINX_SERVICE_EXTERNAL_IP = 127.0.0.1
endif

.PHONY: releases-ingress-nginx
releases-ingress-nginx:
	$(OPEN) $(INGRESS_NGINX_RELEASES)
