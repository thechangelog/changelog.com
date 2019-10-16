
.PHONY: bootstrap-image
bootstrap-image: build-bootstrap-image publish-bootstrap-image ## bi  | Build & publish thechangelog/bootstrap Docker image
.PHONY: bi
bi: bootstrap-image

.PHONY: build-bootstrap-image
build-bootstrap-image: $(DOCKER)
	@cd docker \
	&& $(DOCKER) build \
	  --build-arg DOCKER_COMPOSE_VERSION=$$($(COMPOSE) version --short) \
	  --build-arg GIT_REPOSITORY=$(GIT_REPOSITORY) \
	  --build-arg GIT_BRANCH=$(GIT_BRANCH) \
	  --build-arg DOCKER_SERVICE_NAME=$(DOCKER_STACK)_app \
	  --build-arg MAKEFILE=$(MAKEFILE) \
	  --tag thechangelog/bootstrap:$(BUILD_VERSION) \
	  --tag thechangelog/bootstrap:$(DOCKER_STACK) \
	  --file Dockerfile.bootstrap .
.PHONY: bbi
bbi: build-bootstrap-image

.PHONY: publish-bootstrap-image
publish-bootstrap-image: $(DOCKER)
	@$(DOCKER) push thechangelog/bootstrap:$(BUILD_VERSION) \
	&& $(DOCKER) push thechangelog/bootstrap:$(DOCKER_STACK)

.PHONY: db-backup-image
db-backup-image: build-db-backup-image publish-db-backup-image ## dbi | Build & publish thechangelog/db_backup Docker image
.PHONY: dbi
dbi: db-backup-image

.PHONY: build-db-backup-image
build-db-backup-image: $(DOCKER)
	@cd docker && \
	$(DOCKER) build \
	  --build-arg STACK_VERSION=$(DOCKER_STACK) \
	  --tag thechangelog/db_backup:$(BUILD_VERSION) \
	  --tag thechangelog/db_backup:$(DOCKER_STACK) \
	  --file Dockerfile.db_backup .
.PHONY: bdbi
bdbi: build-db-backup-image

.PHONY: publish-db-backup-image
publish-db-backup-image: $(DOCKER)
	@$(DOCKER) push thechangelog/db_backup:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/db_backup:$(DOCKER_STACK)

.PHONY: build-image-local
build-image-local: $(DOCKER)
	@$(DOCKER) build --pull --tag thechangelog/changelog.com:local --file docker/Dockerfile.local .
.PHONY: bil
bil: build-image-local

.PHONY: proxy-image
proxy-image: build-proxy-image publish-proxy-image ## pi  | Build & publish thechangelog/proxy Docker image
.PHONY: pi
pi: proxy-image

.PHONY: build-proxy-image
build-proxy-image: $(DOCKER)
	@cd nginx && \
	$(DOCKER) build --no-cache --tag thechangelog/proxy:$(BUILD_VERSION) --tag thechangelog/proxy:latest .
.PHONY: bpi
bpi: build-proxy-image

.PHONY: publish-proxy-image
publish-proxy-image: $(DOCKER)
	@$(DOCKER) push thechangelog/proxy:$(BUILD_VERSION) && \
	$(DOCKER) push thechangelog/proxy:latest

.PHONY: runtime-image
runtime-image: build-runtime-image publish-runtime-image ## ri  | Build & publish thechangelog/runtime Docker image
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

