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

