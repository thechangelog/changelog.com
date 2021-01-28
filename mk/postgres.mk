# https://github.com/CrunchyData/postgres-operator/releases
POSTGRES_OPERATOR_VERSION := 4.4.0
# Changing the namespace will make the installer fail ¯\_(ツ)_/¯
POSTGRES_OPERATOR_NAMESPACE := pgo
POSTGRES_OPERATOR_DIR := $(CURDIR)/tmp/postgres-operator-$(POSTGRES_OPERATOR_VERSION)
POSTGRES_OPERATOR_INSTALL_TIMEOUT := 120s

$(POSTGRES_OPERATOR_DIR):
	git clone \
	  --branch v$(POSTGRES_OPERATOR_VERSION) --single-branch --depth 1 \
	  https://github.com/CrunchyData/postgres-operator.git $@
tmp/postgres-operator: $(POSTGRES_OPERATOR_DIR)

.PHONY: lke-postgres-operator
lke-postgres-operator: lke-ctx $(YTT)
	$(YTT) \
	  --data-value namespace=$(POSTGRES_OPERATOR_NAMESPACE) \
	  --data-value managed_namespaces=prod-2020-07 \
	  --data-value version=$(POSTGRES_OPERATOR_VERSION) \
	  --file $(CURDIR)/k8s/postgres-operator > $(CURDIR)/k8s/postgres-operator.yml \
	&& ( $(KUBECTL) apply --filename $(CURDIR)/k8s/postgres-operator.yml \
	     || $(KUBECTL) auth reconcile --filename $(CURDIR)/k8s/postgres-operator.yml ) \
	&& printf "$(BOLD)$(YELLOW)Waiting up to $(POSTGRES_OPERATOR_INSTALL_TIMEOUT) for PostgreSQL Operator to install...$(NORMAL)\n" \
	&& $(KUBECTL) wait --namespace $(POSTGRES_OPERATOR_NAMESPACE) --for=condition=complete job/pgo-deploy --timeout=$(POSTGRES_OPERATOR_INSTALL_TIMEOUT) \
	&& printf "$(BOLD)$(YELLOW)Running PostgreSQL Operator post-install cleanup...$(NORMAL)\n" \
	&& $(KUBECTL) delete --namespace $(POSTGRES_OPERATOR_NAMESPACE) \
	    serviceaccounts/pgo-deployer-sa \
	    clusterrole/pgo-deployer-cr \
	    configmap/pgo-deployer-cm \
	    clusterrolebinding/pgo-deployer-crb \
	    job/pgo-deploy
lke-provision:: lke-postgres-operator

# Command that was used to create the db cluster:
# 	pgo create cluster db2 --replica-count=1 --memory=2Gi --memory-limit=4Gi --cpu=2.0 --cpu-limit=4.0 --namespace prod-2020-07
#
# List all db clusters:
# 	pgo show cluster --all --namespace prod-2020-07
#
# Show db cluster status:
# 	pgo status --namespace prod-2020-07
.PHONY: pgo
pgo: | lke-ctx
	$(KUBECTL) exec --tty --stdin --namespace $(POSTGRES_OPERATOR_NAMESPACE) deploy/pgo-client -- bash --login

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
	  --namespace $(ZALANDO_POSTGRES_OPERATOR_NAMESPACE) \
	  --create-namespace
lke-provision:: lke-zalando-postgres-operator
