# https://github.com/kubernetes/ingress-nginx/releases
NGINX_INGRESS_VERSION := 0.32.0
NGINX_INGRESS_NAMESPACE := ingress-nginx
.PHONY: lke-nginx-ingress
lke-nginx-ingress: lke-ctx
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-$(NGINX_INGRESS_VERSION)/deploy/static/provider/cloud/deploy.yaml \
	&& $(KUBECTL) scale --replicas=$(LKE_NODE_COUNT) deployment/ingress-nginx-controller --namespace $(NGINX_INGRESS_NAMESPACE) \
	&& $(KUBETREE) deployments ingress-nginx-controller --namespace $(NGINX_INGRESS_NAMESPACE)
lke-provision:: lke-nginx-ingress

.PHONY: lke-nginx-ingress-verify
lke-nginx-ingress-verify: lke-ctx
	 $(KUBECTL) get pods --all-namespaces --selector app.kubernetes.io/name=ingress-nginx --watch

.PHONY: lke-nginx-ingress-logs
lke-nginx-ingress-logs: lke-ctx
	$(KUBECTL) logs deployments/ingress-nginx-controller --namespace $(NGINX_INGRESS_NAMESPACE) --follow
