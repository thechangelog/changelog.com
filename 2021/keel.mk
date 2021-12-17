KEEL_RELEASES := https://github.com/keel-hq/keel/releases
KEEL_VERSION := 0.16.1
KEEL_DIR := $(CURDIR)/tmp/keel-$(KEEL_VERSION)

$(KEEL_DIR):
	git clone \
	  --branch $(KEEL_VERSION) --single-branch --depth 1 \
	  https://github.com/keel-hq/keel.git $(KEEL_DIR)
tmp/keel: $(KEEL_DIR)

.PHONY: lke-keel
lke-keel: | $(KEEL_DIR) lke-ctx $(HELM)
	$(HELM) upgrade keel $(KEEL_DIR)/chart/keel \
	  --install \
	  --namespace keel --create-namespace \
	  --values $(KEEL_DIR)/chart/keel/values.yaml \
	  --set helmProvider.enabled=false \
	  --set notificationLevel=debug \
	  --set debug=true \
	  --set service.enabled=true \
	  --set service.type=ClusterIP \
	  --set ingress.enabled=true \
	  --set ingress.annotations."external\-dns\.alpha\.kubernetes\.io/ttl"=10m \
	  --set ingress.annotations."kubernetes\.io/ingress\.class"=nginx \
	  --set ingress.hosts[0].host=keel21.changelog.com \
	  --set ingress.hosts[0].paths[0]=/
	export PUBLIC_IPv4=$(INGRESS_NGINX_SERVICE_EXTERNAL_IP) \
	; export NAMESPACE=keel \
	; export DNS_TTL=$(DNS_TTL) \
	; cat $(CURDIR)/manifests/keel.yml \
	| $(ENVSUBST) -no-unset \
	| $(KUBECTL) $(K_CMD) --filename -

lke-bootstrap:: | lke-keel

.PHONY: releases-keel
releases-keel:
	$(OPEN) $(KEEL_RELEASES)
