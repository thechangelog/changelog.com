# https://github.com/CrunchyData/postgres-operator/releases
POSTGRES_OPERATOR_VERSION := 4.3.0
# Changing the namespace will make the installer fail ¯\_(ツ)_/¯
POSTGRES_OPERATOR_NAMESPACE := pgo
POSTGRES_OPERATOR_DIR := $(CURDIR)/tmp/postgres-operator-$(POSTGRES_OPERATOR_VERSION)

$(POSTGRES_OPERATOR_DIR):
	git clone \
	  --branch v$(POSTGRES_OPERATOR_VERSION) --single-branch --depth 1 \
	  https://github.com/CrunchyData/postgres-operator.git $@
tmp/postgres-operator: $(POSTGRES_OPERATOR_DIR)

# https://access.crunchydata.com/documentation/postgres-operator/4.3.0/installation/postgres-operator/
.PHONY: lke-postgres-operator
lke-postgres-operator: lke-ctx $(YTT)
	$(YTT) \
	  --data-value namespace=$(POSTGRES_OPERATOR_NAMESPACE) \
	  --data-value version=$(POSTGRES_OPERATOR_VERSION) \
	  --file $(CURDIR)/k8s/postgres-operator > $(CURDIR)/k8s/postgres-operator.yml \
	&& $(KUBECTL) apply --filename $(CURDIR)/k8s/postgres-operator.yml
lke-provision:: lke-postgres-operator
