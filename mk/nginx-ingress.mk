# https://github.com/kubernetes/ingress-nginx/releases
NGINX_INGRESS_VERSION := v0.34.1
NGINX_INGRESS_NAMESPACE := ingress-nginx
.PHONY: lke-nginx-ingress
lke-nginx-ingress: lke-ctx
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-$(NGINX_INGRESS_VERSION)/deploy/static/provider/cloud/deploy.yaml \
	&& $(KUBECTL) wait --namespace $(NGINX_INGRESS_NAMESPACE) --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s \
	&& $(KUBECTL) scale --replicas=$(LKE_NODE_COUNT) deployment/ingress-nginx-controller --namespace $(NGINX_INGRESS_NAMESPACE) \
	&& $(KUBETREE) deployments ingress-nginx-controller --namespace $(NGINX_INGRESS_NAMESPACE) \
	&& $(KUBECTL) delete job ingress-nginx-admission-create ingress-nginx-admission-patch
lke-provision:: lke-nginx-ingress

.PHONY: lke-nginx-ingress-verify
lke-nginx-ingress-verify: lke-ctx
	 $(KUBECTL) get pods --all-namespaces --selector app.kubernetes.io/name=ingress-nginx --watch

.PHONY: lke-nginx-ingress-logs
lke-nginx-ingress-logs: lke-ctx
	$(KUBECTL) logs deployments/ingress-nginx-controller --namespace $(NGINX_INGRESS_NAMESPACE) --follow
