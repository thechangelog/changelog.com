LOCAL_PATH_PROVISIONER_RELEASES := https://github.com/rancher/local-path-provisioner/releases
LOCAL_PATH_PROVISIONER_VERSION := 0.0.21
LOCAL_PATH_PROVISIONER_DIR := $(CURDIR)/tmp/local-path-provisioner-$(LOCAL_PATH_PROVISIONER_VERSION)

$(LOCAL_PATH_PROVISIONER_DIR):
	git clone \
	  --branch v$(LOCAL_PATH_PROVISIONER_VERSION) --single-branch --depth 1 \
	  https://github.com/rancher/local-path-provisioner $(LOCAL_PATH_PROVISIONER_DIR)
tmp/local-path-provisioner: $(LOCAL_PATH_PROVISIONER_DIR)

.PHONY: lke-local-path-provisioner
lke-local-path-provisioner: | $(LOCAL_PATH_PROVISIONER_DIR) lke-ctx $(HELM)
	$(HELM) upgrade local-path-provisioner $(LOCAL_PATH_PROVISIONER_DIR)/deploy/chart \
	  --install \
	  --namespace local-path-provisioner --create-namespace \
	  --values $(LOCAL_PATH_PROVISIONER_DIR)/deploy/chart/values.yaml \
	  --set storageClass.reclaimPolicy=Retain \
	  --version $(LOCAL_PATH_PROVISIONER_VERSION)
lke-bootstrap:: | lke-local-path-provisioner

.PHONY: releases-local-path-provisioner
releases-local-path-provisioner:
	$(OPEN) $(LOCAL_PATH_PROVISIONER_RELEASES)
