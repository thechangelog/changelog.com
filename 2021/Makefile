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

define env_not_set
@printf "$(RED)$(1)$(NORMAL) environment variable must be set\n"
@printf 'Run $(BOLD)make .env && source .env$(NORMAL)\n'
exit 1
endef

include $(CURDIR)/deps.mk
include $(CURDIR)/linode.mk
include $(CURDIR)/external-dns.mk
include $(CURDIR)/cert-manager.mk
include $(CURDIR)/ingress-nginx.mk
include $(CURDIR)/postgres.mk
include $(CURDIR)/keel.mk

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
