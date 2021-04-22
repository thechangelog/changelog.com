CERT_DOMAIN := changelog.com
CERT_EMAIL := services@changelog.com

CERT_MANAGER_RELEASES := https://github.com/jetstack/cert-manager/releases
CERT_MANAGER_VERSION := 1.3.1
CERT_MANAGER_NAMESPACE := cert-manager
.PHONY: lke-cert-manager
lke-cert-manager: | lke-ctx
	$(KUBECTL) apply --filename $(CERT_MANAGER_RELEASES)/download/v$(CERT_MANAGER_VERSION)/cert-manager.yaml
lke-bootstrap:: lke-cert-manager

releases-cert-manager:
	$(OPEN) $(CERT_MANAGER_RELEASES)

.PHONY: lke-cert-manager-verify
lke-cert-manager-verify: | lke-ctx
	$(KUBECTL) apply --filename $(CURDIR)/manifests/cert-manager/test-resources.yml
	$(KUBECTL) wait --namespace cert-manager-test --for=condition=ready certificate/selfsigned-cert --timeout=10s
	$(KUBECTL) get certificate --namespace cert-manager-test --output=jsonpath='$(BOLD){"\n"}{.items[0].status.conditions[0].message}{"\n\n"}$(NORMAL)'
	$(KUBECTL) get certificate --namespace cert-manager-test --output=yaml

.PHONY: lke-cert-manager-verify-clean
lke-cert-manager-verify-clean: | lke-ctx
	$(KUBECTL) delete --filename $(CURDIR)/manifests/cert-manager/test-resources.yml --ignore-not-found

# https://github.com/neoskop/cert-manager-webhook-dnsimple/releases
CERT_MANAGER_DNSIMPLE_VERSION := 0.1.0
.PHONY: lke-cert-manager-dnsimple
lke-cert-manager-dnsimple: | lke-ctx $(HELM)
	$(HELM) repo add neoskop https://charts.neoskop.dev
	$(HELM) repo update
	DNSIMPLE_ACCOUNT="$$($(LPASS) show --notes Shared-changelog/secrets/DNSIMPLE_ACCOUNT)" \
	DNSIMPLE_TOKEN="$$($(LPASS) show --notes Shared-changelog/secrets/DNSIMPLE_TOKEN)" \
	$(HELM) upgrade cert-manager-webhook-dnsimple neoskop/cert-manager-webhook-dnsimple \
	  --install \
	  --namespace $(CERT_MANAGER_NAMESPACE) --create-namespace \
	  --set dnsimple.account="$$DNSIMPLE_ACCOUNT" \
	  --set dnsimple.token="$$DNSIMPLE_TOKEN" \
	  --set clusterIssuer.production.enabled=true \
	  --set clusterIssuer.staging.enabled=true \
	  --set clusterIssuer.email=$(CERT_EMAIL) \
	  --set groupName=$(CERT_DOMAIN) \
	  --version $(CERT_MANAGER_DNSIMPLE_VERSION)
lke-bootstrap:: lke-cert-manager-dnsimple

.PHONY: releases-cert-manager-dnsimple
releases-cert-manager-dnsimple: | $(HELM)
	$(HELM) repo update
	$(HELM) search repo neoskop/cert-manager-webhook-dnsimple

.PHONY: lke-cert-manager-dnsimple-info
lke-cert-manager-dnsimple-info: | lke-ctx $(HELM)
	$(HELM) show all neoskop/cert-manager-webhook-dnsimple

.PHONY: lke-cert-manager-dnsimple-test
lke-cert-manager-dnsimple-test: | lke-ctx $(HELM)
	$(HELM) test cert-manager-webhook-dnsimple \
	  --namespace $(CERT_MANAGER_NAMESPACE) \
	  --debug
