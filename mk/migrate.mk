define RSYNC_UPLOADS
  sudo --preserve-env --shell \
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
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(RSYNC_UPLOADS)"
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
db-restore-interactive:
	@ssh -t $(HOST_SSH_USER)@$(HOST) "$(DB_RESTORE_CONTEXT)"
.PHONY: dbri
dbri: db-restore-interactive
