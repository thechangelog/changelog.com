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
    || (echo {{ _MAGENTA }}🍺 Installing Homebrew...{{ _RESET }} \
        && NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
        && echo {{ _REDB }}{{ _WHITE }} 👆 You must follow NEXT STEPS above before continuing 👆 {{ _RESET }})

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

# Create .envrc.secrets with credentials from 1Password
[group('team')]
envrc-secrets:
    op inject --in-file envrc.secrets.op --out-file .envrc.secrets

[private]
gpg: brew
    @[ -d $(brew --prefix)/opt/gpg ] \
    || brew install gpg

[private]
icu4c: brew
    @[ -d "$(brew --prefix icu4c)/lib/pkgconfig" ] \
    || brew install icu4c pkg-config

# https://tldp.org/LDP/abs/html/exitcodes.html
[private]
asdf:
    @which asdf >/dev/null \
    || (brew install asdf \
        && echo {{ _REDB }}{{ _WHITE }} 👆 You must follow CAVEATS above before continuing 👆 {{ _RESET }})

[private]
asdf-shell: brew
    @echo "source $(brew --prefix)/opt/asdf/libexec/asdf.sh"

# Install all system dependencies
[group('contributor')]
install: asdf brew imagemagick gpg icu4c
    @awk '{ system("asdf plugin-add " $1) }' < .tool-versions
    @PKG_CONFIG_PATH="$(brew --prefix icu4c)/lib/pkgconfig:$PKG_CONFIG_PATH" asdf install

export ELIXIR_ERL_OPTIONS := if os() == "linux" { "+fnu" } else { "" }

# Add Oban Pro hex repository
[group('team')]
add-oban-pro-hex-repo:
    [ -n "$OBAN_LICENSE_KEY" ] \
    && [ -n "$OBAN_KEY_FINGERPRINT" ] \
    && mix hex.repo add oban https://getoban.pro/repo --fetch-public-key $OBAN_KEY_FINGERPRINT --auth-key $OBAN_LICENSE_KEY

# Get app dependencies
[group('contributor')]
deps: add-oban-pro-hex-repo
    mix local.hex --force
    mix deps.get --only dev
    mix deps.get --only test

[private]
pg_ctl:
    @which pg_ctl >/dev/null \
    || (echo "{{ _REDB }}{{ _WHITE }}Postgres is not installed.{{ _RESET }} To fix this, run: {{ _GREENB }}just install{{ _RESET }}" && exit 127)

# Start Postgres server
[group('contributor')]
postgres-up: pg_ctl
    @(pg_ctl status | grep -q "is running") || pg_ctl start

# Stop Postgres server
[group('contributor')]
postgres-down: pg_ctl
    @(pg_ctl status | grep -q "no server running") || pg_ctl stop

[private]
postgres-db db:
    @(psql --list --quiet --tuples-only | grep -q {{ db }}) \
    || createdb {{ db }}

# Delete & replace changelog_dev with a prod db dump
[confirm("This DELETEs and REPLACEs changelog_dev with the prod db dump. Are you sure that you want to continue?")]
[group('team')]
restore-dev-db-from-prod format="c": changelog_dev
    @echo "\n{{ _MAGENTA }}🛬 Dumping prod db...{{ _RESET }}"
    [ -f $DB_PROD_DBNAME.{{ format }}.sql ] \
    || time PGSSLMODE=require PGPASSWORD=$(op read op://changelog/neon/password) pg_dump \
        --format={{ format }} --verbose \
        --host=$DB_PROD_HOST \
        --username=$DB_PROD_USERNAME \
        --dbname=$DB_PROD_DBNAME > $DB_PROD_DBNAME.{{ format }}.sql
    @echo "\n{{ _MAGENTA }}🛫 Recreating {{ _CHANGELOG_DEV_DB }} from prod dump...{{ _RESET }}"
    dropdb {{ _CHANGELOG_DEV_DB }}
    createdb {{ _CHANGELOG_DEV_DB }}
    time pg_restore \
        --format={{ format }} --verbose \
        --dbname={{ _CHANGELOG_DEV_DB }} \
        --exit-on-error \
        --no-owner \
        --no-privileges < $DB_PROD_DBNAME.{{ format }}.sql
    @echo "\n{{ _MAGENTA }}⚡️ Warm up the query planner...{{ _RESET }} https://www.postgresql.org/docs/current/sql-analyze.html"
    time psql --dbname={{ _CHANGELOG_DEV_DB }} --command "ANALYZE VERBOSE;"

[private]
neon *ARGS: npm
    @which neonctl >/dev/null \
    || (echo {{ _MAGENTA }}🧪 Installing neonctl...{{ _RESET }} \
        && npm install -g neonctl && echo {{ _MAGENTA }}neonctl{{ _RESET }} && neonctl --version)
    {{ if ARGS != "" { "neonctl " + ARGS } else { "neonctl" } }}

[private]
npm:
    @which npm >/dev/null \
    || (echo "{{ _REDB }}{{ _WHITE }}NPM is not installed.{{ _RESET }} To fix this, run: {{ _GREENB }}just install{{ _RESET }}" && exit 127)

_NEON_DB_BRANCH := env_var("USER") + "-" + datetime("%Y-%m-%d")

# Create a new branch off the prod db
[group('team')]
neon-create-branch:
    @echo "\n{{ _MAGENTA }}🔒 Checking Neon auth...{{ _RESET }}"
    just neon projects get $NEON_PROJECT_ID || just neon auth

    @echo "\n{{ _MAGENTA }}🌲 Creating Neon prod db branch...{{ _RESET }}"
    just neon branches get --project-id=$NEON_PROJECT_ID {{ _NEON_DB_BRANCH }} \
    || just neon branches create --project-id=$NEON_PROJECT_ID --name={{ _NEON_DB_BRANCH }}

    @echo "\n{{ _MAGENTA }}⚡️ Warm up the query planner...{{ _RESET }} https://www.postgresql.org/docs/current/sql-analyze.html"
    time psql "$(just neon-branch-connection-string {{ _NEON_DB_BRANCH }})" --command "ANALYZE VERBOSE;"

    @echo "\n{{ _MAGENTA }}💡 To use this Neon db branch in with your local dev app, run: {{ _RESET }}{{ _GREENB }}just dev-with-neon-branch {{ _NEON_DB_BRANCH }}{{ _RESET }}"

# Show $branch connection details
[group('team')]
neon-branch-connection branch *ARGS:
    @just neon connection-string {{ branch }} --project-id=$NEON_PROJECT_ID \
        --role-name=$DB_PROD_USERNAME --database-name=$DB_PROD_DBNAME --extended --output=yaml {{ ARGS }}

[private]
neon-branch-connection-string branch:
    @just neon-branch-connection {{ branch }} \
    | awk '/connection_string:/ { print $2 }'

# List prod db branches
[group('team')]
neon-branches: (neon "branches list --project-id=$NEON_PROJECT_ID")

[private]
neon-connection-convert-to-env:
    #!/usr/bin/env bash
    awk '
        /^host:/ {gsub(/^host: /, ""); print "export DB_HOST=" $0}
        /^role:/ {gsub(/^role: /, ""); print "export DB_USER=" $0}
        /^password:/ {gsub(/^password: /, ""); print "export DB_PASS=" $0}
        /^database:/ {gsub(/^database: /, ""); print "export DB_NAME=" $0}
    '

[private]
changelog_test: postgres-up (postgres-db "changelog_test")

# Run app tests
[group('contributor')]
test: changelog_test
    mix test

_CHANGELOG_DEV_DB := env_var("CHANGELOG_DEV_DB")

[private]
changelog_dev: postgres-up (postgres-db _CHANGELOG_DEV_DB)
    mix ecto.setup

[private]
yarn:
    @which yarn >/dev/null \
    || (echo "{{ _REDB }}{{ _WHITE }}Yarn is not installed.{{ _RESET }} To fix this, run: {{ _GREENB }}just install{{ _RESET }}" && exit 127)

[private]
assets: yarn
    cd assets && yarn install

# Run app in dev mode
[group('contributor')]
dev: changelog_dev assets
    mix phx.server

# Run app in dev mode with $branch
[group('team')]
dev-with-neon-branch branch: assets
    #!/usr/bin/env bash
    eval "$(just neon-branch-connection {{ branch }} \
    | just neon-connection-convert-to-env)"
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

_BOLD := "$(tput bold)"
_RESET := "$(tput sgr0)"
_BLACK := "$(tput bold)$(tput setaf 0)"
_RED := "$(tput bold)$(tput setaf 1)"
_GREEN := "$(tput bold)$(tput setaf 2)"
_YELLOW := "$(tput bold)$(tput setaf 3)"
_BLUE := "$(tput bold)$(tput setaf 4)"
_MAGENTA := "$(tput bold)$(tput setaf 5)"
_CYAN := "$(tput bold)$(tput setaf 6)"
_WHITE := "$(tput bold)$(tput setaf 7)"
_BLACKB := "$(tput bold)$(tput setab 0)"
_REDB := "$(tput setab 1)$(tput setaf 0)"
_GREENB := "$(tput setab 2)$(tput setaf 0)"
_YELLOWB := "$(tput setab 3)$(tput setaf 0)"
_BLUEB := "$(tput setab 4)$(tput setaf 0)"
_MAGENTAB := "$(tput setab 5)$(tput setaf 0)"
_CYANB := "$(tput setab 6)$(tput setaf 0)"
_WHITEB := "$(tput setab 7)$(tput setaf 0)"

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
