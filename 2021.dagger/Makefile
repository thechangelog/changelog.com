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


include $(CURDIR)/deps.mk
include $(CURDIR)/dagger.mk

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
