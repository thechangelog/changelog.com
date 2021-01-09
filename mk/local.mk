APP_VERSION ?= $(shell date -u +'%y.%-m.%-d')
export APP_VERSION

.PHONY: dev
dev:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
	cd assets && yarn install
	mix do ecto.create, ecto.migrate, phx.server

PG_MAJOR ?= 12
PG_INSTALL ?= /usr/local/opt/postgresql@$(PG_MAJOR)
PG_DIR ?= $(CURDIR)/tmp/postgres@$(PG_MAJOR)

$(PG_INSTALL):
	brew install postgresql@$(PG_MAJOR)

$(PG_DIR):
	$(PG_INSTALL)/bin/pg_ctl -D $(PG_DIR) init

db-ctl-%: $(PG_INSTALL) $(PG_DIR)
	$(PG_INSTALL)/bin/pg_ctl $(*) -D $(PG_DIR)
