define RSYNC_UPLOADS
    rsync --archive --delete --update --inplace --verbose --progress --human-readable \
      $(MIGRATE_FROM):/uploads/ /uploads/
endef
.PHONY: rsync-uploads
rsync-uploads: ## ru  | Synchronise uploads between remote hosts
ifndef MIGRATE_FROM
	@echo "$(RED)MIGRATE_FROM$(NORMAL) make variable must be set to the host we are migrating from" \
	&& echo "e.g. core@2019i.changelog.com" \
	&& exit 1
endif
	@ssh -t $(HOST_SSH_USER)@$(HOST) "sudo --preserve-env --shell $(RSYNC_UPLOADS)"
.PHONY: ru
ru: rsync-uploads

# Rather than creating a new container which needs to access the db container over a custom network,
# exec in the db backup container instead. Secrets are in place, let's just rock'n'roll!
define DB_RESTORE_CONTEXT
docker exec --interactive --tty \
  \$$(docker ps --quiet --latest --filter name=$(DOCKER_STACK)_db_backup) \
  bash
endef
.PHONY: db-restore-interactive
db-restore-interactive: ## dbri| Restore DB from backup interactively
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(DB_RESTORE_CONTEXT)"
.PHONY: dbri
dbri: db-restore-interactive

.PHONY: db-restore-interactive-local
db-restore-interactive-local:
	@$(DB_RESTORE_CONTEXT)
.PHONY: dbril
dbril: db-restore-interactive-local

define STACK_PUBLIC_IP
$$(dig +short $(DOCKER_STACK).changelog.com)
endef
.PHONY: force-resolve-stack
force-resolve-stack: ## frs | Force *.changelog.com resolution to this stack
	@echo -e "$(STACK_PUBLIC_IP)\tchangelog.com www.changelog.com cdn.changelog.com" \
	| sudo tee -a /etc/hosts
.PHONY: frs
frs: force-resolve-stack

.PHONY: force-resolve-stack-rm
force-resolve-stack-rm: ## frsr| Remove force *.changelog.com resolution to this stack
	@sudo sed -i.bak "/$(STACK_PUBLIC_IP)/d" /etc/hosts
frsr: force-resolve-stack-rm
