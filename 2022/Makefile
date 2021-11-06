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
include $(CURDIR)/linode.mk
include $(CURDIR)/secrets.mk
include $(CURDIR)/metrics-server.mk
include $(CURDIR)/grafana-agent.mk
include $(CURDIR)/local-path-provisioner.mk
include $(CURDIR)/external-dns.mk
include $(CURDIR)/traefik.mk
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
