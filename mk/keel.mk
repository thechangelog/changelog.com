# https://hub.helm.sh/charts/keel/keel
KEEL_VERSION := 0.9.3
KEEL_NAMESPACE := keel

# https://github.com/keel-hq/keel/tree/master/chart/keel
define KEEL
keel \
  --namespace $(KEEL_NAMESPACE) --create-namespace \
  --values $(CURDIR)/k8s/keel/values.yml \
  --version $(KEEL_VERSION) \
  --debug \
  --wait \
  keel/keel
endef
.PHONY: lke-keel
lke-keel: | lke-ctx $(HELM)
	$(HELM) repo add keel https://charts.keel.sh  \
	&& $(HELM) repo update \
	&& $(HELM) upgrade --install $(KEEL)
lke-provision:: lke-keel

.PHONY: lke-keel-info
lke-keel-info: | lke-ctx $(HELM)
	$(HELM) show all keel/keel

.PHONY: lke-keel-test
lke-keel-test: | lke-ctx $(HELM)
	$(HELM) test keel \
	  --namespace $(KEEL_NAMESPACE) \
	  --debug

.PHONY: lke-keel-status
lke-keel-status: | lke-ctx $(HELM)
	$(HELM) status keel --namespace $(KEEL_NAMESPACE) \
	&& $(HELM) list --namespace $(KEEL_NAMESPACE)
