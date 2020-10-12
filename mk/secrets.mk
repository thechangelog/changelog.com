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
	@printf "\n 2/5. Add new *-lke-secret target to $(BOLD)mk/secrets.mk$(NORMAL), and add it as a dependency to $(BOLD)env-secrets$(NORMAL) target\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 3/5. Define the new target as a lke-changelog-secrets dependency in $(BOLD)mk/changelog.mk$(NORMAL), then run $(BOLD)make lke-changelog-secrets$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 4/5. Add reference to new secret in $(BOLD)k8s/changelog/app.yml$(NORMAL), then run $(BOLD)make lke-changelog$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 5/5. Commit and push all changes, including the app changes to read the new secret from environment variables. The pipeline will take care of the rest 😉\n" ; read -rp " $(DONE)" -n 1

CIRCLE_CI_ADD_ENV_VAR_URL = https://circleci.com/api/v1.1/project/github/thechangelog/changelog.com/envvar?circle-token=$(CIRCLE_TOKEN)
.PHONY: configure-ci-secrets
configure-ci-secrets: configure-ci-docker-secret configure-ci-coveralls-secret ## ccs | Configure CircleCI secrets
.PHONY: ccs
ccs: configure-ci-secrets

.PHONY: configure-ci-docker-secret
configure-ci-docker-secret: $(LPASS) $(JQ) $(CURL) circle-token
	@DOCKER_CREDENTIALS=$$($(LPASS) show --json 2219952586317097429) && \
	DOCKER_USER="$$($(JQ) --compact-output '.[] | {name: "DOCKER_USER", value: .username}' <<< $$DOCKER_CREDENTIALS)" && \
	DOCKER_PASS="$$($(JQ) --compact-output '.[] | {name: "DOCKER_PASS", value: .password}' <<< $$DOCKER_CREDENTIALS)" && \
	$(CURL) --silent --fail --request POST --header "Content-Type: application/json" -d "$$DOCKER_USER" "$(CIRCLE_CI_ADD_ENV_VAR_URL)" && \
	$(CURL) --silent --fail --request POST --header "Content-Type: application/json" -d "$$DOCKER_PASS" "$(CIRCLE_CI_ADD_ENV_VAR_URL)"
.PHONY: ccds
ccds: configure-ci-docker-secret

.PHONY: configure-ci-coveralls-secret
configure-ci-coveralls-secret: $(LPASS) $(JQ) $(CURL) circle-token
	@COVERALLS_TOKEN='{"name":"COVERALLS_REPO_TOKEN", "value":"'$$($(LPASS) show --notes 8654919576068551356)'"}' && \
	$(CURL) --silent --fail --request POST --header "Content-Type: application/json" -d "$$COVERALLS_TOKEN" "$(CIRCLE_CI_ADD_ENV_VAR_URL)"
.PHONY: cccs
.PHONY: cccs
cccs: configure-ci-coveralls-secret

.PHONY: env-secrets
env-secrets: postgres campaignmonitor github hcaptcha hackernews aws backups_aws twitter app slack rollbar buffer coveralls algolia plusplus ## es  | Print secrets stored in LastPass as env vars
.PHONY: es
es: env-secrets

.PHONY: secrets
secrets: $(LPASS) ## s   | List all LastPass secrets
	@$(SECRETS)
.PHONY: s
s: secrets

define DIRENV

We like $(BOLD)https://direnv.net/$(NORMAL) to manage environment variables.
This is an $(BOLD).envrc$(NORMAL) template that you can use as a starting point:

    PATH_add script
    PATH_add bin
    PATH_add ~/.krew/bin

    export XDG_CONFIG_HOME=$$(expand_path .config)

    export CIRCLE_TOKEN=
    export LINODE_CLI_TOKEN=
    export DNSIMPLE_ACCOUNT=
    export DNSIMPLE_TOKEN=

endef
export DIRENV
.PHONY: circle-token
circle-token:
ifndef CIRCLE_TOKEN
	@echo "$(RED)CIRCLE_TOKEN$(NORMAL) environment variable must be set\n" && \
	echo "Learn more about CircleCI API tokens $(BOLD)https://circleci.com/docs/2.0/managing-api-tokens/$(NORMAL) " && \
	echo "$$DIRENV" && \
	exit 1
endif

.PHONY: linode-cli-token
linode-cli-token:
ifndef LINODE_CLI_TOKEN
	@echo "$(RED)LINODE_CLI_TOKEN$(NORMAL) environment variable must be set" && \
	echo "Learn more about Linode API tokens $(BOLD)https://cloud.linode.com/profile/tokens$(NORMAL) " && \
	echo "$$DIRENV" && \
	exit 1
endif

.PHONY: dnsimple-creds
dnsimple-creds:
ifndef DNSIMPLE_ACCOUNT
	@echo "$(RED)DNSIMPLE_ACCOUNT$(NORMAL) environment variable must be set" && \
	echo "This will be the account's numerical ID, e.g. $(BOLD)00000$(NORMAL)" && \
	echo "$$DIRENV" && \
	exit 1
endif
ifndef DNSIMPLE_TOKEN
	@echo "$(RED)DNSIMPLE_TOKEN$(NORMAL) environment variable must be set" && \
	echo "Get a DNSimple user access token $(BOLD)https://dnsimple.com/user?account_id=$(DNSIMPLE_ACCOUNT)$(NORMAL) " && \
	echo "$$DIRENV" && \
	exit 1
endif

.PHONY: sync-secrets
sync-secrets: $(LPASS)
	@$(LPASS) sync

.PHONY: postgres
postgres: $(LPASS)
	@echo "export PG_DOTCOM_PASS=$$($(LPASS) show --notes 7298637973371173308)"

.PHONY: campaignmonitor
CM_SMTP_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/CM_SMTP_TOKEN)"
CM_API_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/CM_API_TOKEN_2)"
campaignmonitor: $(LPASS)
	@echo "export CM_SMTP_TOKEN=$(CM_SMTP_TOKEN)" && \
	echo "export CM_API_TOKEN=$(CM_API_TOKEN)"
.PHONY: campaignmonitor-lke-secret
campaignmonitor-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic campaignmonitor \
	  --from-literal=smtp_token=$(CM_SMTP_TOKEN) \
	  --from-literal=api_token=$(CM_API_TOKEN) \
	| $(KUBECTL) apply --filename -

GITHUB_CLIENT_ID := "$$($(LPASS) show --notes Shared-changelog/secrets/GITHUB_CLIENT_ID)"
GITHUB_CLIENT_SECRET := "$$($(LPASS) show --notes Shared-changelog/secrets/GITHUB_CLIENT_SECRET)"
GITHUB_API_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/GITHUB_API_TOKEN2)"
.PHONY: github
github: $(LPASS)
	@echo "export GITHUB_CLIENT_ID=$(GITHUB_CLIENT_ID)" && \
	echo "export GITHUB_CLIENT_SECRET=$(GITHUB_CLIENT_SECRET)" && \
	echo "export GITHUB_API_TOKEN=$(GITHUB_API_TOKEN)"
.PHONY: github-lke-secret
github-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic github \
	  --from-literal=client_id=$(GITHUB_CLIENT_ID) \
	  --from-literal=client_secret=$(GITHUB_CLIENT_SECRET) \
	  --from-literal=api_token=$(GITHUB_API_TOKEN) \
	| $(KUBECTL) apply --filename -

HCAPTCHA_SECRET_KEY := "$$($(LPASS) show --notes Shared-changelog/secrets/HCAPTCHA_SECRET_KEY)"
.PHONY: hcaptcha
hcaptcha: $(LPASS)
	@echo "export HCAPTCHA_SECRET_KEY=$(HCAPTCHA_SECRET_KEY)"
.PHONY: hcaptcha-lke-secret
hcaptcha-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
		create secret generic hcaptcha \
		--from-literal=secret_key=$(HCAPTCHA_SECRET_KEY) \
	| $(KUBECTL) apply --filename -

HACKERNEWS_USER := "$$($(LPASS) show --notes Shared-changelog/secrets/HN_USER_1)"
HACKERNEWS_PASS := "$$($(LPASS) show --notes Shared-changelog/secrets/HN_PASS_1)"
.PHONY: hackernews
hackernews: $(LPASS)
	@echo "export HN_USER=$(HACKERNEWS_USER)" && \
	echo "export HN_PASS=$(HACKERNEWS_PASS)"
.PHONY: hackernews-lke-secret
hackernews-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic hackernews \
	  --from-literal=user=$(HACKERNEWS_USER) \
	  --from-literal=pass=$(HACKERNEWS_PASS) \
	| $(KUBECTL) apply --filename -

AWS_ACCESS_KEY_ID := "$$($(LPASS) show --notes Shared-changelog/secrets/AWS_ACCESS_KEY_ID)"
AWS_SECRET_ACCESS_KEY := "$$($(LPASS) show --notes Shared-changelog/secrets/AWS_SECRET_ACCESS_KEY)"
.PHONY: aws
aws: $(LPASS)
	@echo "export AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" && \
	echo "export AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)"
.PHONY: aws-lke-secret
aws-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic aws \
	  --from-literal=access_key_id=$(AWS_ACCESS_KEY_ID) \
	  --from-literal=secret_access_key=$(AWS_SECRET_ACCESS_KEY) \
	| $(KUBECTL) apply --filename -

BACKUPS_AWS_ACCESS_KEY := "$$($(LPASS) show --notes Shared-changelog/secrets/BACKUPS_AWS_ACCESS_KEY)"
BACKUPS_AWS_SECRET_KEY := "$$($(LPASS) show --notes Shared-changelog/secrets/BACKUPS_AWS_SECRET_KEY)"
.PHONY: backups_aws
backups_aws: $(LPASS)
	@echo "export BACKUPS_AWS_ACCESS_KEY=$(BACKUPS_AWS_ACCESS_KEY)" && \
	echo "export BACKUPS_AWS_SECRET_KEY=$(BACKUPS_AWS_SECRET_KEY)"
.PHONY: backups-aws-lke-secret
backups-aws-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic backups-aws \
	  --from-literal=access_key_id=$(BACKUPS_AWS_ACCESS_KEY) \
	  --from-literal=secret_access_key=$(BACKUPS_AWS_SECRET_KEY) \
	| $(KUBECTL) apply --filename -

TWITTER_CONSUMER_KEY := "$$($(LPASS) show --notes Shared-changelog/secrets/TWITTER_CONSUMER_KEY)"
TWITTER_CONSUMER_SECRET := "$$($(LPASS) show --notes Shared-changelog/secrets/TWITTER_CONSUMER_SECRET)"
.PHONY: twitter
twitter: $(LPASS)
	@echo "export TWITTER_CONSUMER_KEY=$(TWITTER_CONSUMER_KEY)" && \
	echo "export TWITTER_CONSUMER_SECRET=$(TWITTER_CONSUMER_SECRET)"
.PHONY: twitter-lke-secret
twitter-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic twitter \
	  --from-literal=consumer_key=$(TWITTER_CONSUMER_KEY) \
	  --from-literal=consumer_secret=$(TWITTER_CONSUMER_SECRET) \
	| $(KUBECTL) apply --filename -

SECRET_KEY_BASE := "$$($(LPASS) show --notes Shared-changelog/secrets/SECRET_KEY_BASE)"
SIGNING_SALT := "$$($(LPASS) show --notes Shared-changelog/secrets/SIGNING_SALT)"
.PHONY: app
app: $(LPASS)
	@echo "export SECRET_KEY_BASE=$(SECRET_KEY_BASE)" && \
	echo "export SIGNING_SALT=$(SIGNING_SALT)"
.PHONY: app-lke-secret
app-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic app \
	  --from-literal=secret_key_base=$(SECRET_KEY_BASE) \
	  --from-literal=signing_salt=$(SIGNING_SALT) \
	| $(KUBECTL) apply --filename -

SLACK_INVITE_API_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/SLACK_INVITE_API_TOKEN)"
SLACK_APP_API_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/SLACK_APP_API_TOKEN)"
SLACK_DEPLOY_WEBHOOK := "$$($(LPASS) show --notes Shared-changelog/secrets/SLACK_DEPLOY_WEBHOOK)"
.PHONY: slack
slack: $(LPASS)
	@echo "export SLACK_INVITE_API_TOKEN=$(SLACK_INVITE_API_TOKEN)" && \
	echo "export SLACK_APP_API_TOKEN=$(SLACK_APP_API_TOKEN)"
.PHONY: slack-lke-secret
slack-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic slack \
	  --from-literal=app_api_token=$(SLACK_APP_API_TOKEN) \
	  --from-literal=deploy_webhook=$(SLACK_DEPLOY_WEBHOOK) \
	  --from-literal=invite_api_token=$(SLACK_INVITE_API_TOKEN) \
	| $(KUBECTL) apply --filename -

ROLLBAR_ACCESS_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/ROLLBAR_ACCESS_TOKEN)"
.PHONY: rollbar
rollbar: $(LPASS)
	@echo "export ROLLBAR_ACCESS_TOKEN=$(ROLLBAR_ACCESS_TOKEN)"
.PHONY: rollbar-lke-secret
rollbar-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic rollbar \
	  --from-literal=access_token=$(ROLLBAR_ACCESS_TOKEN) \
	| $(KUBECTL) apply --filename -

BUFFER_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/BUFFER_TOKEN_3)"
.PHONY: buffer
buffer: $(LPASS)
	@echo "export BUFFER_TOKEN=$(BUFFER_TOKEN)"
.PHONY: buffer-lke-secret
buffer-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic buffer \
	  --from-literal=token=$(BUFFER_TOKEN) \
	| $(KUBECTL) apply --filename -

COVERALLS_REPO_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/COVERALLS_REPO_TOKEN)"
.PHONY: coveralls
coveralls: $(LPASS)
	@echo "export COVERALLS_REPO_TOKEN=$(COVERALLS_REPO_TOKEN)"
.PHONY: coveralls-lke-secret
coveralls-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic coveralls \
	  --from-literal=repo_token=$(COVERALLS_REPO_TOKEN) \
	| $(KUBECTL) apply --filename -

ALGOLIA_APPLICATION_ID := "$$($(LPASS) show --notes Shared-changelog/secrets/ALGOLIA_APPLICATION_ID)"
ALGOLIA_API_KEY := "$$($(LPASS) show --notes Shared-changelog/secrets/ALGOLIA_API_KEY2)"
.PHONY: algolia
algolia: $(LPASS)
	@echo "export ALGOLIA_APPLICATION_ID=$(ALGOLIA_APPLICATION_ID)" && \
	echo "export ALGOLIA_API_KEY=$(ALGOLIA_API_KEY)"
.PHONY: algolia-lke-secret
algolia-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic algolia \
	  --from-literal=application_id=$(ALGOLIA_APPLICATION_ID) \
	  --from-literal=api_key=$(ALGOLIA_API_KEY) \
	| $(KUBECTL) apply --filename -

PLUSPLUS_SLUG := "$$($(LPASS) show --notes Shared-changelog/secrets/PLUSPLUS_SLUG_1)"
.PHONY: plusplus
plusplus: $(LPASS)
	@echo "export PLUSPLUS_SLUG_1=$(PLUSPLUS_SLUG)"
.PHONY: plusplus-lke-secret
plusplus-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic plusplus \
	  --from-literal=slug=$(PLUSPLUS_SLUG) \
	| $(KUBECTL) apply --filename -

FASTLY_API_TOKEN := "$$($(LPASS) show --notes Shared-changelog/secrets/FASTLY_API_TOKEN)"
.PHONY: fastly
fastly: $(LPASS)
	@echo "export FASTLY_API_TOKEN=$(FASTLY_API_TOKEN)"
.PHONY: fastly-lke-secret
fastly-lke-secret: | lke-ctx $(LPASS)
	@$(KUBECTL) --namespace $(CHANGELOG_NAMESPACE) --dry-run=client --output=yaml \
	  create secret generic fastly \
	  --from-literal=token=$(FASTLY_API_TOKEN) \
	| $(KUBECTL) apply --filename -
