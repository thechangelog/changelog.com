DAGGER_BIN := dagger-$(DAGGER_VERSION)-$(platform)-amd64
DAGGER_URL := $(DAGGER_RELEASES)/download/v$(DAGGER_VERSION)/dagger-$(platform)-amd64
DAGGER := $(LOCAL_BIN)/$(DAGGER_BIN)

DAGGER_RELEASES := https://github.com/dagger/dagger/releases
DAGGER_VERSION := 0.1.0-alpha.27
DAGGER_DIR := $(LOCAL_BIN)/dagger_v$(DAGGER_VERSION)_$(platform)_amd64
DAGGER_URL := $(DAGGER_RELEASES)/download/v$(DAGGER_VERSION)/$(notdir $(DAGGER_DIR)).tar.gz
DAGGER := $(DAGGER_DIR)/dagger
$(DAGGER): | $(GH) $(CURL) $(LOCAL_BIN)
	@printf "$(BOLD)$(RED)curl will fail until repository is private$(NORMAL)\n"
	@printf "$(RED)$(CURL) --progress-bar --fail --location --output $(DAGGER_DIR).tar.gz $(DAGGER_URL)$(NORMAL)\n\n"
	@printf "$(BOLD)Using $(GREEN)gh$(NORMAL) $(BOLD)instead$(NORMAL)\n"
	$(GH) release download v$(DAGGER_VERSION) --repo dagger/dagger --pattern '*darwin_amd64.tar.gz' --dir $(LOCAL_BIN)
	mkdir -p $(DAGGER_DIR) && tar zxf $(DAGGER_DIR).tar.gz -C $(DAGGER_DIR)
	touch $(DAGGER)
	chmod +x $(DAGGER)
	$(DAGGER) version | grep $(DAGGER_VERSION)
	ln -sf $(DAGGER) $(LOCAL_BIN)/dagger
.PHONY: dagger
dagger: $(DAGGER)
.PHONY: releases-dagger
releases-dagger:
	$(OPEN) $(DAGGER_RELEASES)
