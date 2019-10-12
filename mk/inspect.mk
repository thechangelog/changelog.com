# https://github.com/bcicen/ctop
define CTOP_CONTAINER
docker pull quay.io/vektorlab/ctop:latest && \
docker run --rm --interactive --tty \
  --cpus 0.5 --memory 128M \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --name ctop_$(USER) \
  quay.io/vektorlab/ctop:latest
endef
.PHONY: ctop
ctop: ## ct  | View real-time container metrics & logs remotely
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(CTOP_CONTAINER)"
.PHONY: ct
ct: ctop

.PHONY: ctop-local
ctop-local:
	@$(CTOP_CONTAINER)
.PHONY: ctl
ctl: ctop-local

# https://github.com/hishamhm/htop
define HTOP_CONTAINER
docker pull jess/htop:latest && \
docker run --rm --interactive --tty \
  --cpus 0.5 --memory 128M \
  --net="host" --pid="host" \
  --name htop_$(USER) \
  jess/htop:latest
endef
.PHONY: htop
htop: ## ht  | View real-time host system metrics
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(HTOP_CONTAINER)"
.PHONY: ht
ht: htop

.PHONY: htop-local
htop-local:
	@$(HTOP_CONTAINER)
.PHONY: htl
htl: htop-local

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
lazydocker: ## ld  | A simple terminal UI for both docker and docker-compose
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(LAZYDOCKER_CONTAINER)"
.PHONY: ld
ld: lazydocker

.PHONY: lazydocker-local
lazydocker-local:
	@$(LAZYDCOKER_CONTAINER)
.PHONY: ldl
ldl: lazydocker-local

define APP_CONTAINER
$$($(DOCKER) container ls \
  --filter label=com.docker.swarm.service.name=$(DOCKER_STACK)_app \
  --format='{{.ID}}' \
  --last 1)
endef
.PHONY: remsh-local
remsh-local:
	@$(DOCKER) exec --tty --interactive "$(APP_CONTAINER)" \
	  bash -c "iex --hidden --sname debug@\$$HOSTNAME --remsh changelog@\$$HOSTNAME"
.PHONY: rl
rl: remsh-local

.PHONY: ssh
ssh: ## ssh | SSH into $HOST
	@ssh $(HOST_SSH_USER)@$(HOST)

.PHONY: watch
watch: $(WATCH) $(DOCKER) ## w   | Watch all containers
	@$(WATCH) -c "$(DOCKER) ps --all \
	  --format='table {{.Status}}\t{{.Names}}\t{{.Image}}\t{{.ID}}'"
.PHONY: w
w: watch

