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

# https://access.crunchydata.com/documentation/postgres-operator/4.3.0/installation/postgres-operator/
# https://access.crunchydata.com/documentation/postgres-operator/4.3.0/installation/configuration/
.PHONY: lke-postgres-operator
lke-postgres-operator: lke-ctx $(YTT)
	$(YTT) \
	  --data-value namespace=$(POSTGRES_OPERATOR_NAMESPACE) \
	  --data-value version=$(POSTGRES_OPERATOR_VERSION) \
	  --file $(CURDIR)/k8s/postgres-operator > $(CURDIR)/k8s/postgres-operator.yml \
	&& ( $(KUBECTL) apply --filename $(CURDIR)/k8s/postgres-operator.yml \
	     || $(KUBECTL) auth reconcile --filename $(CURDIR)/k8s/postgres-operator.yml ) \
	&& echo "$(BOLD)$(YELLOW)Waiting up to $(POSTGRES_OPERATOR_INSTALL_TIMEOUT) for PostgreSQL Operator to install...$(NORMAL)" \
	&& $(KUBECTL) wait --namespace $(POSTGRES_OPERATOR_NAMESPACE) --for=condition=complete job/pgo-deploy --timeout=$(POSTGRES_OPERATOR_INSTALL_TIMEOUT) \
	&& echo "$(BOLD)$(YELLOW)Running PostgreSQL Operator post-install cleanup...$(NORMAL)" \
	&& $(KUBECTL) delete --namespace $(POSTGRES_OPERATOR_NAMESPACE) \
	    serviceaccounts/pgo-deployer-sa \
	    clusterrole/pgo-deployer-cr \
	    configmap/pgo-deployer-cm \
	    clusterrolebinding/pgo-deployer-crb \
	    job/pgo-deploy
	
lke-provision:: lke-postgres-operator

POSTGRES_OPERATOR_CLIENT := $(HOME)/.pgo/$(POSTGRES_OPERATOR_NAMESPACE)/pgo

.PHONY: $(POSTGRES_OPERATOR_CLIENT)
$(POSTGRES_OPERATOR_CLIENT): $(POSTGRES_OPERATOR_DIR) | lke-ctx
	export PGO_OPERATOR_NAMESPACE=$(POSTGRES_OPERATOR_NAMESPACE) \
	; bash -x $(POSTGRES_OPERATOR_DIR)/installers/kubectl/client-setup.sh
lke-postgres-operator-client: $(POSTGRES_OPERATOR_CLIENT)

PGO := $(LOCAL_BIN)/pgo-$(POSTGRES_OPERATOR_VERSION)
$(PGO): | $(POSTGRES_OPERATOR_CLIENT)
	mkdir -p $(LOCAL_BIN) \
	&& cd $(LOCAL_BIN) \
	&& echo "export PGOUSER=\"$(HOME)/.pgo/$(POSTGRES_OPERATOR_NAMESPACE)/pgouser\"" > $(PGO) \
	&& echo "export PGO_CA_CERT=\"$(HOME)/.pgo/$(POSTGRES_OPERATOR_NAMESPACE)/client.crt\"" >> $(PGO) \
	&& echo "export PGO_CLIENT_CERT=\"$(HOME)/.pgo/$(POSTGRES_OPERATOR_NAMESPACE)/client.crt\"" >> $(PGO) \
	&& echo "export PGO_CLIENT_KEY=\"$(HOME)/.pgo/$(POSTGRES_OPERATOR_NAMESPACE)/client.key\"" >> $(PGO) \
	&& echo "export PGO_APISERVER_URL=\"https://127.0.0.1:8443\"" >> $(PGO) \
	&& echo "$(HOME)/.pgo/$(POSTGRES_OPERATOR_NAMESPACE)/pgo \$$@" >> $(PGO) \
	&& chmod +x $(PGO) \
	&& ln -sf $(PGO) $(LOCAL_BIN)/pgo
.PHONY: pgo-local
pgo-local: $(PGO)

.PHONY: pgo
pgo: | lke-ctx
	$(KUBECTL) exec --tty --stdin --namespace $(POSTGRES_OPERATOR_NAMESPACE) deploy/pgo-client -- bash

.PHONY: lke-postgres-operator-connection
lke-postgres-operator-connection: | lke-ctx
	$(KUBECTL) port-forward -n $(POSTGRES_OPERATOR_NAMESPACE) svc/postgres-operator 8443:8443
