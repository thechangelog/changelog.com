[![shields.io](https://img.shields.io/badge/Last%20updated%20on-Jan.%2012%2C%202024-success?style=for-the-badge)](https://shipit.show/80)

This diagram shows the current changelog.com setup:

```mermaid
%% https://fontawesome.com/search
graph TD
    classDef link stroke:#59b287,stroke-width:3px;
    
    %% Code & assets
    subgraph GitHub
        repo{{ fab:fa-github thechangelog/changelog.com }}:::link
        click repo "https://github.com/thechangelog/changelog.com"

        cicd[/ fa:fa-circle-check GitHub Action - Ship It \]:::link
        click cicd "https://github.com/thechangelog/changelog.com/actions/workflows/ship_it.yml"
        
        automation[\ fab:fa-golang Dagger Go SDK /]:::link
        click automation "https://github.com/thechangelog/changelog.com/blob/master/magefiles/magefiles.go"

        registry(( fab:fa-github ghcr.io )):::link
        click registry "https://github.com/orgs/thechangelog/packages"

        chat(( fab:fa-slack Slack )):::link
        click chat "https://changelog.slack.com/archives/C03SA8VE2"

        repo -.-> |.github/workflows/ship_it.yml| cicd
        cicd --> |magefiles/magefiles.go| automation
        
        cicd --> |success #dev| chat
    end
    
    repo -.- |fly.io/changelog-2024-01-12| app
    
    registry --> |ghcr.io/changelog/changelog-prod| app
    container --> |flyctl deploy| app
        
    repo -.- |fly.io/dagger-engine-2023-05-20| container

    %% PaaS - https://fly.io/dashboard/changelog
    subgraph Fly.io
        proxy{fa:fa-globe Proxy}
        proxy ==> |https| app

        container([ fa:fa-project-diagram Dagger Engine 2023-05-20 ]):::link
        click container "https://fly.io/apps/dagger-engine-2023-05-20"
            
        app(( fab:fa-phoenix-framework App changelog-2024-01-12.fly.dev )):::link
        style app fill:#488969;
        click app "https://fly.io/apps/changelog-2024-01-12"

        automation --> |wireguard| container
        container --> |ghcr.io/changelog/changelog-runtime| registry
        container --> |ghcr.io/changelog/changelog-prod| registry

        metricsdb([ fa:fa-chart-line Prometheus ])
        metrics[ fa:fa-columns Grafana fly-metrics.net ]:::link
        click metrics "https://fly-metrics.net"
        metrics --- |promql| metricsdb
        metricsdb -.- |metrics| app
        metricsdb -.- |metrics| container
    end

    app <==> |Postgres| dbrw

    subgraph Neon.tech
        dbrw([ fa:fa-database main branch primary ]):::link
        click dbrw "https://console.neon.tech/app/projects/orange-sound-86604986/branches/br-wandering-smoke-78468159"

        dbro1([ fa:fa-database main branch replica ])
        dbrw -.-> |replicate| dbro1
    end

    %% Secrets
    secrets(( fa:fa-key 1Password )):::link
    click secrets "https://changelog.1password.com/"
    secrets -.-> |secrets| app
    secrets -.-> |secrets| repo

    %% Search
    search(( fa:fa-magnifying-glass Typesense ))
    app -...-> |search| search

    %% Exceptions
    exceptions(( fa:fa-car-crash Sentry )):::link
    click exceptions "https://sentry.io/organizations/changelog-media/issues/?project=5668962"
    app -...-> |exceptions| exceptions

    %% CDN - https://manage.fastly.com/configure/services/7gKbcKSKGDyqU7IuDr43eG
    subgraph Fastly
        apex[ changelog.com ]:::link
        click apex "https://changelog.com"
        
        subgraph Ashburn
            cdn[ cdn.changelog.com ]
        end
    end

    subgraph AWS.S3
        logs[ fab:fa-aws changelog-logs ]
    end
    apex & cdn-.-> |logs| logs

    %% Observability
    observability(( fa:fa-bug Honeycomb )):::link
    click observability "https://ui.honeycomb.io/changelog/datasets/changelog_opentelemetry/home"
    app -....-> |traces| observability
    logs -.-> |logs| observability
    
    %% Object storage
    apex ==> |https| proxy
    subgraph Cloudflare.R2
        assets[ fab:fa-cloudflare changelog-assets changelog.place ]
    end
    cdn ==> |https| assets

    %% Monitoring
    subgraph BetterStack
        status[ fa:fa-layer-group status.changelog.com ]:::link
        click status "https://status.changelog.com"

        monitoring(( fa:fa-table-tennis Uptime )):::link
        click monitoring "https://uptime.betterstack.com/team/133302/monitors"
        monitoring -....-> |monitors| apex
        monitoring -.-> |monitors| cdn
        monitoring -.-> |monitors| proxy
        monitoring -.-> |monitors| status
    end
```

> **Note**
> [Continue live editing this Mermaid diagram](https://mermaid.live/edit#pako:eNqdWHlv2zYU_yqEihYNEEk-4rPrhizu0iJoF8ztBiwuBkqiZS4SqZJUHTfOd98jdVGO3GP-w9bx7vd7B33vhDwiztx5-hRtlMrk3PfXnCm8JZKnxAt56kuCRbhZsVjgbIPeL1YMwSdMsJQLskYJZbdIKsFvyfzJaBYMppPT4tbd0kht5sPs7kXBU3yDqgtQip4hkECULJ7KPCgUXFL1Og-Kh_ojSMbv79EaB_M1dmOqNnmA1IaEG8xikvDYr6-0uejhYT6fa6MaEWFCw1sjCK2cys1CkvHwuLSVs2KWHBpGNz6Yoi0JqQgT4obAe1sajc5DRTlDLlpuaIbeKLRafTxijZb1o9b42MiX_paL23XCt9KXoOgfqrxdmmhbKx3NFc4VT7Fmu1mt6ijyBMSiBY5jItAlR8vFFfKPmdqI-GGDg4QHfoqlIgJ-YrKmCZHNlRfzdoQFiSmAZ_f8-UHC400oPMrRycnR7Bac3SZyEcu2nRkOb8EMeZDhDVaNbpkAEVqa76OKNYultPHfcBdpg_qhn8Hxi95weT7989Xg0GtApuu5P6O9VxjdneG9QU0bj8jVbN2x3Vup68JGwy_zMCRSoicR-bw3LhVUhEV26VaGov062UE6Gm_dQW8wdPsDtz8BrVnW5ipTY1SVmfQ7IONmgkcWe6g7EWUAUcMJOkOVoIhkCd9ZZF-xLzIIdwmLQUxhY28Ev_tGdpUIaEvXGC-heOtGWMmQm4BjETWGHrSs3wxhYwy4cbe7L9pEDBVA0LV-8nBAgV6-BK-MttIbKzWVec9vyn4DLP-SULkRxaA1rYr3lXENNa6hj0eRWoezgWvpI2iXR4NlN5aD5pJlTbVkG04YvXPXYB3R-EXnWYa6EOJprYC0rqKSapcQLRgBipP5k7PpdDaevXjUk4Cg24suhe1ys_qZwdWWAkJzSHALFY8y8W34ipwpmpJ9jfj_JaUogkZEIyQlStBQRkENCuASyk00AgBi8H5DcgkIeMRTM_AkT5lElwKvMcMIIueWJB4jCh2bASVNO-Y2pw2Sith1oRLBnfQTtK7a-A5_ipotbw8q-xjRQapMpyouNTZ-MrV1zaWKBQHqKBDb6n1dt-8IZ54iermptGm6OroRVjjAkqAUFKFAYBZuoHRpiqGZHS0zLcIeCDCweUIgRqUyDVO_rGYJk0nn3ZU8Z5E7HY97Z7Pp2C90QTsPhLvFLCKCstiVqd6qJtOz8bQ_mrVBDVp5_-uWQ3cEA3ELHsbYYvSUrxXZF8IexRU65JKEolnZihvTAbTSW7JD_WtY6qD4o8PaLmJTsnTOy35WspqZWeGp4ihsLO8siBx5rydBy-5ihy049HVtNQxMRtc7Hd9Y77To_S4jkjAI3slJAyjX80oNmnuPqq24VvHqLiSZWc_KwNX3taoQCzcUME7AHqYHYmeMGkYrTNIw6JYBqwxm9AsuNsGmbaQEJoNPpcwBNr-U-Ho5Go-hfw6qaNqeNHr2lk7Lo4vFO2saptAuYuKtYZmDbqtTBMhe0zgXBKwTnyksEP4kvgrCq-XV5WL36cPkTb4QZ0NyeTgujQh7ipC7G9Te4o_uokDbiZ5yWX88o2q15zDGc8HasyyM2I3-8g7UN1T1CmRVQiPzr6W3HDbEwG9arRmIeCut8adfVXJrmcadZ9qAAr-aaG-kWHn4PdDxxQFNqCrDxu1HNb6CPEavOSM7cCHoBleL0QpkTr1NxdkeTLqV6GNa8-gfngEaSUJ0L975G5g7h_gyziiBQ917-WP7TTBslztoLP81lGEzgF4ZEytw9v5kNqqD7FwkPI_WCRbE-2Ng4c0cO-s0hTWVla2CxgJlBts8eZQ_SFx7iytPtLXtbzmjYDd0lwPbfiUKDkVLBWcEe_nBKq9ndYJ3sI7FgudZ-cb7viIpiO3u0cHdHh9pbWeNJpggcL5VhDEq0YdMbzbHT0ENvw0qw-QFxlWpquOQIjj1-8PhsDfwSz7ZWh8aWTWWKrq9yfwR2jYh5Oa76CzkfIOyCKMFAefUSYmAGRs5c-dev1g5sILpepjDZYTFrXbsAej00rncsdCZK5GTUyfPoLDIoljmHYh3IuFphtnfnLfunfm9c-fM3clw7I0nvd5sejYYTUb96amzc-azvtc_G02Gg0kPHo-Go4dT54uR0Pcmw9Fwdtbr9Xu9SQ_IYUCAH2-LP3zM_z4P_wG9QNng)

Let's dig into how all the above pieces fit together.


## A three-tier monolith

TL;DR:
- **Front-end**
  - Fastly
  - Fly.io Proxy
  - Cloudflare R2
- **Application**
  - Elixir / Phoenix
  - Typesense search
- **Database**
  - PostgreSQL (Neon.tech)

[changelog.com](https://changelog.com) is a monolithic
[Elixir](http://elixir-lang.org) application built with the
[Phoenix](http://www.phoenixframework.org) web framework. It uses
[PostgreSQL](https://www.postgresql.org) for persistence &
[Node.js](https://nodejs.org) to digest & compile static assets (CSS & JS).

Static assets, including all our mp3 episodes, are stored on Cloudflare R2.
They are served via Fastly, specifically https://cdn.changelog.com.

```
Fastly (cdn.changelog.com)
↓
Cloudflare R2 (changelog.place)
````

The production instance of our application is running on Fly.io. All
https://changelog.com requests are served via Fastly. Each Fastly request gets
proxied to our application instance via the Fly.io Proxy.

```
Fastly (changelog.com)
↓
Fly.io Proxy
↓
Application (changelog-2022-03-13.fly.dev)
```

The production database - PostgreSQL - is running on Neon.tech. It is a
replicated setup, with one leader (RW) & one replica (RO). We are currently not
using the replica, and since Neon.tech scales down to 0, this isn't costing
anything.

```
Application (changelog-2022-03-13.fly.dev)
↓
PostgreSQL Leader (RW)
↓
PostgreSQL Replica (RO)
```


## Production deploys

Each commit made against our primary branch gets deployed straight into
production. The ["Ship It!" GitHub Actions
workflow](.github/workflows/ship_it.yml) is responsible for this. From the
workflow jobs perspective, it is fairly standard:

- **1/2. CI/CD**
  - Uses Dagger Go SDK so that it works exactly the same locally as it does in
    GitHub Actions
  - [Spins up a Dagger Engine as a Fly.io machine on-demand, then connects to
    it](https://github.com/thechangelog/changelog.com/pull/471) so that caching
    is reliable & persistent between workflow runs
  - A successful run publishes a container image to
    https://ghcr.io/thechangelog/changelog-runtime &
    https://ghcr.io/thechangelog/changelog-prod
  - Deploys to Fly.io
- **2/2. Notify**
  - Notifies `#dev` channel in changelog.slack.com if **CI/CD** succeeds


## Secrets

All our secrets are stored in [1Password](https://changelog.1password.com/), in
the **changelog** vault. We are declaring a single secret in Fly.io,
`OP_SERVICE_ACCOUNT_TOKEN`, and then loading all other secrets into memory part
of app boot via `op` & `env.op`.

In [GitHub Actions
secrets](https://github.com/thechangelog/changelog.com/settings/secrets/actions),
we are still pasting them manually. That is something that should use `op` too.


## Metrics & observability

Since our application & database are running on Fly.io, we benefit from free
infrastructure metrics: https://fly-metrics.net

All logs from Fastly are streamed into Honeycomb.io. This allows us to ask
unknown questions about how various HTTP clients interact with our content. It
also helps us explore how Fastly interacts with Fly.io.

We also send app traces via OpenTelemetry to Honeycomb.io.

App errors - e.g. `Plug.Conn.InvalidQueryError` - show up in Sentry.io.

BetterStack.com monitors our public HTTPS endpoints & alerts us when they become unhealthy.


## Search

We use Typesense for search. It's near-instant & it just works.


## What is missing?

The above is what we have so far. While we like to keep things simple, our
setup is a constant work in progress. We keep making small improvements all the
time, and we talk about them every few months in the context of our [Ship It!
Kaizen episodes](https://changelog.com/topic/kaizen). For example, this diagram
and document were created in the context of [🎧 Kaizen 8: 24 improvements & a
lot more](https://shipit.show/80). If you would prefer to stay in reading mode,
check out [GitHub discussion
#433](https://github.com/thechangelog/changelog.com/discussions/433).

If anything on this page is missing, or could be clearer, please [open an
issue](https://github.com/thechangelog/changelog.com/issues/new/choose). Thank
you very much!

---

## How to create a new app instance?

1. Start by creating a new app, e.g. `flyctl apps create changelog-2024-01-12 --org changelog`
2. Copy the existing app instance config, e.g. `cp -r fly.io/changelog-{2023-12-17,2024-01-12}`
3. Run all following commands in the app directory, e.g. `cd fly.io/changelog-2024-01-12`
4. Update the app name in e.g. `fly.toml` to match the newly created app
5. From within the app directory, set a few secrets required by the app to work correctly while testing

        flyctl secrets set --stage \
            OP_SERVICE_ACCOUNT_TOKEN="$(op read op://changelog/op/credential --account changelog.1password.com --cache)" \
            R2_FEEDS_BUCKET=changelog-feeds-dev \
            URL_HOST=changelog-2024-01-12.fly.dev

6. Deploy the latest app image from <https://github.com/thechangelog/changelog.com/pkgs/container/changelog-prod>

        flyctl deploy --vm-size performance-4x --image <LATEST_IMAGE_SHA>

## How to load data into a Neon.tech from a Fly.io Postgres instance?

The assumption is that a Neon.tech instance has already been provisioned.

### Pre-requisites

- Credentials for the Fly.io Postgres:
```console
op read op://changelog/changelog-postgres-2023-07-31/url --account changelog.1password.com --cache
```
- Credentials for the Neon.tech Postgres:
```console
op read op://changelog/neon/url --account changelog.1password.com --cache
```
- ensure there are no app instances connected to the db being restored
- ensure the db is clean before restore

### Step-by-step guide

1. Connect to the **replica** instance:
```console
flyctl ssh console --select --app changelog-postgres-2023-07-31
```

2. Backup db to local file, then restore to remote host:
```console
time pg_dump --dbname="<FLY_POSTGRES_URL>" --format=c --verbose > /data/changelog.sql
# Expected to take ~40s

time pg_restore --dbname="<NEON_POSTGRES_URL>" --format=c --exit-on-error --no-owner --no-privileges < /data/changelog.sql
# Expected to take ~1m
```

3. [Warm-up the query planner](https://www.postgresql.org/docs/current/sql-analyze.html):
```console
time psql "<NEON_POSTGRES_URL>" --command "ANALYZE VERBOSE;"
# Expected to take ~3s
```
