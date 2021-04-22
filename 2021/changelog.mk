CHANGELOG_NAMESPACE := changelog

# Enable debugging if make runs in debug mode
ifneq (,$(findstring d,$(MFLAGS)))
  WHO_IS_DEBUGGING ?= $(USER)
endif
.PHONY: lke-changelog-%
lke-changelog-%: | lke-ctx $(ENVSUBST)
	export NAMESPACE=$(CHANGELOG_NAMESPACE) \
	; export DEBUG=$(WHO_IS_DEBUGGING) \
	; cat $(CURDIR)/manifests/changelog/$(*).yml \
	| $(ENVSUBST) -no-unset \
	| $(KUBECTL) $(K_CMD) --filename -

.PHONY: lke-changelog
lke-changelog: lke-changelog-db lke-changelog-app lke-changelog-lb lke-changelog-jobs
lke-bootstrap:: lke-changelog

.PHONY: lke-changelog-db-shell
lke-changelog-db-shell: | lke-ctx
	$(KUBECTL) exec --stdin=true --tty=true --namespace $(CHANGELOG_NAMESPACE) \
	  deployments/app -c db-backup -- bash --login

# ^^^ Within the db-restore container run:
#
# 	clean_db
# 	restore_db_from_backup

.PHONY: lke-changelog-secrets
lke-changelog-secrets:: campaignmonitor-lke-secret
lke-changelog-secrets:: github-lke-secret
lke-changelog-secrets:: hackernews-lke-secret
lke-changelog-secrets:: aws-lke-secret
lke-changelog-secrets:: backups-aws-lke-secret
lke-changelog-secrets:: shopify-lke-secret
lke-changelog-secrets:: twitter-lke-secret
lke-changelog-secrets:: app-lke-secret
lke-changelog-secrets:: slack-lke-secret
lke-changelog-secrets:: rollbar-lke-secret
lke-changelog-secrets:: buffer-lke-secret
lke-changelog-secrets:: coveralls-lke-secret
lke-changelog-secrets:: algolia-lke-secret
lke-changelog-secrets:: plusplus-lke-secret
lke-changelog-secrets:: fastly-lke-secret
lke-changelog-secrets:: hcaptcha-lke-secret
lke-changelog-secrets:: grafana-lke-secret
lke-changelog-secrets:: promex-lke-secret
lke-changelog-secrets:: sentry-lke-secret
