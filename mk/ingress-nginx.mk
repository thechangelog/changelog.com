# https://github.com/kubernetes/ingress-nginx/releases
NGINX_INGRESS_VERSION := v0.34.1
NGINX_INGRESS_NAMESPACE := ingress-nginx
.PHONY: lke-ingress-nginx
lke-ingress-nginx: lke-ctx
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-$(NGINX_INGRESS_VERSION)/deploy/static/provider/cloud/deploy.yaml \
	&& $(KUBECTL) wait --namespace $(NGINX_INGRESS_NAMESPACE) --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/ingress-nginx \
	&& $(KUBECTL) scale --replicas=$(LKE_NODE_COUNT) deployment/ingress-nginx-controller --namespace $(NGINX_INGRESS_NAMESPACE) \
	&& $(KUBETREE) deployments ingress-nginx-controller --namespace $(NGINX_INGRESS_NAMESPACE) \
	&& $(KUBECTL) delete job ingress-nginx-admission-create ingress-nginx-admission-patch --namespace $(NGINX_INGRESS_NAMESPACE)
lke-provision:: lke-ingress-nginx

.PHONY: lke-ingress-nginx-verify
lke-ingress-nginx-verify: lke-ctx
	 $(KUBECTL) get pods --all-namespaces --selector app.kubernetes.io/name=ingress-nginx --watch
