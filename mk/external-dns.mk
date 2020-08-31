# https://github.com/kubernetes-sigs/external-dns/releases
EXTERNAL_DNS_VERSION := v0.7.3
EXTERNAL_DNS_IMAGE := us.gcr.io/k8s-artifacts-prod/external-dns/external-dns:$(EXTERNAL_DNS_VERSION)
EXTERNAL_DNS_DEPLOYMENT := external-dns
EXTERNAL_DNS_NAMESPACE := $(EXTERNAL_DNS_DEPLOYMENT)
EXTERNAL_DNS_TREE := $(KUBETREE) deployments $(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE)
.PHONY: lke-external-dns
lke-external-dns: lke-ctx dnsimple-creds $(YTT) $(KUBETREE)
	$(YTT) \
	  --data-value namespace=$(EXTERNAL_DNS_NAMESPACE) \
	  --data-value image=$(EXTERNAL_DNS_IMAGE) \
	  --file $(CURDIR)/k8s/external-dns > $(CURDIR)/k8s/external-dns.yml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/external-dns.yml \
	&& $(KUBECTL) create secret generic dnsimple \
	    --from-literal=token="$(DNSIMPLE_TOKEN)" --dry-run --output json \
	   | $(KUBECTL) apply --namespace $(EXTERNAL_DNS_NAMESPACE) --filename - \
	&& $(KUBETREE) deployments $(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE)
lke-provision:: lke-external-dns

.PHONY: lke-external-dns-tree
lke-external-dns-tree: lke-ctx $(KUBETREE)
	$(EXTERNAL_DNS_TREE)

.PHONY: lke-external-dns-logs
lke-external-dns-logs: lke-ctx
	$(KUBECTL) logs deployments/$(EXTERNAL_DNS_DEPLOYMENT) --namespace $(EXTERNAL_DNS_NAMESPACE) --follow
