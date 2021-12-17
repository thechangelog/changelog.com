SHELL := bash# we want bash behaviour in all shell invocations
PLATFORM := $(shell uname)
platform = $(shell echo $(PLATFORM) | tr A-Z a-z)
ifeq ($(PLATFORM),Darwin)
platform_alt = macOS
else
platform_alt = $(platform)
endif
MAKEFILE := $(firstword $(MAKEFILE_LIST))

# https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
GREY := \033[0;37m
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
MAGENTA := \033[0;35m
CYAN := \033[0;36m
BOLD := \033[1m
NORMAL := \033[0m
RESET := \033[0m

BASE_DIR := $(CURDIR)/..
MANIFESTS := $(CURDIR)/manifests

DNS_TTL ?= 600

K_CMD ?= apply
# Dump all objects (do not apply) if DEBUG variable is set
ifneq (,$(DEBUG))
  K_CMD = create --dry-run=client --output=yaml
endif

define env_not_set
@printf "$(RED)$(1)$(NORMAL) environment variable must be set\n" 1>&2
@printf 'Run $(BOLD)make .env && source .env$(NORMAL) and then retry\n' 1>&2
exit 1
endef

include $(CURDIR)/deps.mk
include $(CURDIR)/dagger.mk
include $(CURDIR)/linode.mk
include $(CURDIR)/secrets.mk
include $(CURDIR)/crossplane.mk
include $(CURDIR)/grafana-agent.mk
include $(CURDIR)/honeycomb-agent.mk
include $(CURDIR)/metrics-server.mk
include $(CURDIR)/parca.mk
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

.PHONY: clean
clean:
	rm -fr $(CURDIR)/{.config,.env,bin}
	rm -fr $(CURDIR)/../{.config,.envrc,.kube,bin,tmp}

.DEFAULT_GOAL := start
.PHONY: start
start: .env
	@printf "\nIf you have state in this directory, or the parent (top-level directory),\n$(YELLOW)you may want to start from scratch by running:$(NORMAL) $(BOLD)make clean$(NORMAL)\n\n"
	@printf "Otherwise just run $(BOLD)$(GREEN)source .env$(NORMAL) and carry on.\nmake shell completion will be configured afterwards\n\n"

# - [x] Backup 2020 db
# - [x] Restore 2020 db on 2021
# - [x] Upate Fastly back-end to 21.changelog.com
# - [x] IF REAL-TIME STATS DON'T LOOK HEALTHY, REVERT SERVICE CONFIG: https://manage.fastly.com/stats/real-time/services/7gKbcKSKGDyqU7IuDr43eG/datacenters/all
# - [x] Stop 2020 external-dns
# - [x] Configure 2021 external-dns to sync & linode-kubernetes-engine, so that other domains get updated
# - [x] Stop keel in 2020 & remove DockerHub webhook
# - [x] After 24h, delete 2020 setup & cleanup old config
