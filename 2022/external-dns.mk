EXTERNAL_DNS_RELEASES := https://github.com/kubernetes-sigs/external-dns/releases
EXTERNAL_DNS_VERSION := v0.9.0
EXTERNAL_DNS_IMAGE := k8s.gcr.io/external-dns/external-dns:$(EXTERNAL_DNS_VERSION)
EXTERNAL_DNS_NAMESPACE := external-dns
EXTERNAL_DNS_CRD_MANIFEST := $(MANIFESTS)/external-dns-crd-manifest-$(EXTERNAL_DNS_VERSION).yml
EXTERNAL_DNS_CRD_MANIFEST_URL := https://raw.githubusercontent.com/kubernetes-sigs/external-dns/$(EXTERNAL_DNS_VERSION)/docs/contributing/crd-source/crd-manifest.yaml
EXTERNAL_DNS_TXT_OWNER_ID ?= linode-kubernetes-engine
EXTERNAL_DNS_LOG_LEVEL ?= debug
# Change to sync when existing DNS records should be updated
EXTERNAL_DNS_POLICY ?= upsert-only
.PHONY: lke-external-dns
lke-external-dns: | lke-ctx $(ENVSUBST) $(EXTERNAL_DNS_CRD_MANIFEST)
	$(KUBECTL) $(K_CMD) --filename $(EXTERNAL_DNS_CRD_MANIFEST)
	export NAMESPACE=$(EXTERNAL_DNS_NAMESPACE) \
	; export IMAGE=$(EXTERNAL_DNS_IMAGE) \
	; export TXT_OWNER_ID=$(EXTERNAL_DNS_TXT_OWNER_ID) \
	; export LOG_LEVEL=$(EXTERNAL_DNS_LOG_LEVEL) \
	; export POLICY=$(EXTERNAL_DNS_POLICY) \
	; cat $(CURDIR)/manifests/external-dns.yml \
	| $(ENVSUBST) -no-unset \
	| $(KUBECTL) $(K_CMD) --filename -
	$(KUBECTL) create secret generic dnsimple \
	  --from-literal=token="$$($(LPASS) show --notes Shared-changelog/secrets/DNSIMPLE_TOKEN)" --dry-run=client --output json \
	| $(KUBECTL) $(K_CMD) --namespace $(EXTERNAL_DNS_NAMESPACE) --filename -
lke-bootstrap:: | lke-external-dns

$(EXTERNAL_DNS_CRD_MANIFEST): | $(CURL)
	$(CURL) --progress-bar --fail --location --output $(EXTERNAL_DNS_CRD_MANIFEST) $(EXTERNAL_DNS_CRD_MANIFEST_URL)

.PHONY: releases-external-dns
releases-external-dns:
	$(OPEN) $(EXTERNAL_DNS_RELEASES)
