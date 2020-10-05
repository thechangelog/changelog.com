# https://github.com/jesseduffield/lazydocker
define LAZYDOCKER_CONTAINER
docker pull lazyteam/lazydocker:latest && \
docker run --rm --interactive --tty \
  --cpus 0.5 --memory 128M \
  --name lazydocker_$(USER) \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume lazydocker_$(USER):/.config/jesseduffield/lazydocker \
  lazyteam/lazydocker:latest
endef
.PHONY: lazydocker
lazydocker:
	@$(LAZYDOCKER_CONTAINER)
.PHONY: ld
ld: lazydocker

.PHONY: backups-image
backups-image: build-backups-image publish-backups-image
.PHONY: bi
bi: backups-image

.PHONY: build-backups-image
build-backups-image: $(DOCKER)
	@cd docker && \
	$(DOCKER) build \
	  --build-arg STACK_VERSION=$(STACK_VERSION) \
	  --tag thechangelog/backups:$(BUILD_VERSION) \
	  --tag thechangelog/backups:$(STACK_VERSION) \
	  --file Dockerfile.backups .
.PHONY: bbi
bbi: build-backups-image

.PHONY: publish-backups-image
publish-backups-image: $(DOCKER)
	@$(DOCKER) push thechangelog/backups:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/backups:$(STACK_VERSION)

.PHONY: runtime-image
runtime-image: build-runtime-image publish-runtime-image
.PHONY: ri
ri: runtime-image

.PHONY: build-runtime-image
build-runtime-image: $(DOCKER)
	@$(DOCKER) build --no-cache --tag thechangelog/runtime:$(BUILD_VERSION) --tag thechangelog/runtime:latest --file docker/Dockerfile.runtime .
.PHONY: bri
bri: build-runtime-image

.PHONY: publish-runtime-image
publish-runtime-image: $(DOCKER)
	$(DOCKER) push thechangelog/runtime:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/runtime:latest

