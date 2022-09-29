SECRETS := mkdir -p $(XDG_CONFIG_HOME)/.config && $(LPASS) ls "Shared-changelog/secrets"

define SECRET_MISSING
echo "$(RED)SECRET$(NORMAL) environment variable must be set to the name of the secret that will be added" && \
echo "This value must be in upper-case, e.g. $(BOLD)SOME_SECRET$(NORMAL)" && \
echo "This value must not match any of the existing secrets:" && \
$(SECRETS) && \
exit 1
endef
.PHONY: add-secret
add-secret: $(LPASS) ## as  | Add secret to LastPass
ifndef SECRET
	@$(SECRET_MISSING)
endif
	@$(LPASS) add --notes "Shared-changelog/secrets/$(SECRET)"
.PHONY: as
as: add-secret

.PHONY: update-secret
update-secret: $(LPASS) ## us  | Edit secret in LastPass
ifndef SECRET
	@$(SECRET_MISSING)
endif
	@$(LPASS) edit --notes "Shared-changelog/secrets/$(SECRET)"
.PHONY: us
us: update-secret

DONE := $(YELLOW)(press any key when done)$(NORMAL)

.PHONY: howto-rotate-secret
howto-rotate-secret:
	@printf "$(BOLD)$(GREEN)All commands must be run in this directory. I propose a new side-by-side split to these instructions.$(NORMAL)\n\n"
	@printf " 1/3. Update secret in LastPass by running e.g. $(BOLD)make update-secret SECRET=ALGOLIA_API_KEY$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 2/3. Add new secret to production by running $(BOLD)make lke-changelog-secrets$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 3/3. Restart the app so that it picks up the new secret by running $(BOLD)make lke-changelog-update$(NORMAL)\n" ; read -rp " $(DONE)" -n 1

.PHONY: howto-add-secret
howto-add-secret:
	@printf "$(BOLD)$(GREEN)All commands must be run in this directory. I propose a new side-by-side split to these instructions.$(NORMAL)\n\n"
	@printf " 1/5. Add new secret to LastPass by running e.g. $(BOLD)make add-secret SECRET=CAPTCHA_API_KEY$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 2/5. Add new *-lke-secret target to $(BOLD)$(CURDIR)/secrets.mk$(NORMAL) & remember to append it to $(BOLD)lke-changelog-secrets$(NORMAL) target\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 3/5. Run $(BOLD)make lke-changelog-secrets$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 4/5. Add reference to new secret in $(BOLD)k8s/changelog/app.yml$(NORMAL), then run $(BOLD)make lke-changelog$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 5/5. Commit and push all changes, including the app changes to read the new secret from environment variables. The pipeline will take care of the rest 😉\n" ; read -rp " $(DONE)" -n 1

.PHONY: env-secrets
env-secrets::

.PHONY: lke-changelog-secrets
lke-changelog-secrets::

.PHONY: secrets
secrets: $(LPASS) ## s   | List all LastPass secrets
	@$(SECRETS)
.PHONY: s
s: secrets

.PHONY: sync-secrets
sync-secrets: $(LPASS)
	@$(LPASS) sync

.PHONY: postgres
postgres: $(LPASS)
	@echo "export PG_DOTCOM_PASS=$$($(LPASS) show --notes 7298637973371173308)"
env-secrets:: postgres

.PHONY: campaignmonitor
CM_SMTP_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/CM_SMTP_TOKEN)"
CM_API_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/CM_API_TOKEN_2)"
campaignmonitor: $(LPASS)
	@echo "export CM_SMTP_TOKEN=$(CM_SMTP_TOKEN)" && \
	echo "export CM_API_TOKEN=$(CM_API_TOKEN)"
env-secrets:: campaignmonitor
.PHONY: campaignmonitor-lke-secret
campaignmonitor-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic campaignmonitor \
	  --from-literal=smtp_token=$(CM_SMTP_TOKEN) \
	  --from-literal=api_token=$(CM_API_TOKEN) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: campaignmonitor-lke-secret

GITHUB_CLIENT_ID ?= "$$($(LPASS) show --notes Shared-changelog/secrets/GITHUB_CLIENT_ID)"
GITHUB_CLIENT_SECRET ?= "$$($(LPASS) show --notes Shared-changelog/secrets/GITHUB_CLIENT_SECRET)"
GITHUB_API_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/GITHUB_API_TOKEN2)"
.PHONY: github
github: $(LPASS)
	@echo "export GITHUB_CLIENT_ID=$(GITHUB_CLIENT_ID)" && \
	echo "export GITHUB_CLIENT_SECRET=$(GITHUB_CLIENT_SECRET)" && \
	echo "export GITHUB_API_TOKEN=$(GITHUB_API_TOKEN)"
env-secrets:: github
.PHONY: github-lke-secret
github-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic github \
	  --from-literal=client_id=$(GITHUB_CLIENT_ID) \
	  --from-literal=client_secret=$(GITHUB_CLIENT_SECRET) \
	  --from-literal=api_token=$(GITHUB_API_TOKEN) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: github-lke-secret

TURNSTILE_SECRET_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/TURNSTILE_SECRET_KEY)"
.PHONY: turnstile
turnstile: $(LPASS)
	@echo "export TURNSTILE_SECRET_KEY=$(TURNSTILE_SECRET_KEY)"
env-secrets:: turnstile
.PHONY: turnstile-lke-secret
turnstile-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
		create secret generic turnstile \
		--from-literal=secret_key=$(TURNSTILE_SECRET_KEY) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: turnstile-lke-secret

RECAPTCHA_SECRET_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/RECAPTCHA_SECRET_KEY)"
.PHONY: recaptcha
recaptcha: $(LPASS)
	@echo "export RECAPTCHA_SECRET_KEY=$(RECAPTCHA_SECRET_KEY)"
env-secrets:: recaptcha
.PHONY: recaptcha-lke-secret
recaptcha-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
		create secret generic recaptcha \
		--from-literal=secret_key=$(RECAPTCHA_SECRET_KEY) \
	| $(KUBECTL) apply --filename -
lke-changelog-secrets:: recaptcha-lke-secret

HACKERNEWS_USER ?= "$$($(LPASS) show --notes Shared-changelog/secrets/HN_USER_1)"
HACKERNEWS_PASS ?= "$$($(LPASS) show --notes Shared-changelog/secrets/HN_PASS_1)"
.PHONY: hackernews
hackernews: $(LPASS)
	@echo "export HN_USER=$(HACKERNEWS_USER)" && \
	echo "export HN_PASS=$(HACKERNEWS_PASS)"
env-secrets:: hackernews
.PHONY: hackernews-lke-secret
hackernews-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic hackernews \
	  --from-literal=user=$(HACKERNEWS_USER) \
	  --from-literal=pass=$(HACKERNEWS_PASS) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: hackernews-lke-secret

AWS_ACCESS_KEY_ID ?= "$$($(LPASS) show --notes Shared-changelog/secrets/AWS_ACCESS_KEY_ID)"
AWS_SECRET_ACCESS_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/AWS_SECRET_ACCESS_KEY)"
.PHONY: aws
aws: $(LPASS)
	@echo "export AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" && \
	echo "export AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)"
env-secrets:: aws
.PHONY: aws-lke-secret
aws-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic aws \
	  --from-literal=access_key_id=$(AWS_ACCESS_KEY_ID) \
	  --from-literal=secret_access_key=$(AWS_SECRET_ACCESS_KEY) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: aws-lke-secret

BACKUPS_AWS_ACCESS_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/BACKUPS_AWS_ACCESS_KEY)"
BACKUPS_AWS_SECRET_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/BACKUPS_AWS_SECRET_KEY)"
.PHONY: backups_aws
backups_aws: $(LPASS)
	@echo "export BACKUPS_AWS_ACCESS_KEY=$(BACKUPS_AWS_ACCESS_KEY)" && \
	echo "export BACKUPS_AWS_SECRET_KEY=$(BACKUPS_AWS_SECRET_KEY)"
env-secrets:: backups_aws
.PHONY: backups-aws-lke-secret
backups-aws-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic backups-aws \
	  --from-literal=access_key_id=$(BACKUPS_AWS_ACCESS_KEY) \
	  --from-literal=secret_access_key=$(BACKUPS_AWS_SECRET_KEY) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: backups-aws-lke-secret

SHOPIFY_API_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/SHOPIFY_API_KEY)"
SHOPIFY_API_PASSWORD ?= "$$($(LPASS) show --notes Shared-changelog/secrets/SHOPIFY_API_PASSWORD)"
.PHONY: shopify
shopify: $(LPASS)
	@echo "export SHOPIFY_API_KEY=$(SHOPIFY_API_KEY)" && \
	echo "export SHOPIFY_API_PASSWORD=$(SHOPIFY_API_PASSWORD)"
env-secrets:: shopify
.PHONY: shopify-lke-secret
shopify-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
		create secret generic shopify \
		--from-literal=api_key=$(SHOPIFY_API_KEY) \
		--from-literal=api_password=$(SHOPIFY_API_PASSWORD) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: shopify-lke-secret

TWITTER_CONSUMER_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/TWITTER_CONSUMER_KEY)"
TWITTER_CONSUMER_SECRET ?= "$$($(LPASS) show --notes Shared-changelog/secrets/TWITTER_CONSUMER_SECRET)"
.PHONY: twitter
twitter: $(LPASS)
	@echo "export TWITTER_CONSUMER_KEY=$(TWITTER_CONSUMER_KEY)" && \
	echo "export TWITTER_CONSUMER_SECRET=$(TWITTER_CONSUMER_SECRET)"
env-secrets:: twitter
.PHONY: twitter-lke-secret
twitter-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic twitter \
	  --from-literal=consumer_key=$(TWITTER_CONSUMER_KEY) \
	  --from-literal=consumer_secret=$(TWITTER_CONSUMER_SECRET) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: twitter-lke-secret

SECRET_KEY_BASE ?= "$$($(LPASS) show --notes Shared-changelog/secrets/SECRET_KEY_BASE)"
SIGNING_SALT ?= "$$($(LPASS) show --notes Shared-changelog/secrets/SIGNING_SALT)"
.PHONY: app
app: $(LPASS)
	@echo "export SECRET_KEY_BASE=$(SECRET_KEY_BASE)" && \
	echo "export SIGNING_SALT=$(SIGNING_SALT)"
env-secrets:: app
.PHONY: app-lke-secret
app-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic app \
	  --from-literal=secret_key_base=$(SECRET_KEY_BASE) \
	  --from-literal=signing_salt=$(SIGNING_SALT) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: app-lke-secret

SLACK_INVITE_API_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/SLACK_INVITE_API_TOKEN)"
SLACK_APP_API_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/SLACK_APP_API_TOKEN)"
SLACK_DEPLOY_WEBHOOK ?= "$$($(LPASS) show --notes Shared-changelog/secrets/SLACK_DEPLOY_WEBHOOK)"
.PHONY: slack
slack: $(LPASS)
	@echo "export SLACK_INVITE_API_TOKEN=$(SLACK_INVITE_API_TOKEN)" && \
	echo "export SLACK_APP_API_TOKEN=$(SLACK_APP_API_TOKEN)"
env-secrets:: slack
.PHONY: slack-lke-secret
slack-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic slack \
	  --from-literal=app_api_token=$(SLACK_APP_API_TOKEN) \
	  --from-literal=deploy_webhook=$(SLACK_DEPLOY_WEBHOOK) \
	  --from-literal=invite_api_token=$(SLACK_INVITE_API_TOKEN) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: slack-lke-secret

BUFFER_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/BUFFER_TOKEN_3)"
.PHONY: buffer
buffer: $(LPASS)
	@echo "export BUFFER_TOKEN=$(BUFFER_TOKEN)"
env-secrets:: buffer
.PHONY: buffer-lke-secret
buffer-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic buffer \
	  --from-literal=token=$(BUFFER_TOKEN) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: buffer-lke-secret

COVERALLS_REPO_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/COVERALLS_REPO_TOKEN)"
.PHONY: coveralls
coveralls: $(LPASS)
	@echo "export COVERALLS_REPO_TOKEN=$(COVERALLS_REPO_TOKEN)"
env-secrets:: coveralls
.PHONY: coveralls-lke-secret
coveralls-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic coveralls \
	  --from-literal=repo_token=$(COVERALLS_REPO_TOKEN) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: coveralls-lke-secret

ALGOLIA_APPLICATION_ID ?= "$$($(LPASS) show --notes Shared-changelog/secrets/ALGOLIA_APPLICATION_ID)"
ALGOLIA_API_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/ALGOLIA_API_KEY2)"
.PHONY: algolia
algolia: $(LPASS)
	@echo "export ALGOLIA_APPLICATION_ID=$(ALGOLIA_APPLICATION_ID)" && \
	echo "export ALGOLIA_API_KEY=$(ALGOLIA_API_KEY)"
env-secrets:: algolia
.PHONY: algolia-lke-secret
algolia-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic algolia \
	  --from-literal=application_id=$(ALGOLIA_APPLICATION_ID) \
	  --from-literal=api_key=$(ALGOLIA_API_KEY) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: algolia-lke-secret

PLUSPLUS_SLUG ?= "$$($(LPASS) show --notes Shared-changelog/secrets/PLUSPLUS_SLUG_1)"
.PHONY: plusplus
plusplus: $(LPASS)
	@echo "export PLUSPLUS_SLUG_1=$(PLUSPLUS_SLUG)"
env-secrets:: plusplus
.PHONY: plusplus-lke-secret
plusplus-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic plusplus \
	  --from-literal=slug=$(PLUSPLUS_SLUG) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: plusplus-lke-secret

FASTLY_API_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/FASTLY_API_TOKEN)"
.PHONY: fastly
fastly: $(LPASS)
	@echo "export FASTLY_API_TOKEN=$(FASTLY_API_TOKEN)"
env-secrets:: fastly
.PHONY: fastly-lke-secret
fastly-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic fastly \
	  --from-literal=token=$(FASTLY_API_TOKEN) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: fastly-lke-secret

GRAFANA_API_KEY ?= "$$($(LPASS) show --notes Shared-changelog/secrets/GRAFANA_API_KEY)"
.PHONY: grafana
grafana: $(LPASS)
	@echo "export GRAFANA_API_KEY=$(GRAFANA_API_KEY)"
env-secrets:: grafana
.PHONY: grafana-lke-secret
grafana-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic grafana \
	  --from-literal=api_key=$(GRAFANA_API_KEY) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: grafana-lke-secret

PROMETHEUS_BEARER_TOKEN_PROM_EX := "$$($(LPASS) show --notes Shared-changelog/secrets/PROMETHEUS_BEARER_TOKEN_PROM_EX)"
.PHONY: promex
promex: $(LPASS)
	@echo "export PROMETHEUS_BEARER_TOKEN_PROM_EX=$(PROMETHEUS_BEARER_TOKEN_PROM_EX)"
env-secrets:: promex
.PHONY: promex-lke-secret
promex-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic promex \
	  --from-literal=bearer_token=$(PROMETHEUS_BEARER_TOKEN_PROM_EX) \
	| $(KUBECTL) $(K_CMD) --filename -
	# TODO: grafana-agent will need this
	# @$(KUBECTL) --namespace $(GRAFANA_AGENT_NAMESPACE) --dry-run=client --output=yaml \
	#   create secret generic promex \
	#   --from-literal=bearer_token=$(PROMETHEUS_BEARER_TOKEN_PROM_EX) \
	# | $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: promex-lke-secret

SENTRY_AUTH_TOKEN ?= "$$($(LPASS) show --notes Shared-changelog/secrets/SENTRY_AUTH_TOKEN)"
.PHONY: sentry
sentry: $(LPASS)
	@echo "export SENTRY_AUTH_TOKEN=$(SENTRY_AUTH_TOKEN)"
env-secrets:: sentry
.PHONY: sentry-lke-secret
sentry-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic sentry \
	  --from-literal=auth_token=$(SENTRY_AUTH_TOKEN) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: sentry-lke-secret

POSTGRES_PASSWORD ?= "$$($(LPASS) show --notes Shared-changelog/secrets/POSTGRES_PASSWORD)"
.PHONY: postgres-lke-secret
postgres-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic postgres \
	  --from-literal=password=$(POSTGRES_PASSWORD) \
	| $(KUBECTL) $(K_CMD) --filename -
lke-changelog-secrets:: postgres-lke-secret
