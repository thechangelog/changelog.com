SHELL := bash# we want bash behaviour in all shell invocations
PLATFORM := $(shell uname)
platform = $(shell echo $(PLATFORM) | tr A-Z a-z)
MAKEFILE := $(firstword $(MAKEFILE_LIST))

# https://linux.101hacks.com/ps1-examples/prompt-color-using-tput/
RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BOLD := $(shell tput bold)
NORMAL := $(shell tput sgr0)

MANIFESTS := $(CURDIR)/manifests

K_CMD ?= apply

define env_not_set
@printf "$(RED)$(1)$(NORMAL) environment variable must be set\n"
@printf 'Run $(BOLD)make .env && source .env$(NORMAL)\n'
exit 1
endef

include $(CURDIR)/deps.mk
include $(CURDIR)/linode.mk
include $(CURDIR)/secrets.mk
include $(CURDIR)/grafana-agent.mk
include $(CURDIR)/external-dns.mk
include $(CURDIR)/cert-manager.mk
include $(CURDIR)/ingress-nginx.mk
include $(CURDIR)/local-path-provisioner.mk
include $(CURDIR)/keel.mk
include $(CURDIR)/changelog.mk

define MAKE_TARGETS
  awk -F':+' '/^[^.%\t_][0-9a-zA-Z._%-]*:+.*$$/ { printf "%s\n", $$1 }' $(MAKEFILE_LIST)
endef

define BASH_AUTOCOMPLETE
complete -W \"$$($(MAKE_TARGETS) | sort | uniq)\" make gmake m
endef

env::
	@echo "$(BASH_AUTOCOMPLETE)"

.env:
	$(MAKE) --no-print-directory env SILENT="1>/dev/null 2>&1" > .env

# - [x] Backup 2020 db
# - [x] Restore 2020 db on 2021
# - [x] Upate Fastly back-end to 21.changelog.com
# - [x] IF REAL-TIME STATS DON'T LOOK HEALTHY, REVERT SERVICE CONFIG: https://manage.fastly.com/stats/real-time/services/7gKbcKSKGDyqU7IuDr43eG/datacenters/all
# - [x] Stop 2020 external-dns
# - [x] Configure 2021 external-dns to sync & linode-kubernetes-engine, so that other domains get updated
# - [x] Stop keel in 2020 & remove DockerHub webhook
# - [ ] After 24h, delete 2020 setup & cleanup old config
