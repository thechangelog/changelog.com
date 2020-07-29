# https://github.com/CrunchyData/postgres-operator/releases
POSTGRES_OPERATOR_VERSION := 4.4.0
# Changing the namespace will make the installer fail ¯\_(ツ)_/¯
POSTGRES_OPERATOR_NAMESPACE := pgo
POSTGRES_OPERATOR_DIR := $(CURDIR)/tmp/postgres-operator-$(POSTGRES_OPERATOR_VERSION)
POSTGRES_OPERATOR_INSTALL_TIMEOUT := 60s

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

# pgo create cluster db --replica-count=1 --memory=2Gi --memory-limit=4Gi --cpu=2.0 --cpu-limit=4.0 -n prod-2020-07
.PHONY: pgo
pgo: | lke-ctx
	$(KUBECTL) exec --tty --stdin --namespace $(POSTGRES_OPERATOR_NAMESPACE) deploy/pgo-client -- bash
