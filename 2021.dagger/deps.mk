LOCAL_BIN := $(CURDIR)/bin
$(LOCAL_BIN):
	mkdir -p $@

PATH := $(LOCAL_BIN):$(PATH)
export PATH

.PHONY: env
env::
	@echo 'alias m=make'
	@echo 'export PATH="$(LOCAL_BIN):$$PATH"'

ifeq ($(PLATFORM),Darwin)
OPEN := open
else
OPEN := xdg-open
endif

XDG_CONFIG_HOME := $(CURDIR)/.config
export XDG_CONFIG_HOME
env::
	@echo 'export XDG_CONFIG_HOME="$(XDG_CONFIG_HOME)"'


CURL ?= /usr/bin/curl
ifeq ($(PLATFORM),Linux)
$(CURL):
	@sudo apt-get update && sudo apt-get install curl
endif
