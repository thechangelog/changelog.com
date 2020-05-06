# https://github.com/jetstack/cert-manager/releases
CERT_MANAGER_VERSION := 0.14.3
CERT_MANAGER_NAMESPACE := cert-manager
.PHONY: lke-cert-manager
lke-cert-manager: lke-ctx
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/jetstack/cert-manager/v$(CERT_MANAGER_VERSION)/deploy/manifests/01-namespace.yaml \
	  --filename https://github.com/jetstack/cert-manager/releases/download/v$(CERT_MANAGER_VERSION)/cert-manager.yaml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/cert-manager/letsencrypt-staging.yml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/cert-manager/letsencrypt-prod.yml
lke-provision:: lke-cert-manager

# https://kubernetes.io/docs/reference/kubectl/jsonpath/
.PHONY: lke-cert-manager-verify
lke-cert-manager-verify: lke-ctx
	$(KUBECTL) apply \
	   --filename $(CURDIR)/k8s/cert-manager/test-resources.yml \
	&& $(KUBECTL) get certificate --namespace cert-manager-test --output=jsonpath='$(BOLD){"\n"}{.items[0].status.conditions[0].message}{"\n\n"}$(NORMAL)' \
	&& $(KUBECTL) get certificate --namespace cert-manager-test --output=yaml

.PHONY: lke-cert-manager-verify-clean
lke-cert-manager-verify-clean: lke-ctx
	$(KUBECTL) delete \
	   --filename $(CURDIR)/k8s/cert-manager/test-resources.yml

.PHONY: lke-cert-manager-logs
lke-cert-manager-logs: lke-ctx
	$(KUBECTL) logs deployments/cert-manager --namespace $(CERT_MANAGER_NAMESPACE) --follow
