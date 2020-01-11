ifeq ($(PLATFORM),Darwin)
SED := /usr/local/bin/gsed
$(SED):
	brew install gnu-sed
else
SED := /bin/sed
endif

ifeq ($(PLATFORM),Darwin)
MONOLITH ?= /usr/local/bin/monolith
$(MONOLITH):
	brew install monolith
endif
ifeq ($(PLATFORM),Linux)
MONOLITH ?= /usr/bin/monolith
$(MONOLITH):
	$(error Please install monolith: https://github.com/Y2Z/monolith#installation)
endif

define ABSOLUTE_CHANGELOG_LINKS
$(SED) --in-place --regexp-extended --expression \
  's|href="/|href="https://changelog.com/|g ; s|action="/|action="https://changelog.com/|g ; s|data-play="/|data-play="https://changelog.com/|g'
endef

.PHONY: tmp/ten-curl.html
tmp/ten-curl.html: $(CURL)
	@mkdir -p tmp \
	&& $(CURL) --progress-bar --output $(@) https://changelog.com/ten \
	&& $(ABSOLUTE_CHANGELOG_LINKS) $(@)

.PHONY: tmp/ten-monolith.html
tmp/ten-monolith.html: $(MONOLITH)
	@mkdir -p tmp \
	&& $(MONOLITH) https://changelog.com/ten -I -o $(@) \
	&& $(ABSOLUTE_CHANGELOG_LINKS) $(@)

.PHONY: ten-image
ten-image: build-ten-image publish-ten-image

.PHONY: build-ten-image
build-ten-image: BUILD_VERSION = 2019-11-01T10.10.10Z
build-ten-image: $(DOCKER) tmp/ten-curl.html tmp/ten-monolith.html
	@$(DOCKER) build \
	  --pull \
	  --tag thechangelog/ten:$(BUILD_VERSION) \
	  --file docker/Dockerfile.ten \
	  $(CURDIR)

.PHONY: publish-ten-image
publish-ten-image: BUILD_VERSION = 2019-11-01T10.10.10Z
publish-ten-image: $(DOCKER)
	@$(DOCKER) push thechangelog/ten:$(BUILD_VERSION)
