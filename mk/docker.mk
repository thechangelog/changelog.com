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

.PHONY: howto-upgrade-elixir
howto-upgrade-elixir:
	@printf "$(BOLD)$(GREEN)All commands must be run in this directory. I propose a new side-by-side split to these instructions.$(NORMAL)\n\n"
	@printf "Pick an image with node (required by the asset pipeline) from $(BOLD)$(BLUE)https://hub.docker.com/r/circleci/elixir/tags?page=1&ordering=last_updated$(NORMAL)\n\n"
	@printf " 1/7. Update $(BOLD)docker/Dockerfile.runtime$(NORMAL) to use an image from the URL above, then run $(BOLD)make runtime-image$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 2/7. Update $(BOLD)docker/Dockerfile.production$(NORMAL) to the exact runtime version that was published in the previous step\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 3/7. Update $(BOLD).circleci/config.yml$(NORMAL) to the exact runtime version that was published in the previous step\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 4/7. Update $(BOLD).github/workflows/test.yml$(NORMAL) to the exact runtime version that was published in the previous step\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 5/7. Update $(BOLD)docker_dev/changelog.yml$(NORMAL) to the exact runtime version that was published in the previous step\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 6/7. Commit and push everything\n" ; read -rp " $(DONE)" -n 1
	@printf "\n 7/7. Watch the pipeline succeed and publish an app container image with the updated version of Elixir $(BOLD)$(BLUE)https://app.circleci.com/pipelines/github/thechangelog/changelog.com$(NORMAL)\n" ; read -rp " $(DONE)" -n 1
	@printf "\nIf the pipeline succeeded, the git version of the app will be promoted to live within about a minute, you can watch this with $(BOLD)watch -c make check-deployed-version$(NORMAL)\n"
	@printf "\nYou may want to update the elixir version in $(BOLD)mix.exs$(NORMAL)\n"
