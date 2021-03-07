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
@printf 'Run $(BOLD)eval "$$(make env)"$(NORMAL)\n'
exit 1
endef

include $(CURDIR)/deps.mk
include $(CURDIR)/linode.mk
include $(CURDIR)/external-dns.mk
include $(CURDIR)/cert-manager.mk
include $(CURDIR)/ingress-nginx.mk
include $(CURDIR)/postgres.mk
include $(CURDIR)/keel.mk
