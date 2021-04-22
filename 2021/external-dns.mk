EXTERNAL_DNS_RELEASES := https://github.com/kubernetes-sigs/external-dns/releases
EXTERNAL_DNS_VERSION := v0.7.6
EXTERNAL_DNS_IMAGE := k8s.gcr.io/external-dns/external-dns:$(EXTERNAL_DNS_VERSION)
EXTERNAL_DNS_NAMESPACE := external-dns
EXTERNAL_DNS_CRD_MANIFEST := $(MANIFESTS)/external-dns/crd-manifest-$(EXTERNAL_DNS_VERSION).yml
EXTERNAL_DNS_CRD_MANIFEST_URL := https://raw.githubusercontent.com/kubernetes-sigs/external-dns/$(EXTERNAL_DNS_VERSION)/docs/contributing/crd-source/crd-manifest.yaml
.PHONY: lke-external-dns
lke-external-dns: | lke-ctx $(YTT) $(EXTERNAL_DNS_CRD_MANIFEST)
	$(KUBECTL) $(K_CMD) --filename $(EXTERNAL_DNS_CRD_MANIFEST)
	$(YTT) \
	  --data-value dns.record_owner=lke-$(LKE_LABEL) \
	  --data-value namespace=$(EXTERNAL_DNS_NAMESPACE) \
	  --data-value image=$(EXTERNAL_DNS_IMAGE) \
	  --file $(MANIFESTS)/external-dns/template.yml \
	  --file $(MANIFESTS)/external-dns/values.yml > $(MANIFESTS)/external-dns.yml
	$(KUBECTL) $(K_CMD) --filename $(MANIFESTS)/external-dns.yml
	$(KUBECTL) create secret generic dnsimple \
	  --from-literal=token="$$($(LPASS) show --notes Shared-changelog/secrets/DNSIMPLE_TOKEN)" --dry-run=client --output json \
	| $(KUBECTL) $(K_CMD) --namespace $(EXTERNAL_DNS_NAMESPACE) --filename -
lke-bootstrap:: lke-external-dns

$(EXTERNAL_DNS_CRD_MANIFEST): | $(CURL)
	$(CURL) --progress-bar --fail --location --output $(EXTERNAL_DNS_CRD_MANIFEST) $(EXTERNAL_DNS_CRD_MANIFEST_URL)

.PHONY: releases-external-dns
releases-external-dns:
	$(OPEN) $(EXTERNAL_DNS_RELEASES)
