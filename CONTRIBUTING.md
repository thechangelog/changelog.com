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
- [PostgreSQL](https://www.postgresql.org/download/) v15
- [Elixir](https://elixir-lang.org/install.html) v1.15
- [Erlang/OTP](https://www.erlang.org/downloads) v26 - usually installed as an Elixir dependency
- [Node.js](https://nodejs.org/en/download/) v20 LTS - [latest-v20.x](https://nodejs.org/download/release/latest-v20.x/)
- [Yarn](https://yarnpkg.com/getting-started/install) v1.22
- [Golang](https://go.dev/doc/install) v1.20 - if you want to run CI locally

We are using [`asdf`](https://asdf-vm.com/) to install the correct dependency versions in our development environment.

This is what that looks like on macOS 12, our usual development environment:

<img src="changelog-local-dev-2022.png">

```console
# 🛠 INSTALL DEPENDENCIES 🛠
awk '{ system("asdf plugin-add " $1) }' < .tool-versions
asdf install

#👇 installed on a MacBook Pro 16" (2021) running macOS 12.7.1 in ~4mins on Dec 16, 2023 by @gerhard
# - Elixir v1.15.7
# - Erlang v26.2
# - Golang 1.20.12
# - Node.js v20.10.0
# - Yarn v1.22.19
# - PostgreSQL v15.3
#👆 installed on a MacBook Pro 16" (2021) running macOS 12.7.1 in ~4mins on Dec 16, 2023 by @gerhard

# You will also need to install imagemagick via Homebrew.
# asdf imagemagick plugin did not work for me.
brew install imagemagick

# 🪣 CONFIGURE DATABASE 🪣
# Start PostgreSQL
postgres # or pg_ctl start
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

1. Run e.g. `asdf install erlang latest:26`
    - If a new version gets installed, run `asdf local erlang <INSTALLED_VERSION>`
2. Repeat previous step for Elixir & Node.js
3. Commit & push to check that image builds successfully in GitHub Actions
    - _Alternatively_, build the image locally via: `{ cd magefiles && go run main.go -w ../ image:runtime }`

After you confirm that the image builds successfully:
1. Update `.devcontainer/docker-compose.yml` with new image tag
2. Ensure that Elixir minor version in `mix.exs` is accurate
3. Update Elixir, Erlang/OTP & Node.js version in `CONTRIBUTING.md` (this file)

Commit and push everything, then wait for all GitHub Actions checks to go green
✅ . At this point, one of the maintainers will review, approve & merge this
change. Thank you very much!

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
