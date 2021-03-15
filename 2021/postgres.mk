POSTGRES_OPERATOR_RELEASES := https://github.com/zalando/postgres-operator/releases
POSTGRES_OPERATOR_VERSION := 1.6.1
POSTGRES_OPERATOR_DIR := $(CURDIR)/tmp/postgres-operator-$(POSTGRES_OPERATOR_VERSION)

$(POSTGRES_OPERATOR_DIR):
	git clone \
	  --branch v$(POSTGRES_OPERATOR_VERSION) --single-branch --depth 1 \
	  https://github.com/zalando/postgres-operator.git $(POSTGRES_OPERATOR_DIR)
tmp/postgres-operator: $(POSTGRES_OPERATOR_DIR)

# TODO: configLogicalBackup
lke-postgres-operator: | $(POSTGRES_OPERATOR_DIR) lke-ctx $(HELM)
	$(HELM) upgrade postgres-operator $(POSTGRES_OPERATOR_DIR)/charts/postgres-operator \
	  --install \
	  --namespace postgres-operator --create-namespace \
	  --values $(POSTGRES_OPERATOR_DIR)/charts/postgres-operator/values-crd.yaml \
	  --set configKubernetes.enable_pod_antiaffinity=true \
	  --set configKubernetes.pod_environment_configmap=postgres-operator/postgres-pod-environment
	$(KUBECTL) apply --filename $(CURDIR)/manifests/postgres-operator

releases-postgres-operator:
	$(OPEN) $(POSTGRES_OPERATOR_RELEASES)
