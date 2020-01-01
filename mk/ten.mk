ifeq ($(PLATFORM),Darwin)
MONOLITH ?= /usr/local/bin/monolith
$(MONOLITH):
	@brew install monolith
endif
ifeq ($(PLATFORM),Linux)
MONOLITH ?= /usr/bin/monolith
$(MONOLITH):
	$(error Please install monolith: https://github.com/Y2Z/monolith#installation)
endif

tmp/ten.html: $(MONOLITH)
	@mkdir -p tmp \
	&& $(MONOLITH) https://changelog.com/ten -I -o $(@)

.PHONY: ten-image
ten-image: build-ten-image publish-ten-image

.PHONY: build-ten-image
build-ten-image: BUILD_VERSION = 2019-12-31T20.20.10Z
build-ten-image: $(DOCKER) tmp/ten.html
	@$(DOCKER) build \
	  --pull \
	  --tag thechangelog/ten:$(BUILD_VERSION) \
	  --file docker/Dockerfile.ten \
	  .

.PHONY: publish-ten-image
publish-ten-image: BUILD_VERSION = 2019-12-31T20.20.10Z
publish-ten-image: $(DOCKER)
	@$(DOCKER) push thechangelog/ten:$(BUILD_VERSION)
