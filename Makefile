SHELL := bash# we want bash behaviour in all shell invocations
PLATFORM := $(shell uname)

RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)

ifneq (4,$(firstword $(sort $(MAKE_VERSION) 4)))
  $(warning $(BOLD)$(RED)GNU Make v4 or newer is required$(NORMAL))
  $(info On macOS it can be installed with $(BOLD)brew install make$(NORMAL) and run as $(BOLD)gmake$(NORMAL))
  $(error Please run with GNU Make v4 or newer)
endif



### VARS ###
#
# https://tools.ietf.org/html/rfc3339 format - s/:/./g so that Docker tag is valid
export BUILD_VERSION := $(shell date -u +'%Y-%m-%dT%H.%M.%SZ')

DOMAIN ?= changelog.com
DOCKER_STACK ?= 2019
DOCKER_STACK_FILE ?= docker/changelog.stack.yml

HOST ?= $(DOCKER_STACK)i.$(DOMAIN)
HOST_SSH_USER ?= core
RSYNC_SRC_HOST ?= root@172.104.216.248

HOSTNAME := $(DOCKER_STACK).$(DOMAIN)
HOSTNAME_LOCAL := changelog.localhost

GIT_REPOSITORY ?= https://github.com/thechangelog/changelog.com
GIT_BRANCH ?= master

APP_IMAGE ?= thechangelog/changelog.com:latest

export FQDN IPv4



### DEPS ###
#
ifeq ($(PLATFORM),Darwin)
DOCKER := /usr/local/bin/docker
COMPOSE := $(DOCKER)-compose
$(DOCKER) $(COMPOSE):
	@brew cask install docker
endif
ifeq ($(PLATFORM),Linux)
DOCKER ?= /usr/bin/docker
$(DOCKER): $(CURL)
	@sudo apt-get update && \
	sudo apt-get install apt-transport-https gnupg-agent && \
	$(CURL) -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
	APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key finger | \
	  grep --quiet "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88" && \
	echo "deb https://download.docker.com/linux/ubuntu $$(lsb_release -c -s) stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list && \
	sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io && \
	sudo adduser $$USER docker && newgrp docker && sudo service restart docker
COMPOSE ?= /usr/local/bin/docker-compose
$(COMPOSE):
	@sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose && \
	sudo chmod a+x /usr/local/bin/docker-compose
endif

CURL ?= /usr/bin/curl
ifeq ($(PLATFORM),Linux)
$(CURL):
	@sudo apt-get update && sudo apt-get install curl
endif

ifeq ($(PLATFORM),Darwin)
JQ := /usr/local/bin/jq
$(JQ):
	@brew install jq
endif
ifeq ($(PLATFORM),Linux)
JQ ?= /snap/bin/jq
$(JQ):
	@sudo snap install jq
endif

ifeq ($(PLATFORM),Darwin)
LPASS := /usr/local/bin/lpass
$(LPASS):
	@brew install lastpass-cli
endif
ifeq ($(PLATFORM),Linux)
LPASS := /usr/bin/lpass
$(LPASS):
	@sudo apt-get update && sudo apt-get install lastpass-cli
endif

TERRAFORM := /usr/local/bin/terraform
$(TERRAFORM):
ifeq ($(PLATFORM),Darwin)
	@brew install terraform
endif
ifeq ($(PLATFORM),Linux)
	$(error $(RED)Please install $(BOLD)terraform$(NORMAL) in $(TERRAFORM): https://www.terraform.io/downloads.html)
endif

ifeq ($(PLATFORM),Darwin)
OPENSSL := /usr/local/opt/openssl/bin/openssl
$(OPENSSL):
	@brew install openssl
endif
ifeq ($(PLATFORM),Linux)
OPENSSL := /usr/bin/openssl
$(OPENSSL):
	@sudo apt-get update && sudo apt-get install openssl
endif

ifeq ($(PLATFORM),Darwin)
WATCH := /usr/local/bin/watch
$(WATCH):
	@brew install watch
endif
ifeq ($(PLATFORM),Linux)
WATCH := /usr/bin/watch
endif

BATS := /usr/local/bin/bats
$(BATS):
ifeq ($(PLATFORM),Darwin)
	@brew install bats-core
endif
ifeq ($(PLATFORM),Linux)
	$(error $(RED)Please install $(BOLD)bats-core$(NORMAL) in $(BATS): https://github.com/bats-core/bats-core#installation)
endif

SECRETS := $(LPASS) ls "Shared-changelog/secrets"

TF := cd terraform && $(TERRAFORM)
TF_VAR := export TF_VAR_ssl_key="$$(lpass show --notes 8038492725192048930)" && export TF_VAR_ssl_cert="$$(lpass show --notes 7748004306557989540 && cat terraform/dhparams.pem)"

# Enable Terraform debugging if make runs in debug mode
ifneq (,$(findstring d,$(MFLAGS)))
  TF_LOG ?= debug
  export TF_LOG
endif



### TARGETS ###
#
.DEFAULT_GOAL := help

colours:
	@echo "$(BOLD)BOLD $(RED)RED $(GREEN)GREEN $(YELLOW)YELLOW $(NORMAL)"

.PHONY: $(HOST)
$(HOST): iaas create-docker-secrets bootstrap-docker

define BOOTSTRAP_CONTAINER
docker pull thechangelog/bootstrap:latest && \
docker run --rm --interactive --tty --name bootstrap \
  --env HOSTNAME=\$$HOSTNAME \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  --volume changelog.com:/app:rw \
  thechangelog/bootstrap:latest
endef
define DISABLE_APP_UPDATER
docker service scale $(DOCKER_STACK)_app_updater=0
endef
.PHONY: bootstrap-docker
bootstrap-docker:
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(DISABLE_APP_UPDATER) ; $(BOOTSTRAP_CONTAINER)"
.PHONY: bd
bd: bootstrap-docker

.PHONY: interactive-bootstrap
interactive-bootstrap:
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(BOOTSTRAP_CONTAINER) bash"
.PHONY: ib
ib: interactive-bootstrap

.PHONY: add-secret
add-secret: $(LPASS) ## as  | Add secret to LastPass
ifndef SECRET
	@echo "$(RED)SECRET$(NORMAL) environment variable must be set to the name of the secret that will be added" && \
	echo "This value must be in upper-case, e.g. $(BOLD)SOME_SECRET$(NORMAL)" && \
	echo "This value must not match any of the existing secrets:" && \
	$(SECRETS) && \
	exit 1
endif
	@$(LPASS) add --notes "Shared-changelog/secrets/$(SECRET)"
.PHONY: as
as: add-secret

.PHONY: prevent-incompatible-deps-reaching-the-docker-image
prevent-incompatible-deps-reaching-the-docker-image:
	@rm -fr deps

.PHONY: create-dirs-mounted-as-volumes
create-dirs-mounted-as-volumes:
	@mkdir -p $(CURDIR)/priv/{uploads,db}

.PHONY: bootstrap-image
bootstrap-image: build-bootstrap-image publish-bootstrap-image ## bi  | Build & publish thechangelog/bootstrap Docker image
.PHONY: bi
bi: bootstrap-image

.PHONY: build-bootstrap-image
build-bootstrap-image: $(DOCKER)
	@cd docker && \
	$(DOCKER) build \
	  --build-arg GIT_REPOSITORY=$(GIT_REPOSITORY) \
	  --build-arg GIT_BRANCH=$(GIT_BRANCH) \
	  --tag thechangelog/bootstrap:$(BUILD_VERSION) \
	  --tag thechangelog/bootstrap:latest \
	  --file Dockerfile.bootstrap .
.PHONY: bbi
bbi: build-bootstrap-image

.PHONY: publish-bootstrap-image
publish-bootstrap-image: $(DOCKER)
	@$(DOCKER) push thechangelog/bootstrap:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/bootstrap:latest

.PHONY: build
build: $(COMPOSE) prevent-incompatible-deps-reaching-the-docker-image ## b   | Build changelog.com app container
	@$(COMPOSE) build
.PHONY: b
b: build

.PHONY: build-test
build-test: $(COMPOSE) prevent-incompatible-deps-reaching-the-docker-image ## bt  | Build Docker image required to run tests locally
	@$(COMPOSE) run --rm -e MIX_ENV=test -e DB_URL=ecto://postgres@db:5432/changelog_test app mix do deps.get, compile, ecto.create
.PHONY: bt
bt: build-test

SEPARATOR := ---------------------------------------------------------------------------------
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:+.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN { FS = "[:#]" } ; { printf "$(SEPARATOR)\n\033[36m%-22s\033[0m %s\n", $$1, $$4 }' ; \
	echo $(SEPARATOR)

.PHONY: clean-docker
clean-docker: $(DOCKER) $(COMPOSE) ## cd  | Remove all changelog containers, images & volumes
	@$(COMPOSE) stop && \
	$(DOCKER) stack rm $(DOCKER_STACK) && \
	$(DOCKER) system prune && \
	$(DOCKER) volume prune && \
	$(DOCKER) volume ls | awk '/changelog|$(DOCKER_STACK)/ { system("$(DOCKER) volume rm " $$2) }' ; \
	$(DOCKER) images | awk '/changelog|$(DOCKER_STACK)/ { system("$(DOCKER) image rm " $$1 ":" $$2) }'
.PHONY: cd
cd: clean-docker

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

.PHONY: contrib
contrib: $(COMPOSE) prevent-incompatible-deps-reaching-the-docker-image create-dirs-mounted-as-volumes ## c   | Contribute to changelog.com by running a local copy
	@bash -c "trap '$(COMPOSE) down' INT ; \
	  $(COMPOSE) up ; \
	  [[ $$? =~ 0|2 ]] || \
	    ( echo 'You might want to run $(BOLD)make build contrib$(NORMAL) if app dependencies have changed' && exit 1 )"
.PHONY: c
c: contrib

.PHONY: create-docker-secrets
create-docker-secrets: $(LPASS) ## cds | Create Docker secrets
	@$(SECRETS) | \
	awk '! /secrets\/? / { print($$1) }' | \
	while read -r secret ; do \
	  export secret_key="$$($(LPASS) show --name $$secret)" ; \
	  export secret_value="$$($(LPASS) show --notes $$secret)" ; \
	  echo "Creating $(BOLD)$(YELLOW)$$secret_key$(NORMAL) secret on $(HOST)..." ; \
	  echo "Prevent ssh from hijacking stdin: https://github.com/koalaman/shellcheck/wiki/SC2095" > /dev/null ; \
	  if [ $(HOST) = localhost ] ; then \
	    echo $$secret_value | docker secret create $$secret_key - || true ; \
	  else \
	    ssh $(HOST_SSH_USER)@$(HOST) "echo $$secret_value | docker secret create $$secret_key - || true" < /dev/null || exit 1 ; \
	  fi \
	done && \
	echo "$(BOLD)$(GREEN)All secrets are now setup as Docker secrets$(NORMAL)" && \
	echo "A Docker secret cannot be modified - it can only be removed and created again, with a different value" && \
	echo "A Docker secret can only be removed if it is not bound to a Docker service" && \
	echo "It might be easier to define a new secret, e.g. $(BOLD)ALGOLIA_API_KEY2$(NORMAL)"
.PHONY: cds
cds: create-docker-secrets

define VERSION_CHECK
VERSION="$$($(CURL) --silent --location \
  --write-out '$(NORMAL)HTTP/%{http_version} %{http_code} in %{time_total}s' \
  http://$(HOSTNAME)/version.txt)" && \
echo $(BOLD)$(PRE_VERSION)$$VERSION @ $$(date)
endef
.PHONY: check-deployed-version
check-deployed-version: PRE_VERSION = $(GIT_REPOSITORY)/tree/
check-deployed-version: $(CURL) ## cdv | Check the currently deployed git sha
	@$(VERSION_CHECK)
.PHONY: cdv
cdv: check-deployed-version

.PHONY: check-deployed-version-local
check-deployed-version-local: HOSTNAME = $(HOSTNAME_LOCAL)
check-deployed-version-local: $(CURL)
	@$(VERSION_CHECK)
.PHONY: cdvl
cdvl: check-deployed-version-local

# https://github.com/bcicen/ctop
define CTOP_CONTAINER
docker pull quay.io/vektorlab/ctop:latest && \
docker run --rm --interactive --tty \
  --cpus 0.5 --memory 128M \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --name ctop_$(USER) \
  quay.io/vektorlab/ctop:latest
endef
.PHONY: ctop
ctop: ## ct  | View real-time container metrics & logs remotely
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(CTOP_CONTAINER)"
.PHONY: ct
ct: ctop

.PHONY: ctop-local
ctop-local:
	@$(CTOP_CONTAINER)
.PHONY: ctl
ctl: ctop-local

.PHONY: remove-docker-secrets
remove-docker-secrets: $(LPASS)
	@if [ $(HOST) = localhost ] ; then \
	  docker secret ls | awk '/ago/ { system("docker secret rm " $$1) }' ; \
	else \
	  ssh $(HOST_SSH_USER)@$(HOST) "docker secret ls | awk '/ago/ { system(\"docker secret rm \" \$$1) }'" ; \
	fi
.PHONY: rds
rds: remove-docker-secrets

.PHONY: db-backup-image
db-backup-image: build-db-backup-image publish-db-backup-image ## dbi | Build & publish thechangelog/db_backup Docker image
.PHONY: dbi
dbi: db-backup-image

.PHONY: build-db-backup-image
build-db-backup-image: $(DOCKER)
	@cd docker && \
	$(DOCKER) build \
	  --tag thechangelog/db_backup:$(BUILD_VERSION) \
	  --tag thechangelog/db_backup:latest \
	  --file Dockerfile.db_backup .
.PHONY: bdbi
bdbi: build-db-backup-image

.PHONY: publish-db-backup-image
publish-db-backup-image: $(DOCKER)
	@$(DOCKER) push thechangelog/db_backup:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/db_backup:latest

.PHONY: deploy-docker-stack
deploy-docker-stack: $(DOCKER) ## dds | Deploy the changelog.com Docker Stack
	@export HOSTNAME ; \
	$(DOCKER) service scale $(DOCKER_STACK)_app_updater=0 ; \
	$(DOCKER) stack deploy --compose-file $(DOCKER_STACK_FILE) --prune $(DOCKER_STACK)
.PHONY: dds
dds: deploy-docker-stack

priv/db:
	@mkdir -p priv/db

.PHONY: deploy-docker-stack-local
deploy-docker-stack-local: DOCKER_STACK_FILE = docker/changelog.stack.local.yml
deploy-docker-stack-local: deploy-docker-stack priv/db
.PHONY: ddsl
ddsl: deploy-docker-stack-local

.PHONY: build-image-local
build-image-local: $(DOCKER)
	@$(DOCKER) build --pull --tag thechangelog/changelog.com:local --file docker/Dockerfile.local .
.PHONY: bil
bil: build-image-local

.PHONY: update-app-service-local
update-app-service-local: $(DOCKER)
	@$(DOCKER) service update --force --image thechangelog/changelog.com:local --update-monitor 10s $(DOCKER_STACK)_app
.PHONY: uasl
uasl: update-app-service-local

.PHONY: env-secrets
env-secrets: postgres campaignmonitor github aws backups_aws twitter app slack rollbar buffer coveralls algolia ## es  | Print secrets stored in LastPass as env vars
.PHONY: es
es: env-secrets

.PHONY: iaas
iaas: linode-token dnsimple-creds terraform/dhparams.pem init validate apply ## i   | Provision IaaS infrastructure
.PHONY: i
i: iaas

# https://github.com/hishamhm/htop
define HTOP_CONTAINER
docker pull jess/htop:latest && \
docker run --rm --interactive --tty \
  --cpus 0.5 --memory 128M \
  --net="host" --pid="host" \
  --name htop_$(USER) \
  jess/htop:latest
endef
.PHONY: htop
htop: ## ht  | View real-time host system metrics
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(HTOP_CONTAINER)"
.PHONY: ht
ht: htop

.PHONY: htop-local
htop-local:
	@$(HTOP_CONTAINER)
.PHONY: htl
htl: htop-local

# https://www.linode.com/docs/platform/nodebalancer/nodebalancer-reference-guide/#diffie-hellman-parameters
terraform/dhparams.pem: $(OPENSSL)
	@$(OPENSSL) dhparam -out terraform/dhparams.pem 2048

.PHONY: init
init: $(TERRAFORM)
	@$(TF) init

.PHONY: validate
validate: $(TERRAFORM)
	@$(TF_VAR) && $(TF) validate

.PHONY: plan
plan: $(TERRAFORM)
	@$(TF_VAR) && $(TF) plan

.PHONY: apply
apply: $(TERRAFORM)
	@$(TF_VAR) && $(TF) apply

.PHONY: legacy-assets
legacy-assets: $(DOCKER)
	@echo "$(YELLOW)This is a secret target that is only meant to be executed if legacy assets are present locally$(NORMAL)" && \
	echo "$(YELLOW)If this runs with an incorrect $(BOLD)./nginx/www/wp-content$(NORMAL)$(YELLOW), the resulting Docker image will miss relevant files$(NORMAL)" && \
	read -rp "Are you sure that you want to continue? (y|n) " -n 1 && ([[ $$REPLY =~ ^[Yy]$$ ]] || exit) && \
	cd nginx && $(DOCKER) build --tag thechangelog/legacy_assets --file Dockerfile.legacy_assets . && \
	$(DOCKER) push thechangelog/legacy_assets

CHANGELOG_SERVICES_SEPARATOR := ----------------------------------------------------------------------------------------
define CHANGELOG_SERVICES

                                                                        $(BOLD)$(RED)Private$(NORMAL)   $(BOLD)$(GREEN)Public$(NORMAL)
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(RED)Papertrail$(NORMAL)               | https://papertrailapp.com/dashboard                       |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(RED)Fastly$(NORMAL)                   | https://manage.fastly.com/services/all                    |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(RED)Linode$(NORMAL)                   | https://cloud.linode.com/dashboard                        |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(RED)Pivotal Tracker$(NORMAL)          | https://www.pivotaltracker.com/n/projects/1650121         |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(RED)Rollbar Dashboard$(NORMAL)        | https://rollbar.com/changelogmedia/changelog.com/         |
| $(BOLD)$(RED)Rollbar Deploys$(NORMAL)          | https://rollbar.com/changelogmedia/changelog.com/deploys/ |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(RED)Pingdom Uptime$(NORMAL)           | https://my.pingdom.com/reports/uptime                     |
| $(BOLD)$(RED)Pingdom Page Speed$(NORMAL)       | https://my.pingdom.com/reports/rbc                        |
| $(BOLD)$(RED)Pingdom Visitor Insights$(NORMAL) | https://my.pingdom.com/3/visitor-insights                 |
| $(BOLD)$(GREEN)Pingdom Status$(NORMAL)           | http://status.changelog.com/                              |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(GREEN)Netdata$(NORMAL)                  | https://netdata.changelog.com                             |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(GREEN)DockerHub$(NORMAL)                | https://hub.docker.com/u/thechangelog                     |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(GREEN)CircleCI$(NORMAL)                 | https://circleci.com/gh/thechangelog/changelog.com        |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(GREEN)GitHub$(NORMAL)                   | https://github.com/thechangelog/changelog.com             |
$(CHANGELOG_SERVICES_SEPARATOR)
| $(BOLD)$(GREEN)Slack$(NORMAL)                    | https://changelog.slack.com/                              |
$(CHANGELOG_SERVICES_SEPARATOR)

endef
export CHANGELOG_SERVICES
.PHONY: list-services
list-services: ## ls  | List of all services used by changelog.com
	@echo "$$CHANGELOG_SERVICES"
.PHONY: ls
ls: list-services

.PHONY: preview-readme
preview-readme: $(DOCKER) ## pre | Preview README & live reload on edit
	@$(DOCKER) run --interactive --tty --rm --name changelog_md \
	  --volume $(CURDIR):/data \
	  --volume $(HOME)/.grip:/.grip \
	  --expose 5000 --publish 5000:5000 \
	  mbentley/grip --context=. 0.0.0.0:5000
.PHONY: pre
pre: preview-readme

.PHONY: proxy-image
proxy-image: build-proxy-image publish-proxy-image ## pi  | Build & publish thechangelog/proxy Docker image
.PHONY: pi
pi: proxy-image

.PHONY: build-proxy-image
build-proxy-image: $(DOCKER)
	@cd nginx && \
	$(DOCKER) build --no-cache --tag thechangelog/proxy:$(BUILD_VERSION) --tag thechangelog/proxy:latest .
.PHONY: bpi
bpi: build-proxy-image

.PHONY: publish-proxy-image
publish-proxy-image: $(DOCKER)
	@$(DOCKER) push thechangelog/proxy:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/proxy:latest

.PHONY: e2e
e2e: $(BATS) $(CURL)

.PHONY: proxy-test
proxy-test: FQDN = $(DOMAIN)
proxy-test: IPv4 = 69.164.223.133
proxy-test: e2e
	@cd test/e2e && \
	$(BATS) proxy.bats proxy.prod.bats
.PHONY: pt
pt: proxy-test

.PHONY: proxy-test-local
proxy-test-local: FQDN = $(HOSTNAME_LOCAL)
proxy-test-local: IPv4 = 127.0.0.1
proxy-test-local: e2e
	@cd test/e2e && \
	$(BATS) proxy.bats proxy.local.bats
.PHONY: ptl
ptl: proxy-test-local

.PHONY: report-deploy
report-deploy: report-deploy-slack report-deploy-rollbar

.PHONY: report-deploy-rollbar
report-deploy-rollbar: $(CURL)
	@ROLLBAR_ACCESS_TOKEN="$$(cat /run/secrets/ROLLBAR_ACCESS_TOKEN)" && export ROLLBAR_ACCESS_TOKEN && \
	COMMIT_USER="$$(cat ./COMMIT_USER)" && export COMMIT_USER && \
	COMMIT_SHA="$$(cat ./COMMIT_SHA)" && export COMMIT_SHA && \
	$(CURL) --silent --fail --output /dev/null --request POST --url https://api.rollbar.com/api/1/deploy/ \
	  --data '{"access_token":"'$$ROLLBAR_ACCESS_TOKEN'","environment":"'$$ROLLBAR_ENVIRONMENT'","rollbar_username":"'$$COMMIT_USER'","revision":"'$$COMMIT_SHA'","comment":"Running in container '$$HOSTNAME' on host '$$NODE'"}'

.PHONY: report-deploy-slack
report-deploy-slack: $(CURL)
	@SLACK_DEPLOY_WEBHOOK="$$(cat /run/secrets/SLACK_DEPLOY_WEBHOOK)" && export SLACK_DEPLOY_WEBHOOK && \
	COMMIT_USER="$$(cat ./COMMIT_USER)" && export COMMIT_USER && \
	COMMIT_SHA="$$(cat ./COMMIT_SHA)" && export COMMIT_SHA && \
	$(CURL) --silent --fail --output /dev/null --request POST --url $$SLACK_DEPLOY_WEBHOOK \
	  --header 'Content-type: application/json' \
	  --data '{"text":"<$(GIT_REPOSITORY)/commit/'$$COMMIT_SHA'|'$${COMMIT_SHA:0:7}'> by <$(GIT_REPOSITORY)/commits?author='$$COMMIT_USER'|'$$COMMIT_USER'> is just coming up"}'

.PHONY: runtime-image
runtime-image: build-runtime-image publish-runtime-image ## ri  | Build & publish thechangelog/runtime Docker image
.PHONY: ri
ri: runtime-image

.PHONY: build-runtime-image
build-runtime-image: $(DOCKER)
	@$(DOCKER) build --no-cache --tag thechangelog/runtime:$(BUILD_VERSION) --tag thechangelog/runtime:latest --file docker/Dockerfile.runtime .
.PHONY: bri
bri: build-runtime-image

.PHONY: publish-runtime-image
publish-runtime-image: $(DOCKER)
	$(DOCKER) push thechangelog/runtime:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/runtime:latest

define APP_CONTAINER
$$($(DOCKER) container ls \
  --filter label=com.docker.swarm.service.name=$(DOCKER_STACK)_app \
  --format='{{.ID}}' \
  --last 1)
endef
.PHONY: remsh-local
remsh-local:
	@$(DOCKER) exec --tty --interactive "$(APP_CONTAINER)" \
	  bash -c "iex --hidden --sname debug@\$$HOSTNAME --remsh changelog@\$$HOSTNAME"
.PHONY: rl
rl: remsh-local

define RSYNC_UPLOADS
  sudo --preserve-env --shell \
    rsync --archive --delete --update --inplace --verbose --progress --human-readable \
      $(RSYNC_SRC_HOST):/data/www/uploads/ /uploads/
endef
.PHONY: rsync-uploads
rsync-uploads: ## ru  | Synchronise uploads between remote hosts
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(RSYNC_UPLOADS)"
.PHONY: ru
ru: rsync-uploads

.PHONY: rsync-small-uploads-local
rsync-small-uploads-local: create-dirs-mounted-as-volumes
	@rsync --archive --delete --update --inplace --verbose --progress --human-readable \
	  "$(RSYNC_SRC_HOST):/data/www/uploads/{avatars,covers,icons,logos}" $(CURDIR)/priv/uploads/
.PHONY: rsul
rsul: rsync-small-uploads-local

.PHONY: secrets
secrets: $(LPASS) ## s   | List all LastPass secrets
	@$(SECRETS)
.PHONY: s
s: secrets

.PHONY: ssh
ssh: ## ssh | SSH into $HOST
	@ssh $(HOST_SSH_USER)@$(HOST)

.PHONY: ssl-report
ssl-report: ## ssl | Run an SSL report via SSL Labs
	@open "https://www.ssllabs.com/ssltest/analyze.html?d=$(HOSTNAME)&latest"
.PHONY: ssl
ssl: ssl-report

.PHONY: test
test: $(COMPOSE) ## t   | Run tests as they run on CircleCI
	@$(COMPOSE) run --rm -e MIX_ENV=test -e DB_URL=ecto://postgres@db:5432/changelog_test app mix test
.PHONY: t
t: test

test_flakes:
	@mkdir -p test_flakes

TEST_RUNS ?= 10
.PHONY: find-flaky-tests
find-flaky-tests: test_flakes
	@for TEST_RUN_NO in {1..$(TEST_RUNS)}; do \
	  echo "RUNNING TEST $$TEST_RUN_NO ... " ; \
	  ($(MAKE) --no-print-directory test >> test_flakes/$$TEST_RUN_NO && \
	    rm test_flakes/$$TEST_RUN_NO && \
	    echo -e "$(GREEN)PASS$(NORMAL)\n") || \
	  echo -e "$(RED)FAIL$(NORMAL)\n"; \
	done

.PHONY: watch
watch: $(WATCH) $(DOCKER) ## w   | Watch all containers
	@$(WATCH) -c "$(DOCKER) ps --all \
	  --format='table {{.Status}}\t{{.Names}}\t{{.Image}}\t{{.ID}}'"
.PHONY: w
w: watch

define UPDATE_NETDATA
docker pull netdata/netdata && \
docker service update --force --image netdata/netdata $(DOCKER_STACK)_netdata
endef
.PHONY: update_netdata
update_netdata:
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(UPDATE_NETDATA)"

define DIRENV

We like $(BOLD)https://direnv.net/$(NORMAL) to manage environment variables.
This is an $(BOLD).envrc$(NORMAL) template that you can use as a starting point:

    PATH_add script

    export CIRCLE_TOKEN=
    export TF_VAR_linode_token=
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

.PHONY: linode-token
linode-token:
ifndef TF_VAR_linode_token
	@echo "$(RED)TF_VAR_linode_token$(NORMAL) environment variable must be set" && \
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
campaignmonitor: $(LPASS)
	@echo "export CM_SMTP_TOKEN=$$($(LPASS) show --notes 4518157498237793892)" && \
	echo "export CM_API_TOKEN=$$($(LPASS) show --notes 2172742429466797248)"
.PHONY: github
github: $(LPASS)
	@echo "export GITHUB_CLIENT_ID=$$($(LPASS) show --notes 6311620502443842879)" && \
	echo "export GITHUB_CLIENT_SECRET=$$($(LPASS) show --notes 6962532309857955032)" && \
	echo "export GITHUB_API_TOKEN=$$($(LPASS) show --notes 5059892376198418454)"
.PHONY: aws
aws: $(LPASS)
	@echo "export AWS_ACCESS_KEY_ID=$$($(LPASS) show --notes 5523519094417729320)" && \
	echo "export AWS_SECRET_ACCESS_KEY=$$($(LPASS) show --notes 1520570655547620905)"
.PHONY: backups_aws
backups_aws: $(LPASS)
	@echo "export BACKUPS_AWS_ACCESS_KEY=$$($(LPASS) show --notes 2383382642830769087)" && \
	echo "export BACKUPS_AWS_SECRET_KEY=$$($(LPASS) show --notes 4892015361959119196)"
.PHONY: twitter
twitter: $(LPASS)
	@echo "export TWITTER_CONSUMER_KEY=$$($(LPASS) show --notes 1932439368993537002)" && \
	echo "export TWITTER_CONSUMER_SECRET=$$($(LPASS) show --notes 5671723614506961548)"
.PHONY: app
app: $(LPASS)
	@echo "export SECRET_KEY_BASE=$$($(LPASS) show --notes 7272253808960291967)" && \
	echo "export SIGNING_SALT=$$($(LPASS) show --notes 8954230056631744101)"
.PHONY: slack
slack: $(LPASS)
	@echo "export SLACK_INVITE_API_TOKEN=$$($(LPASS) show --notes 3107315517561229870)" && \
	echo "export SLACK_APP_API_TOKEN=$$($(LPASS) show --notes 1152178239154303913)"
.PHONY: rollbar
rollbar: $(LPASS)
	@echo "export ROLLBAR_ACCESS_TOKEN=$$($(LPASS) show --notes 5433360937426957091)"
.PHONY: buffer
buffer: $(LPASS)
	@echo "export BUFFER_TOKEN=$$($(LPASS) show --notes 4791620911166920938)"
.PHONY: coveralls
coveralls: $(LPASS)
	@echo "export COVERALLS_REPO_TOKEN=$$($(LPASS) show --notes 8654919576068551356)"
.PHONY: algolia
algolia: $(LPASS)
	@echo "export ALGOLIA_APPLICATION_ID=$$($(LPASS) show --notes 5418916921816895235)" && \
	echo "export ALGOLIA_API_KEY=$$($(LPASS) show --notes 1668162557359149736)"
