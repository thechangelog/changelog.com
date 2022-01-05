DAGGER_VERSION := main

DAGGER_GIT_DIR := $(CURDIR)/tmp/dagger-$(DAGGER_VERSION)
$(DAGGER_GIT_DIR):
	git clone \
	  --branch $(DAGGER_VERSION) --single-branch --depth 1 \
	  git@github.com:dagger/dagger $(DAGGER_GIT_DIR)
.PHONY: dagger-dev
dagger-dev: $(DAGGER_GIT_DIR)
