# vim: set tabstop=4 shiftwidth=4 expandtab:

[private]
default:
    just --list

[private]
fmt:
    just --fmt --check --unstable

[private]
brew:
    @which brew >/dev/null \
    || (echo {{ GREEN }}🍺 Installing Homebrew...{{ RESET }} \
        && NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
        && echo {{ REDB }}{{ WHITE }} 👆 You must follow NEXT STEPS above before continuing 👆 {{ RESET }})

[private]
brew-linux-shell:
    @echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

[private]
just: brew
    @[ -f $(brew--prefix)/bin/just ] \
    || brew install just

[private]
just0:
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin

[private]
imagemagick: brew
    @[ -d $(brew --prefix)/opt/imagemagick ] \
    || brew install imagemagick

[private]
check-postgres-envs:
    @(grep -q postgresql@16 <<< $PATH) \
    || (echo "{{ REDB }}{{ WHITE }}Postgres 16 not present in PATH.{{ RESET }} To fix this, run: {{ GREENB }}{{ WHITE }}direnv allow{{ RESET }}" && exit 127)

export OP_ACCOUNT := "changelog.1password.com"

# Create .envrc.secrets with credentials from 1Password
[group('team')]
envrc-secrets:
    op inject --in-file envrc.secrets.op --out-file .envrc.secrets

[private]
postgres: brew
    @[ -d $(brew --prefix)/opt/postgresql@16 ] \
    || brew install postgresql@16

[private]
gpg: brew
    @[ -d $(brew --prefix)/opt/gpg ] \
    || brew install gpg

# https://tldp.org/LDP/abs/html/exitcodes.html
[private]
asdf:
    @which asdf >/dev/null \
    || (brew install asdf \
        && echo {{ REDB }}{{ WHITE }} 👆 You must follow CAVEATS above before continuing 👆 {{ RESET }})

[private]
asdf-shell: brew
    @echo "source $(brew --prefix)/opt/asdf/libexec/asdf.sh"

# Install all system dependencies
[group('contributor')]
install: asdf brew imagemagick postgres gpg
    @awk '{ system("asdf plugin-add " $1) }' < .tool-versions
    @asdf install

export ELIXIR_ERL_OPTIONS := if os() == "linux" { "+fnu" } else { "" }

# Add Oban Pro repository
[group('team')]
add-oban-pro-repo:
    [ -n "$OBAN_LICENSE_KEY" ] \
    && [ -n "$OBAN_KEY_FINGERPRINT" ] \
    && mix hex.repo add oban https://getoban.pro/repo --fetch-public-key $OBAN_KEY_FINGERPRINT --auth-key $OBAN_LICENSE_KEY

# Get app dependencies
[group('contributor')]
deps: add-oban-pro-repo
    mix local.hex --force
    mix deps.get --only dev
    mix deps.get --only test

[private]
pg_ctl:
    @which pg_ctl >/dev/null \
    || (echo "{{ REDB }}{{ WHITE }}Postgres 16 is not installed.{{ RESET }} To fix this, run: {{ GREENB }}{{ WHITE }}just install{{ RESET }}" && exit 127)

# Start Postgres server
[group('contributor')]
postgres-up: pg_ctl check-postgres-envs
    @(pg_ctl status | grep -q "is running") || pg_ctl start

# Stop Postgres server
[group('contributor')]
postgres-down: pg_ctl check-postgres-envs
    @(pg_ctl status | grep -q "no server running") || pg_ctl stop

[private]
postgres-db db: check-postgres-envs
    @(psql --list --quiet --tuples-only | grep -q {{ db }}) \
    || createdb {{ db }}

export DB_USER := `whoami`


# Delete & replace changelog_dev with a prod db dump
[confirm("This DELETEs and REPLACEs changelog_dev with the prod db dump. Are you sure that you want to continue?")]
[group('team')]
restore-dev-db-from-prod format="c": changelog_dev
    @echo "\n{{ GREEN }}🛬 Dumping prod db...{{ RESET }}"
    [ -f $DB_PROD_DBNAME.{{ format }}.sql ] \
    || time PGSSLMODE=require PGPASSWORD=$(op read op://changelog/neon/password) pg_dump \
        --format={{ format }} --verbose \
        --host=$DB_PROD_HOST \
        --username=$DB_PROD_USERNAME \
        --dbname=$DB_PROD_DBNAME > $DB_PROD_DBNAME.{{ format }}.sql
    @echo "\n{{ GREEN }}🛫 Recreating {{ CHANGELOG_DEV_DB }} from prod dump{{ RESET }}..."
    dropdb {{ CHANGELOG_DEV_DB }}
    createdb {{ CHANGELOG_DEV_DB }}
    time pg_restore \
        --format=c --verbose \
        --dbname={{ CHANGELOG_DEV_DB }} \
        --exit-on-error \
        --no-owner \
        --no-privileges < $DB_PROD_DBNAME.{{ format }}.sql
    @echo "\n{{ GREEN }}⚡️ Warm up the query planner...{{ RESET }} https://www.postgresql.org/docs/current/sql-analyze.html..."
    time psql --dbname={{ CHANGELOG_DEV_DB }} --command "ANALYZE VERBOSE;"


[private]
changelog_test: postgres-up (postgres-db "changelog_test")

# Run app tests
[group('contributor')]
test: changelog_test
    mix test

CHANGELOG_DEV_DB := "changelog_dev"
[private]
changelog_dev: postgres-up (postgres-db CHANGELOG_DEV_DB)
    mix ecto.setup

[private]
yarn:
    @which yarn >/dev/null \
    || (echo "{{ REDB }}{{ WHITE }}Yarn is not installed.{{ RESET }} To fix this, run: {{ GREENB }}{{ WHITE }}just install{{ RESET }}" && exit 127)

[private]
assets: yarn
    cd assets && yarn install

# Run app in dev mode
[group('contributor')]
dev: changelog_dev assets
    mix phx.server

# Setup everything needed for your first contribution
[group('contributor')]
contribute: install
    #!/usr/bin/env bash
    eval "$(just asdf-shell)"
    just deps
    just test
    just dev

[private]
actions-runner:
    docker run --interactive --tty \
        --volume=changelog-linuxbrew:/home/linuxbrew/.linuxbrew \
        --volume=changelog-asdf:/home/runner/.asdf \
        --volume=.:/home/runner/work --workdir=/home/runner/work \
        --env=HOST=$(hostname) --publish=4000:4000 \
        --pull=always ghcr.io/actions/actions-runner

[linux]
[private]
do-it:
    #!/usr/bin/env bash
    sudo apt update
    DEBIAN_FRONTEND=noninteractive sudo apt install -y build-essential curl git libncurses5-dev libssl-dev inotify-tools
    just brew
    eval "$(just brew-linux-shell)"
    just asdf
    eval "$(just asdf-shell)"
    just contribute

# Tag Kaizen $version with $episode & $discussion at $commit (recording date)
[group('team')]
tag-kaizen version episode discussion commit:
    git tag --force --sign \
        --message="Recorded as 🎧 <https://changelog.com/friends/{{ episode }}>" \
        --message="Discussed in https://github.com/thechangelog/changelog.com/discussions/{{ discussion }}" \
        kaizen.{{ version }} {{ commit }}
    git push --force origin kaizen.{{ version }}

# https://linux.101hacks.com/ps1-examples/prompt-color-using-tput/

BOLD := "$(tput bold)"
RESET := "$(tput sgr0)"
BLACK := "$(tput bold)$(tput setaf 0)"
RED := "$(tput bold)$(tput setaf 1)"
GREEN := "$(tput bold)$(tput setaf 2)"
YELLOW := "$(tput bold)$(tput setaf 3)"
BLUE := "$(tput bold)$(tput setaf 4)"
MAGENTA := "$(tput bold)$(tput setaf 5)"
CYAN := "$(tput bold)$(tput setaf 6)"
WHITE := "$(tput bold)$(tput setaf 7)"
BLACKB := "$(tput bold)$(tput setab 0)"
REDB := "$(tput setab 1)$(tput setaf 0)"
GREENB := "$(tput setab 2)$(tput setaf 0)"
YELLOWB := "$(tput setab 3)$(tput setaf 0)"
BLUEB := "$(tput setab 4)$(tput setaf 0)"
MAGENTAB := "$(tput setab 5)$(tput setaf 0)"
CYANB := "$(tput setab 6)$(tput setaf 0)"
WHITEB := "$(tput setab 7)$(tput setaf 0)"

# just actions-runner
# DEBIAN_FRONTEND=noninteractive sudo apt install -y curl
# eval $(grep j_ust.systems justfile)
# cd ../
# sudo chown -fR runner:runner work ~/.asdf
# cd work
# just do-it
#
# du -skh _build
# 72M
#
# du -skh deps
# 41M
#
# du -skh /home/linuxbrew/.linuxbrew
# 1.5G
# du -skh ~/.asdf
# 728M
