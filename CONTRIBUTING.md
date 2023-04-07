✅ By participating in this project you agree to abide by [our Contributor Code of Conduct](https://changelog.com/coc)

## How can I contribute?

We prefer small incremental changes that can be reviewed and merged quickly.
It's OK if it takes multiple pull requests to close an issue.

Each improvement should land in our primary branch within a few hours.
The sooner we can get multiple people looking at and agreeing on a specific change, the quicker we will have it out in production.
The quicker we can get these small improvements in production, the quicker we can find out what doesn't work, or what we have missed.

The added benefit is that this will force everyone to think about handling partially implemented features & non-breaking changes.
Both are great approaches, and in our 10years+ experience, they work really well in practice.

### 1/3. DCO

Contributions to this project **must** be accompanied by a [Developer Certificate of Origin](https://github.com/apps/dco) (DCO).

All commit messages **must** contain the `Signed-off-by: <USER> <EMAIL>` line.
They **must** match the commit author, otherwise commits cannot be merged.
When committing, use the `--signoff` flag:

```shell
git commit --signoff
```

### 2/3. Fork, clone & configure upstream

- [Fork](https://github.com/thechangelog/changelog.com/fork)
- Clone your fork
- Add the upstream repository as a new remote:

```console
git remote add upstream git@github.com:thechangelog/changelog.com.git
```

#### 💡 Alternatively, you can use the [`gh` CLI](https://cli.github.com/):

```console
gh repo fork thechangelog/changelog.com
# ✓ Created fork gerhard/changelog.com
# ? Would you like to clone the fork? Yes
# Cloning into 'changelog.com'...
# remote: Enumerating objects: 46047, done.
# remote: Counting objects: 100% (1015/1015), done.
# remote: Compressing objects: 100% (365/365), done.
# remote: Total 46047 (delta 643), reused 973 (delta 627), pack-reused 45032
# Receiving objects: 100% (46047/46047), 60.17 MiB | 17.64 MiB/s, done.
# Resolving deltas: 100% (34752/34752), done.
# ✓ Cloned fork

cd changelog.com
git remote -v
# origin	git@github.com:gerhard/changelog.com.git (fetch)
# origin	git@github.com:gerhard/changelog.com.git (push)
# upstream	git@github.com:thechangelog/changelog.com.git (fetch)
# upstream	git@github.com:thechangelog/changelog.com.git (push)
```

### 3/3. Create a pull request


```console
# Create a new branch
git checkout -b <DESCRIPTIVE-CHANGE-TITLE>

# Make changes to your branch
# ...

# Commit changes - remember to sign!
git commit --all --signoff

# Push your new branch
git push <DESCRIPTIVE-CHANGE-TITLE>
```

Create a new pull request via https://github.com/thechangelog/changelog.com

## How do I run the application locally?

You will need to have the following dependencies installed:
- [PostgreSQL](https://www.postgresql.org/download/) v14
- [Elixir](https://elixir-lang.org/install.html) v1.14
- [Erlang/OTP](https://www.erlang.org/downloads) v25 - usually installed as an Elixir dependency
- [Node.js](https://nodejs.org/en/download/) v18 LTS - [latest-v18.x](https://nodejs.org/download/release/latest-v18.x/)
- [Yarn](https://yarnpkg.com/getting-started/install) v1.22

This is what that looks like on macOS 12, our usual development environment:

<img src="changelog-local-dev-2022.png">

```console
# 🛠 INSTALL DEPENDENCIES 🛠
brew install postgresql@14 elixir node@14 yarn imagemagick

#👇 installed on an iMac Pro (2017) running macOS 12.6.1 in ~2mins on Nov. 13, 2022 by @gerhard
# - PostgreSQL v14.6
# - Elixir v1.14.4
# - Erlang v25.3
# - Node.js v18.15.0
# - Yarn v1.22.19
# - ImageMagick v7.1
# 👆 installed on an iMac Pro (2017) running macOS 12.6.1 in ~2mins on Nov. 13, 2022 by @gerhard

# 🪣 CONFIGURE DATABASE 🪣
# Add correct PostgreSQL to PATH
export PATH="$(brew --prefix)/opt/postgresql@14/bin:$PATH"
# Start PostgreSQL
postgres -D $(brew --prefix)/var/postgresql@14
# Create user "postgres" with password "postgres"
createuser postgres --password --createdb
# Create changelog_dev db owned by the postgres user
createdb changelog_dev --username=postgres
# Create changelog_test db owned by the postgres user
createdb changelog_test --username=postgres

# 💜 CONFIGURE APP 💜
# Install deps
mix deps.get
# Prepare dev database
mix ecto.setup

# 🌈 CONFIGURE STATIC ASSETS 🌈
cd assets
# Add correct Node.js to PATH
export PATH="$(brew --prefix)/opt/node@18/bin:$PATH"
# Install dependencies requires for static assets
yarn install
cd ..

# 🏃 RUN APP 🏃
mix phx.server
# Go to http://localhost:4000

# 🏋️ TESTS 🏋️
mix test
```

## How to upgrade 💜 Elixir, 🚜 Erlang/OTP & ⬢ Node.js?

1. Update `ElixirVersion` & `ErlangVersion` in `magefiles/image/runtime.go` to latest [hexpm/elixir](https://hub.docker.com/r/hexpm/elixir/tags?page=1&ordering=last_updated&name=ubuntu-jammy)
2. While here, also update `NodejsVersion` to [latest-v18.x](https://nodejs.org/download/release/latest-v18.x/)
3. Commit & push to check that image builds successfully in GitHub Actions
    - _Alternatively_, build the image locally via: `cd magefiles && go run main.go image:runtime`

After you confirm that the image builds successfully:
1. Update `.devcontainer/docker-compose.yml` with new image tag
2. Ensure that Elixir minor version in `mix.exs` is accurate
3. Update Elixir, Erlang/OTP & Node.js version in `CONTRIBUTING.md` (this file)

Commit and push everything, then wait for all GitHub Actions checks to go green
✅ . At this point, one of the maintainers will review, approve & merge this
change. Thank you very much!

## How to use 🐳 Docker Engine running on ✈️ Fly.io?

Ensure that you have a [Fly.io Wireguard Tunnel configured locally](https://fly.io/docs/reference/private-networking/#creating-your-tunnel-configuration).
You may also need to [install `flyctl`](https://fly.io/docs/hands-on/install-flyctl/).

Given an active Fly.io Wireguard tunnel:

1. Check that the Wireguard tunnel works:
```
dig +noall +answer _apps.internal txt
_apps.internal.		5	IN	TXT	"changelog-2022-03-13,docker-2022-06-13,old-flower-9005,postgres-2022-03-12"
```
1. Configure `docker` CLI to use Docker Engine running on Fly.io:
```
export DOCKER_HOST=tcp://[fdaa:0:4556:a7b:21e0:1:1f9d:2]:2375
```
1. Check that `docker` CLI can connect to the remote Docker Engine:
```
docker info
...
Server:
 Containers: 1
  Running: 1
  Paused: 0
  Stopped: 0
 Server Version: 20.10.17
...
```

Any `docker` commands will now run against this remote Docker Engine now. `cd
magefiles && go run main.go -w image:runtime` also needs a Docker Engine to
resolve all its dependencies, and then run.

## Using GitHub Codespaces

A pre-configured Codespace can be launched for this repo by following the instructions [here](https://docs.github.com/codespaces/developing-in-codespaces/creating-a-codespace-for-a-repository). Everything you need to start contributing is installed and the following commands will start the site:

```console
# CONFIGURE APP
mix deps.get
mix ecto.setup

# CONFIGURE STATIC ASSETS
cd assets
yarn install

# RUN APP
mix phx.server
```

### Codespaces + VS Code Web Editor

If you are developing in the VS Code web editor two extra steps are required for the site to be able to load static assets correctly. Port forwarding utilizes a dynamic HTTPS `*.preview.app.github.dev` URL when developing in the web editor.

1. Set the `CODESPACES_WEB` environment variable. This tells the app to construct appropriate static asset paths.

   ```console
   export CODESPACES_WEB=true
   ```

2. After running the app the URL it is exposed on is visible in the `Toggle Ports` VS Code view (port 4000). Launch that URL and configure your browser to allow it to load insecure content via the instructions [here](https://experienceleague.adobe.com/docs/target/using/experiences/vec/troubleshoot-composer/mixed-content.html). This is necessary to allow js/css to be accessible over HTTP when the `*.preview.app.github.dev` site is using HTTPS.
