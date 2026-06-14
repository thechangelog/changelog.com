---
name: new-fly-app-instance
description: >-
  Stand up a new changelog.com Fly.io app instance (named changelog-YYYY-MM-DD),
  validate the whole CI/CD pipeline from a fork first, and later promote the
  instance to production. Use when creating a fresh Fly app, rotating the
  production instance, testing deploys from a fork before a PR, or cutting
  APP_PROD_INSTANCE over to a new instance. The operator runs every command
  themselves on their host; these touch production (Neon Postgres, Cloudflare
  R2, the CDN), so the skill is human-in-the-loop by design.
---

# New Fly.io app instance — validate, create & promote

A guided runbook in two phases.

**Before the PR merges — validate from a fork:**

- **Part A — Prepare your fork.** Fork the repo and configure GitHub Actions so
  the pipeline can run in *your* account.
- **Part B — Create & prime the Fly app.** Stand up the dated instance and stage
  its one bootstrap secret.
- **Part C — Trigger the pipeline & verify.** Push to your fork's `master` to
  drive the workflow end-to-end and confirm it deploys to the new app.

**After the PR merges — promote to production:**

- **Part D — Promote to production.** Cut `APP_PROD_INSTANCE` and live traffic
  over to the new instance.

A–C validate a new instance from a fork before the PR lands; D happens later,
once the merged instance has proven itself.

## How to drive this skill — read every time

This runbook touches **production**: the Neon Postgres prod database, Cloudflare
R2 buckets, and the public CDN. Human-in-the-loop is the point — but the default
is to *do the work yourself and verify*, not to hand the operator a list of
commands to type.

**First, establish where you're running — the rules below depend on it:**

- **On the operator's host** — one copy of the repo, possibly already
  authenticated. No file syncing needed; you may run authed commands if `op` /
  `flyctl` are signed in (still confirm before any production mutation).
- **In a separate sandbox / VM** — a distinct copy of the repo, usually **not**
  authenticated for production. Mirror file changes to the host, and run
  1Password / Fly commands on the host.

Check at startup — `flyctl auth whoami`, `op whoami`, and whether this is the
operator's real working tree or a copy — and if unsure, ask. Say which mode
you're in before driving.

- **Run each step yourself; the operator stays in the loop.** Default to running
  commands here in the VM and verifying the result — don't hand the operator a
  list to type. They can always take a step over (then you verify). **Before any
  command that mutates production** (deploy, secret-set, DB/CDN change), say what
  it will do and get a yes first. One step at a time; don't advance until the
  current step is verified.
- **Guard 1Password-authed production commands.** Commands that need
  **1Password** — `op read` / `op signin`, `fnox exec --profile production|ci`,
  and the secret-set that wraps `op read` (B4) — touch the crown-jewel token. In
  a sandbox without auth, the operator runs these on the host and you verify from
  their output; **never** copy the OP service-account token or an `op` sign-in
  into a sandbox. On the host with `op` already signed in, you may run them —
  confirm first. (Same for Fly auth: if the current environment lacks it, the
  operator runs the `flyctl` step or supplies a token.)
- **Sandbox only: keep it in sync with the host.** When you're in a separate
  copy, every file change must land in **both** — edit here and give the operator
  the exact change for the host (or mirror their host change here), then `diff`
  to confirm they match. **On the host there's a single copy — skip this.**
- **Verify before advancing.** If output looks off, diagnose it together. Never
  "continue anyway".
- **Flag every production mutation loudly.** Where a step writes to the prod DB,
  R2, the CDN, or shared repo config, say so and confirm intent first.
- **Adapt to what's already done** — if a step was completed out of band, verify
  its result and skip ahead rather than redoing it.

Naming convention: a new instance is `changelog-YYYY-MM-DD` using the date it's
created — the date part is significant (it's how instances are told apart, and
it threads through the Fly app name, the `fly.io/<name>/` dir, and
`APP_PROD_INSTANCE`). Throughout, `${OLD}` is the current production app
(`mise env | rg APP_PROD_INSTANCE`, currently `changelog-2025-05-05`) and
`${NEW}` is the one being created.

---

# Before the PR merges — validate from a fork

Parts A–C run entirely in your fork and prove the new instance end-to-end before
the PR that adds it is merged.

## Part A — Prepare your fork

### A1. Fork the repo and confirm the URL

Ask the operator to fork `thechangelog/changelog.com` to their account and paste
the **fork URL** (e.g. `https://github.com/gerhard/changelog.com`). The fork is
public, so **verify it yourself** before continuing — e.g.
`gh repo view <owner>/changelog.com --json url,visibility,isFork` or fetch the
URL. Confirm it exists, is public, and is a fork. The fork owner is the
`IMAGE_OWNER` value in A2.

### A2. Set GitHub Actions variables & secrets on the fork

Under the fork's **Settings → Secrets and variables → Actions**:

**Variables** (Variables tab):

| Variable | Set to | Why |
| --- | --- | --- |
| `APP_PROD_INSTANCE` | `${NEW}` (e.g. `changelog-2026-06-14`) | The dated app this fork deploys to. mise.toml's `[env]` only supplies the *default* (`${OLD}`); the workflows forward `vars.APP_PROD_INSTANCE` so the fork targets its own app. The date must match the Fly app created in Part B. |
| `IMAGE_OWNER` | the fork owner (e.g. `gerhard`) | Publishes images to `ghcr.io/<owner>/changelog-{runtime,prod}` in *your* account instead of `thechangelog`. Defaults to `thechangelog` via mise.toml when unset. |
| `DEPLOY_FROM_REPO` | this repo as `github.com/owner/repo` (e.g. `github.com/gerhard/changelog.com`) | Opt-in gate for publish + deploy. Set it to the fork's own `github.com/<owner>/changelog.com` to run the full pipeline; leave unset for build & test only. No default anywhere — each repo that deploys declares itself. |
| `RUNS_ON` | `namespace` if this repo has Namespace.so access, else *(unset)* | `ship_it.yml` runs on Namespace.so when `RUNS_ON` contains `namespace`, otherwise GitHub-hosted `ubuntu-latest` — exactly one. Set `namespace` on any repo with access: the canonical repo **or** a fork that has it (e.g. `gerhard/changelog.com`, and others may). A fork *without* access leaves it unset and runs on GitHub. |

**Secrets** (Secrets tab):

| Secret | When | Why |
| --- | --- | --- |
| `OP_SERVICE_ACCOUNT_TOKEN` | only if testing publish/deploy in CI | A 1Password service-account token. Build & test run **unauthenticated**, so it's not needed for those. Publish (GHCR) and Deploy (Fly) resolve all other credentials via `fnox exec --profile ci`, which needs this token. |

> **Publish & deploy are gated by `DEPLOY_FROM_REPO`.** `github.yml` /
> `namespace.yml` carry
> `if: "${{ format('github.com/{0}', github.repository) == env.DEPLOY_FROM_REPO && github.ref_name == 'master' }}"`
> (compares the live `github.com/owner/repo` to the variable; `==` keeps it safe
> when the var is unset — `endsWith` would match an empty var. GitHub expressions
> have **no `replace`**, so the `github.com/` host is literal in `format`), and
> `mise-tasks/team/cd` builds the same string
> (`${GITHUB_SERVER_URL#https://}/${GITHUB_REPOSITORY}`) and guards on it. A fork opts into
> the full pipeline simply by setting `DEPLOY_FROM_REPO` to its own
> `github.com/<owner>/changelog.com` (and providing `OP_SERVICE_ACCOUNT_TOKEN`) —
> **no source edits.** Leave it unset for build & test only. The canonical repo
> must set `DEPLOY_FROM_REPO=github.com/thechangelog/changelog.com` for its own
> publish/deploy to run (the workflow `if:` reads the variable, not mise's
> defaults).

Confirm the variables/secrets are set (and whether the gate was touched) before
moving on.

---

## Part B — Create & prime the Fly app

Run B-steps from the host. `${NEW}` = the dated name from A2.

### B1. Create the Fly app

```bash
flyctl apps create ${NEW} --org changelog
```

Registers the app name in the `changelog` org. No machines, no traffic, no cost
yet — reversible via `flyctl apps destroy`. Healthy result: `New app created: ${NEW}`.

### B2. Copy the current instance's config

```bash
cp -r fly.io/${OLD} fly.io/${NEW}
cd fly.io/${NEW}
```

Each instance keeps its Fly config in `fly.io/<app-name>/`. Copying the current
prod instance gives a known-good baseline. Run the rest of Part B from inside
`fly.io/${NEW}`.

**Verify the copy.** Confirm it's a clean, unedited baseline:
`diff fly.io/${OLD}/fly.toml fly.io/${NEW}/fly.toml` must be **empty**
(identical). Any diff here means the copy is wrong — stop and resolve before the
B3 edits. *In a sandbox*, the operator's host `cp` won't appear locally —
reproduce it (`cp -r fly.io/${OLD} fly.io/${NEW}`) before diffing, so later edits
land on the right files.

### B3. Point `fly.toml` at the new app

Two **required** edits to `fly.io/${NEW}/fly.toml`:

- `app = "${NEW}"` — must match B1.
- `[env] APP_INSTANCE = "experimental"` — **important.** `config/prod.exs` only
  starts the Oban job queues when `APP_INSTANCE == "production"`; any other value
  leaves the queue list empty. So an `experimental` instance boots and serves
  HTTP but does **not** process scheduled jobs (Zulip import, feed/person
  bouncers, email) against the shared prod database. Without this, a second live
  instance would double-process those jobs.

**Then review the rest of the file against the Fly config reference.** The
copied config carries whatever conventions were current when the *previous*
instance was created, so this is the moment to catch drift. WebFetch the
reference linked at the top of `fly.toml`
(<https://fly.io/docs/reference/configuration/>) and, against the existing
values, surface — **as suggestions, in addition to the two required edits**:

- **Deprecated / non-standard constructs** to modernize (e.g. `[experimental]
  cmd` → `[processes]`; the verbose `[[services]]` + `[[services.ports]]` +
  `[[services.http_checks]]` → the simpler `[http_service]` +
  `[[http_service.checks]]` for an HTTP-only app).
- **Newer options worth adopting** given how this app runs (e.g. explicit
  `auto_stop_machines` / `auto_start_machines` / `min_machines_running` to
  document always-on vs scale-to-zero; `[[vm]]` `cpus`/`memory`/`cpu_kind`
  instead of just `size`; duration strings like `kill_timeout = "30s"`).

**Sanity-check the inherited *values*, not just the structure.** The limits and
sizes were copied from the previous instance — confirm they still fit how the
app actually runs:

- Cross-check `internal_port` against the app's configured HTTP port
  (`config/prod.exs` → `http: [port: ...]`).
- Justify the concurrency `type`/limits from the connection profile: grep for
  LiveView / Phoenix sockets / channels (`lib/**/endpoint.ex`, `socket "..."`).
  Long-lived websockets (LiveView) justify `type = "connections"` and generous
  limits — lowering them would shed live viewers during exactly the
  high-traffic live events you want to serve. Pure request/response would point
  to `type = "requests"` instead.
- Treat inherited values as proven-in-prod: validate against real peaks on
  [fly-metrics.net](https://fly-metrics.net) rather than changing them blind. A
  connection limit does **not** bound CPU — for LiveView-heavy load the
  saturation risk is CPU / VM size, so watch metrics and scale `[[vm]]` / region
  count rather than touching the limit.

Present each with a recommendation and let the operator choose — don't apply
unilaterally. The experimental instance is the safe place to trial any of these
before they reach production (Part D).

**Verify the edits yourself — don't ask the operator to paste a diff.** Run
`diff fly.io/${OLD}/fly.toml fly.io/${NEW}/fly.toml` and confirm it shows **only**
the agreed changes. *In a sandbox*, first reproduce the operator's edits locally
so both copies match.

**Validate the schema, not just TOML syntax.** A TOML parser (`tomllib`) only
checks that the file *parses* — it won't catch Fly schema mistakes like
`auto_start_machines = "off"` (it's a **bool**, not the string enum that
`auto_stop_machines` takes), or fields whose types changed across flyctl
versions. Run `flyctl config validate -c fly.io/${NEW}/fly.toml`. It needs Fly
auth, so in a sandbox have the operator run it on the host **before** deploying —
otherwise the first `flyctl secrets set` / `deploy` is where the error surfaces
(as it did once here).

### B4. Stage the one bootstrap secret

```bash
flyctl secrets set --stage \
    OP_SERVICE_ACCOUNT_TOKEN="$(op read op://changelog/op/credential --account changelog.1password.com --cache)"
```

`OP_SERVICE_ACCOUNT_TOKEN` is the single secret set directly on Fly; everything
else resolves at boot via `fnox exec --profile production`, which reads 1Password
using this token. `--stage` records it without deploying (no machines yet); it
applies on the first deploy. Healthy result:
`Secrets are staged for the first deployment`. Requires `op whoami` to be signed
in; if not, `eval $(op signin)` first.

> **Optional first-boot smoke test (no prod writes).** Before wiring CI you can
> seed the app with a known-good image while skipping the release command:
> `flyctl deploy --ha=false --no-release-command --image=ghcr.io/thechangelog/changelog-prod:<LATEST_SHA>`
> (latest tag at
> <https://github.com/thechangelog/changelog.com/pkgs/container/changelog-prod>).
> `--no-release-command` skips `mix ecto.migrate` + `mix changelog.static.upload`
> so it touches no prod data. Otherwise, let Part C drive the deploy.

**Part B done.** The app exists and has its bootstrap secret staged.

---

## Part C — Trigger the pipeline & verify

This is where the workflow is exercised for real — **not** the first step, the
last one, once A and B are in place.

### C1. Push to the fork's `master` branch ⭐

Git runs on the **host** (`vm:keep` excludes `.git/`, so a sandbox's git is
irrelevant). A host clone usually has only `origin` → **upstream**, so add a
fork remote first if it's missing (`git remote -v` to check):

```bash
git remote add fork https://github.com/<owner>/changelog.com.git   # if absent
git add -A && git commit            # or amend, operator's choice
git push fork <your-branch>:master
```

**Before pushing, validate any changed workflow YAML.** GitHub rejects the whole
file on a syntax error. Watch two traps in `run:`/`if:` values: mise's parallel
separator `:::` (e.g. `mise run a ::: b`) and any expression containing quotes or
`{…}` (e.g. a `format(...)` `if:`) — the embedded **colon-space** or braces break
an unquoted YAML scalar, so wrap the whole value in **double quotes**
(`run: "… ::: …"`, `if: "${{ … }}"`). And a YAML parser only catches *syntax* —
it won't catch invalid GitHub **expressions**: the expression language has a
limited function set (`contains`, `startsWith`, `endsWith`, `format`, `join`,
`toJSON`, `fromJSON`, `hashFiles`) — notably **no `replace`**. Validate both with
`actionlint`:
`mise x aqua:rhysd/actionlint@latest -- actionlint -ignore 'label "namespace-profile-changelog" is unknown' .github/workflows/*.yml`
(the ignore drops a false positive for the Namespace self-hosted runner).

**`ship_it.yml` triggers on push to `master`, and the publish/deploy gate
requires `github.ref_name == 'master'`.** Pushing to any other branch runs build
& test only — it will *not* publish an image or deploy. So to validate the full
pipeline you must land the change on the fork's **`master`**. Remind the operator
of this explicitly; it's the single most-forgotten step.

(With `DEPLOY_FROM_REPO` set to this fork in A2, the master push is also what
makes publish + deploy fire here.)

### C2. Watch the "Ship It!" run

In the fork's Actions tab, confirm:

- **Build & test** pass on `ubuntu-latest`.
- **Publish** pushes images to `ghcr.io/${IMAGE_OWNER}/changelog-{runtime,prod}`.
- **Deploy** runs `flyctl deploy` against `${NEW}`.

> ⚠️ **A new GHCR package is private → Fly can't pull it.** The first time images
> land in a new namespace, `ghcr.io/${IMAGE_OWNER}/changelog-{runtime,prod}` are
> **private**, so `flyctl deploy` fails with `Authentication required to access
> image "ghcr.io/.../changelog-prod:…"`. **Make the package public before the
> deploy** — GitHub → your profile/org → Packages → the package → Package
> settings → Change visibility → Public. At minimum `changelog-prod` (the image
> Fly pulls; the prod image is self-contained, so the runtime package can stay
> private). One-time per new namespace (a fork, or a new org). Alternatively give
> Fly registry credentials, but public is simplest for a test fork.

> ⚠️ **Deploy touches production data.** `fly.toml`'s `release_command` runs
> `on.deploy` in the new container before cutover:
> `fnox exec --profile production -- mix ecto.migrate` **and**
> `mix changelog.static.upload`. With profile `production` these hit the **prod
> Neon DB** and **prod R2 assets bucket** even on an `experimental` app.
> `ecto.migrate` is a no-op when prod is already migrated; `static.upload`
> re-pushes assets. Watch the release-command logs for
> `fnox: command not found` (fnox must be installed in `Dockerfile.runtime`).

### C3. Verify the deployed app

```bash
flyctl status --app ${NEW}
flyctl logs --app ${NEW}
curl -fsS https://${NEW}.fly.dev/health
```

Confirm the machine is `started`/healthy, logs are clean, `/health` returns OK.
`team:cd` deploys with `--ha=false`, so a fresh instance comes up as a **single
machine in the primary region** (`iad`). The instance now runs but is **not** in
the request path and **not** processing jobs (APP_INSTANCE=experimental) — exactly
what we want until promotion.

> **Deploys are blue-green — they never replace a running app in place.**
> `fly.toml` sets `[deploy] strategy = "bluegreen"` and `team:cd` doesn't
> override it (`--ha=false` is orthogonal — it only sets the machine *count*, not
> the strategy). On a **redeploy**, new (green) machines boot *alongside* the
> running (blue) ones, one per region, and traffic shifts only once green pass
> health checks; if they fail, blue keeps serving and the deploy fails safely.
> (The very first deploy of a fresh app has no blue to protect, so blue-green
> only kicks in from the second deploy on — e.g. C5's GitHub redeploy, and every
> prod deploy.) Verify mid-deploy with `flyctl machines list --app ${NEW}`: you'll
> see green machines in `created`/`0/2` next to `started`/`1/1` blue, one green
> per region. After cutover, confirm with
> `flyctl config show --app ${NEW} | grep -A2 '"deploy"'` → `"strategy": "bluegreen"`.

### C4. Run across two regions — required

Two regions is **essential, not optional**: a single-region failure must not take
the site down (status.changelog.com/incident/513790). Validate it on the
experimental instance too. It isn't promoted yet, so `APP_PROD_INSTANCE` still
points at the old prod — **override it inline** (the `mise.toml` `[env]` template
coalesces the OS env var over its default):

```bash
APP_PROD_INSTANCE=${NEW} mise team:prod:multi-region
flyctl status --app ${NEW}
```

`team:prod:multi-region` runs `flyctl scale count 2 --max-per-region 1 --region
iad,ewr`, so you end with **1 healthy machine in `iad` and 1 in `ewr`** —
`--max-per-region 1` rebalances if the deploy happened to bring up two in the
primary. Confirm `flyctl status` lists both regions, each `started` with passing
checks.

Then confirm the app actually **serves 200 from each region** — `started` ≠
serving traffic. Force each region and read the serving region (`sr`) out of
Fly's debug header:

```bash
for r in iad ewr; do
  echo "== forcing ${r} =="
  curl -sS -D - -o /dev/null \
    -H "Fly-Force-Region: ${r}" -H "Flyio-Debug: doit" \
    https://${NEW}.fly.dev/health | grep -iE '^(HTTP/|flyio-debug:)'
done
```

Each must show **`200`** and a `flyio-debug` JSON whose `"sr"` (serving region)
matches the region you forced — that proves that region's machine handled it
(`sr` = serving region, `sid` = serving machine; `nr` is only the edge you hit).
Use `Fly-Force-Instance-Id: <machine-id>` to pin a specific machine. (Technique
borrowed from pipely's `test/acceptance/periodic/region.hurl`.)

Promotion (Part D) makes this the permanent default.

### C5. Confirm the GitHub-hosted path too

The first run proved the **Namespace** path (the fork's default,
`RUNS_ON=namespace`). `ship_it.yml` runs exactly one runner, so the
GitHub-hosted path hasn't executed yet — prove it too, since forks **without**
Namespace access rely on it. Flip the runner and trigger again:

- Set the `RUNS_ON` repo variable to `github` (any value **not** containing
  `namespace` works — including unsetting it; the `github` job runs whenever
  `RUNS_ON` lacks `namespace`).
- Trigger a fresh "Ship It!" run on `master` — amend + force-push, or any new
  commit (a `workflow_dispatch` from the Actions tab also works).
- Confirm the **`github`** job runs (on `ubuntu-latest`, not the Namespace
  runner) and that build & test → publish → deploy all pass, deploying the same
  `${NEW}`. This exercises a genuinely different code path: with no remote
  builder, `docker:build-runtime` `--load`s the runtime into the **local Docker
  daemon** and `docker:test` / `docker:build-prod` `FROM` it (Namespace instead
  pushes the runtime to `nscr.io`) — so it's worth confirming independently.
- Afterwards set `RUNS_ON` back to `namespace` to restore the preferred default
  (persistent Namespace caching).

**Part C done.** The pipeline is proven end-to-end in your account on **both**
runners — Namespace and GitHub-hosted — deploying to `${NEW}` and running
healthy across two regions.

---

# After the PR merges — promote to production

Part D runs once the merged instance config is on `master` and the experimental
instance has soaked.

## Part D — Promote an instance to production

Only when `${NEW}` has proven itself. Deliberate, ordered cutover — do not batch.
Region resilience is already in place: C4 scaled `${NEW}` to two regions
(`iad,ewr`, one machine each) and that count persists across deploys, so there's
no separate scale step here — just confirm `flyctl status` still shows both.

### D1. Make `${NEW}` the default for team tasks

`APP_PROD_INSTANCE` is defined once, in `mise.toml` `[env]`, as a template whose
literal fallback is the current prod app. Edit that fallback to `${NEW}`, then:

```bash
mise trust
mise env | rg APP_PROD_INSTANCE   # should show ${NEW}
```

This is what `team:cd`, `team:prod:multi-region`, etc. target locally.

### D2. Flip the instance to production mode

Edit `fly.io/${NEW}/fly.toml`: set `[env] APP_INSTANCE = "production"` so the
Oban queues start (inverse of B3). Remove any env vars that shouldn't be on the
canonical prod instance (e.g. stray `URL_HOST`, `STATIC_URL_HOST`). Redeploy so
the change and the queues take effect.

> ⚠️ From here `${NEW}` is a full production worker.

### D3. Cut the CDN origin over

Update the origin in [pipely](https://github.com/thechangelog/pipely) to
`https://${NEW}.fly.dev`, then release a new Pipely version. **This is the
public traffic cutover** — changelog.com now serves from `${NEW}`. Watch
Honeycomb / BetterStack as it rolls.

### D4. Update the upstream GitHub Actions variable

Set the `APP_PROD_INSTANCE` repo variable on `thechangelog/changelog.com` to
`${NEW}`:
<https://github.com/thechangelog/changelog.com/settings/variables/actions/APP_PROD_INSTANCE>
so upstream CI deploys target the new instance.

### D5. Sweep remaining references

```bash
rg ${OLD}
```

Update every lingering reference — the INFRASTRUCTURE.md architecture diagram,
`fly.toml` `PIPEDREAM_HOST`, docs — to `${NEW}`.

### D6. Retire the old instance

Once `${NEW}` is confirmed healthy in production and serving all traffic, scale
`${OLD}` down (eventually `flyctl apps destroy ${OLD}`) so you're not paying for
two prod instances. Only after a soak period.

**Part D done.** `${NEW}` is production; `${OLD}` is retired.

---

## Related

- Branch the prod DB for local work: `mise team:neon:branch-create`, then
  `mise team:db:neon-use-remote-branch` (or `mise team:db:neon-import-main-locally`).
- Secrets model: `fnox.toml` holds 1Password references only;
  `OP_SERVICE_ACCOUNT_TOKEN` is the one manually-set secret (on Fly and in
  GitHub Actions).
