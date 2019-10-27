.PHONY: todo
todo:
	@echo "* 2019-10-27 | GL | Remote Docker Linux instance with $(GREEN)DOCKER_HOST=ssh://changelog.dev$(NORMAL)" \
	; echo "* 2019-10-27 | GL | Compile assets with Parcel instead of Webpack - $(BOLD)https://en.parceljs.org/$(NORMAL)"

.PHONY: CFtodo
CFtodo: $(WATCH)
	@$(WATCH_MAKE_TARGET) todo
