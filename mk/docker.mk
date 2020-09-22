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

.PHONY: db-backup-image
db-backup-image: build-db-backup-image publish-db-backup-image
.PHONY: dbi
dbi: db-backup-image

.PHONY: build-db-backup-image
build-db-backup-image: $(DOCKER)
	@cd docker && \
	$(DOCKER) build \
	  --build-arg STACK_VERSION=$(STACK_VERSION) \
	  --tag thechangelog/db_backup:$(BUILD_VERSION) \
	  --tag thechangelog/db_backup:$(STACK_VERSION) \
	  --file Dockerfile.db_backup .
.PHONY: bdbi
bdbi: build-db-backup-image

.PHONY: publish-db-backup-image
publish-db-backup-image: $(DOCKER)
	@$(DOCKER) push thechangelog/db_backup:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/db_backup:$(STACK_VERSION)

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

