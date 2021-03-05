INGRESS_NGINX_RELEASES := https://github.com/kubernetes/ingress-nginx/releases
INGRESS_NGINX_VERSION := v0.44.0
INGRESS_NGINX_NAMESPACE := ingress-nginx
.PHONY: lke-ingress-nginx
lke-ingress-nginx: lke-ctx
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-$(INGRESS_NGINX_VERSION)/deploy/static/provider/cloud/deploy.yaml
	@printf "$(BOLD)Wait for the SSL certificate used by the admission webhook to be created...$(NORMAL)\n"
	$(KUBECTL) wait --namespace $(INGRESS_NGINX_NAMESPACE) --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
	$(KUBECTL) apply --filename $(CURDIR)/manifests/ingress-nginx

.PHONY: releases-ingress-nginx
releases-ingress-nginx:
	$(OPEN) $(INGRESS_NGINX_RELEASES)
