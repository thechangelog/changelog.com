ZALANDO_POSTGRES_OPERATOR_VERSION := 1.6.0
ZALANDO_POSTGRES_OPERATOR_DIR := $(CURDIR)/tmp/zalando-postgres-operator-$(ZALANDO_POSTGRES_OPERATOR_VERSION)
ZALANDO_POSTGRES_OPERATOR_NAMESPACE := postgres-operator

$(ZALANDO_POSTGRES_OPERATOR_DIR):
	git clone \
	  --branch v$(ZALANDO_POSTGRES_OPERATOR_VERSION) --single-branch --depth 1 \
	  https://github.com/zalando/postgres-operator.git $(ZALANDO_POSTGRES_OPERATOR_DIR)
tmp/zalando-postgres-operator: $(ZALANDO_POSTGRES_OPERATOR_DIR)

# TODO: configLogicalBackup
lke-zalando-postgres-operator: | lke-ctx $(HELM)
	$(HELM) upgrade postgres-operator \
	  $(ZALANDO_POSTGRES_OPERATOR_DIR)/charts/postgres-operator \
	  --install \
	  --values $(ZALANDO_POSTGRES_OPERATOR_DIR)/charts/postgres-operator/values-crd.yaml \
	  --set configKubernetes.enable_pod_antiaffinity=true \
	  --set configKubernetes.pod_environment_configmap=$(ZALANDO_POSTGRES_OPERATOR_NAMESPACE)/postgres-pod-environment \
	  --namespace $(ZALANDO_POSTGRES_OPERATOR_NAMESPACE) \
	  --create-namespace
	$(KUBECTL) apply --filename $(CURDIR)/k8s/postgres-pod-config.yml --namespace $(ZALANDO_POSTGRES_OPERATOR_NAMESPACE)
lke-provision:: lke-zalando-postgres-operator
