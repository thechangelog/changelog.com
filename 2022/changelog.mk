CHANGELOG_NAMESPACE := prod-2022-01

# Enable debugging if make runs in debug mode
ifneq (,$(findstring d,$(MFLAGS)))
  WHO_IS_DEBUGGING ?= $(USER)
endif
.PHONY: lke-changelog-%
lke-changelog-%: | lke-ctx $(ENVSUBST)
	export NAMESPACE=$(CHANGELOG_NAMESPACE) \
	; export PUBLIC_IPv4s=$(LKE_POOL_PUBLIC_IPv4s) \
	; export PUBLIC_IPv4=$(INGRESS_NGINX_SERVICE_EXTERNAL_IP) \
	; export DNS_TTL=$(DNS_TTL) \
	; export DEBUG=$(WHO_IS_DEBUGGING) \
	; cat $(CURDIR)/manifests/changelog/$(*).yml \
	| $(ENVSUBST) -no-unset \
	| $(KUBECTL) $(K_CMD) --filename -

# TODO: Re-run without the pr400 as soon as we are ready to go live
# https://github.com/thechangelog/changelog.com/pull/400
.PHONY: lke-changelog-pr400
lke-changelog-pr400: lke-changelog-_namespace lke-changelog-secrets lke-changelog-db lke-changelog-app lke-changelog-dns lke-changelog-lb

.PHONY: lke-changelog
lke-changelog: lke-changelog-_namespace lke-changelog-secrets lke-changelog-db lke-changelog-app lke-changelog-lb lke-changelog-dns lke-changelog-jobs
lke-bootstrap:: | lke-changelog

.PHONY: lke-changelog-db-shell
lke-changelog-db-shell: | lke-ctx
	$(KUBECTL) exec --stdin=true --tty=true --namespace $(CHANGELOG_NAMESPACE) \
	  deployments/app -c db-backup -- bash --login
