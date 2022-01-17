EXTERNAL_DNS_RELEASES := https://github.com/kubernetes-sigs/external-dns/releases
EXTERNAL_DNS_VERSION := 1.7.1
EXTERNAL_DNS_DIR := $(CURDIR)/tmp/external-dns-$(EXTERNAL_DNS_VERSION)
EXTERNAL_DNS_NAMESPACE := external-dns
EXTERNAL_DNS_TXT_OWNER_ID ?= $(LKE_LABEL)
# TODO: Delete the DNSEndpoints & un-comment this when we have finished migrating
# EXTERNAL_DNS_TXT_OWNER_ID ?= linode-kubernetes-engine
EXTERNAL_DNS_LOG_LEVEL ?= debug
# Change to sync when existing DNS records should be updated
EXTERNAL_DNS_POLICY ?= upsert-only

$(EXTERNAL_DNS_DIR):
	git clone \
	  --branch external-dns-helm-chart-$(EXTERNAL_DNS_VERSION) --single-branch --depth 1 \
	  https://github.com/kubernetes-sigs/external-dns $(EXTERNAL_DNS_DIR)
tmp/external-dns: $(EXTERNAL_DNS_DIR)

.PHONY: lke-external-dns
lke-external-dns: | $(EXTERNAL_DNS_DIR) lke-ctx $(HELM)
	$(HELM) upgrade external-dns $(EXTERNAL_DNS_DIR)/charts/external-dns \
	  --install \
	  --namespace $(EXTERNAL_DNS_NAMESPACE) --create-namespace \
	  --values $(EXTERNAL_DNS_DIR)/charts/external-dns/values.yaml \
	  --set txtOwnerId=$(EXTERNAL_DNS_TXT_OWNER_ID) \
	  --set txtPrefix=_external-dns. \
	  --set logLevel=$(EXTERNAL_DNS_LOG_LEVEL) \
	  --set sources[0]=crd \
	  --set sources[1]=crd \
	  --set policy=$(EXTERNAL_DNS_POLICY) \
	  --set extraArgs[0]=--crd-source-apiversion=externaldns.k8s.io/v1alpha1 \
	  --set extraArgs[1]=--crd-source-kind=DNSEndpoint \
	  --set extraArgs[2]=--events \
	  --set provider=dnsimple \
	  --set env[0].name=DNSIMPLE_OAUTH \
	  --set env[0].valueFrom.secretKeyRef.name=dnsimple \
	  --set env[0].valueFrom.secretKeyRef.key=token \
	  --version $(EXTERNAL_DNS_VERSION)
	$(KUBECTL) $(K_CMD) --filename $(EXTERNAL_DNS_DIR)/docs/contributing/crd-source/crd-manifest.yaml
	$(KUBECTL) create secret generic dnsimple \
	  --from-literal=token="$$($(LPASS) show --notes Shared-changelog/secrets/DNSIMPLE_TOKEN)" --dry-run=client --output json \
	| $(KUBECTL) $(K_CMD) --namespace $(EXTERNAL_DNS_NAMESPACE) --filename -
lke-bootstrap:: | lke-external-dns


.PHONY: releases-external-dns
releases-external-dns:
	$(OPEN) $(EXTERNAL_DNS_RELEASES)
