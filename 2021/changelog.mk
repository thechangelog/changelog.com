CHANGELOG_NAMESPACE := prod-2021-04
DNS_TTL := 600

# Enable debugging if make runs in debug mode
ifneq (,$(findstring d,$(MFLAGS)))
  WHO_IS_DEBUGGING ?= $(USER)
endif
.PHONY: lke-changelog-%
lke-changelog-%: | lke-ctx $(ENVSUBST)
	export NAMESPACE=$(CHANGELOG_NAMESPACE) \
	export PUBLIC_IPv4s=$(LKE_POOL_PUBLIC_IPv4s) \
	export DNS_TTL=$(DNS_TTL) \
	; export DEBUG=$(WHO_IS_DEBUGGING) \
	; cat $(CURDIR)/manifests/changelog/$(*).yml \
	| $(ENVSUBST) -no-unset \
	| $(KUBECTL) $(K_CMD) --filename -

.PHONY: lke-changelog
lke-changelog: lke-changelog-_namespace lke-changelog-secrets lke-changelog-db lke-changelog-app lke-changelog-lb lke-changelog-jobs
lke-bootstrap:: | lke-changelog

.PHONY: lke-changelog-db-shell
lke-changelog-db-shell: | lke-ctx
	$(KUBECTL) exec --stdin=true --tty=true --namespace $(CHANGELOG_NAMESPACE) \
	  deployments/app -c db-backup -- bash --login
