CERT_DOMAIN := changelog.com
CERT_EMAIL := services@changelog.com

# https://github.com/jetstack/cert-manager/releases
CERT_MANAGER_VERSION := 0.14.3
CERT_MANAGER_NAMESPACE := cert-manager
.PHONY: lke-cert-manager
lke-cert-manager: | lke-ctx
	$(KUBECTL) apply \
	  --filename https://raw.githubusercontent.com/jetstack/cert-manager/v$(CERT_MANAGER_VERSION)/deploy/manifests/01-namespace.yaml \
	  --filename https://github.com/jetstack/cert-manager/releases/download/v$(CERT_MANAGER_VERSION)/cert-manager.yaml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/cert-manager/letsencrypt-staging.yml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/cert-manager/letsencrypt-prod.yml
lke-provision:: lke-cert-manager

# https://kubernetes.io/docs/reference/kubectl/jsonpath/
.PHONY: lke-cert-manager-verify
lke-cert-manager-verify: | lke-ctx
	$(KUBECTL) apply \
	   --filename $(CURDIR)/k8s/cert-manager/test-resources.yml \
	&& $(KUBECTL) get certificate --namespace cert-manager-test --output=jsonpath='$(BOLD){"\n"}{.items[0].status.conditions[0].message}{"\n\n"}$(NORMAL)' \
	&& $(KUBECTL) get certificate --namespace cert-manager-test --output=yaml

.PHONY: lke-cert-manager-verify-clean
lke-cert-manager-verify-clean: | lke-ctx
	$(KUBECTL) delete \
	   --filename $(CURDIR)/k8s/cert-manager/test-resources.yml

.PHONY: lke-cert-manager-logs
lke-cert-manager-logs: lke-ctx
	$(KUBECTL) logs deployments/cert-manager --namespace $(CERT_MANAGER_NAMESPACE) --follow

# https://github.com/neoskop/cert-manager-webhook-dnsimple/releases
CERT_MANAGER_DNSIMPLE_VERSION := 0.0.4
define CERT_MANAGER_DNSIMPLE
cert-manager-webhook-dnsimple \
  --namespace $(CERT_MANAGER_NAMESPACE) \
  --set dnsimple.account=$(DNSIMPLE_ACCOUNT) \
  --set dnsimple.token=$(DNSIMPLE_TOKEN) \
  --set clusterIssuer.production.enabled=true \
  --set clusterIssuer.staging.enabled=true \
  --set clusterIssuer.email=$(CERT_EMAIL) \
  --set groupName=$(CERT_DOMAIN) \
  --version $(CERT_MANAGER_DNSIMPLE_VERSION) \
  --debug \
  --wait \
  neoskop/cert-manager-webhook-dnsimple
endef
.PHONY: lke-cert-manager-dnsimple
lke-cert-manager-dnsimple: | lke-ctx $(HELM) dnsimple-creds
	$(HELM) repo add neoskop https://charts.neoskop.dev \
	&& ( $(HELM) install $(CERT_MANAGER_DNSIMPLE) \
	     || $(HELM) upgrade $(CERT_MANAGER_DNSIMPLE) )
lke-provision:: lke-cert-manager-dnsimple

.PHONY: lke-cert-manager-dnsimple-info
lke-cert-manager-dnsimple-info: | lke-ctx $(HELM)
	$(HELM) show all neoskop/cert-manager-webhook-dnsimple

.PHONY: lke-cert-manager-dnsimple-test
lke-cert-manager-dnsimple-test: | lke-ctx $(HELM)
	$(HELM) test cert-manager-webhook-dnsimple \
	  --namespace $(CERT_MANAGER_NAMESPACE) \
	  --debug

.PHONY: lke-cert-manager-dnsimple-status
lke-cert-manager-dnsimple-status: | lke-ctx $(HELM)
	$(HELM) status cert-manager-webhook-dnsimple \
	  --namespace $(CERT_MANAGER_NAMESPACE) \
	&& $(HELM) list --namespace $(CERT_MANAGER_NAMESPACE)
