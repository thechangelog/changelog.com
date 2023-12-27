[![shields.io](https://img.shields.io/badge/Last%20updated%20on-Aug.%202%2C%202023-success?style=for-the-badge)](https://shipit.show/80)

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
    
    repo -.- |2022.fly| app
    
    registry --> |ghcr.io/changelog/changelog-prod| app
    container --> |flyctl deploy| app
        
    repo -.- |fly.io/dagger-engine-2023-05-20| container

    %% PaaS - https://fly.io/dashboard/changelog
    subgraph Fly.io
    
        proxy{fa:fa-globe Proxy}
        proxy ==> |https| app


        container([ fa:fa-project-diagram Dagger Engine 2023-05-20 ]):::link
        click container "https://fly.io/apps/dagger-engine-2023-05-20"
            
        app(( fab:fa-phoenix-framework App changelog-2022-03-13.fly.dev )):::link
        style app fill:#488969;
        click app "https://fly.io/apps/changelog-2022-03-13"
            
        dbw([ fa:fa-database PostgreSQL Leader 2023-07-31 ]):::link
        click dbw "https://fly.io/apps/changelog-postgres-2023-07-31"
            
        dbr1([ fa:fa-database PostgreSQL Replica 2023-07-31 ])

        app <==> |pgsql| dbw
        dbw -.-> |replication| dbr1

        automation --> |wireguard| container
        container --> |ghcr.io/changelog/changelog-runtime| registry
        container --> |ghcr.io/changelog/changelog-prod| registry

        metricsdb([ fa:fa-chart-line Prometheus ])
        metrics[ fa:fa-columns Grafana fly-metrics.net ]:::link
        click metrics "https://fly-metrics.net"
        metrics --- |promql| metricsdb
        metricsdb -.- |metrics| app
        metricsdb -.- |metrics| dbw
        metricsdb -.- |metrics| container
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
> [Continue live editing this Mermaid diagram](https://mermaid.live/edit#pako:eNqdWHlv2zYU_yqEihYtEEm2FceJum7I4i4t0m5d3W7A4qKgJFrmLIkqSdVx43z3PVIX5Ug95j9sHe9-v3fQt1bIImL51sOHaC1lLnzXXbFM4i0RLCVOyFJXEMzD9TKLOc7X6N18mSH4hAkWYk5WKKHZBgnJ2Yb4D6ZnweR0dlTe2lsaybXv5TdPS57yG1RdgFL0CIEEIkX5VBRBqeCSyhdFUD5UH05ydnuLVjjwV9iOqVwXAZJrEq5xFpOExW5zpcxFd3e-7yujWhFhQsONFoSWVu1mKUl7OCxtaS0zQw4No2sXTFGWhJSHCbFD4N1URqPzUFKWIRst1jRHLyVaLj8MWKNk_ag1LtbyhbtlfLNK2Fa4AhR9pNLZpYmytdbRXuFCshQrtuvlsokiS0AsmuM4JhxdMrSYXyF3yNRWxA8bHCQscFMsJOHwE5MVTYhor5yYdSPMSUwBPLvHjw8SHq9D7lCGnjwZzG7J2W8i47Ho2pnjcANmiIMMr7FsdYsEiNBCfw8qViyG0tZ_zV2mDeqHfgbHL0be4vz0r-eTQ68BmbZj_4z2Tml0f4b3GjVdPCJbsfXHdm-krg8bLb8owpAIgR5E5PNeu1RSkSwyS7c2FO0no8nEWSU7UJHnXZIqD1pulTa3Bx92zllksIeq7dAM8Kg5QXYoExSRPGGmlj5jgFYpiTScbZLFIMYGCz17NIXffSu7jjr0oDcYL6BSm65XyxDrgGEetYYe9KffNKHpsvqAMze727IzxAB6gt6oJ3cHFOjZM_BN66x86qCvNvPxddVkgOlfEko7ohi0p3XFPtcuotZF9GEQnk1YW4xWvoJ-MRg0s5scdJQ8b0skXzOS0Rt7BdYRBVp0nueoTbLCiT3y7LGn0OIAvPoqSchdQpRgBNBN_AfHp6dnJ2dP7zUiIOj3ok_hsAdRsG0iHGGJAywgX0zImJPFn6_QK4IjCFgZjJntjYfDC6K-aVJeShZ2K_BrtvHxV417CxVBQ9y1zkSRitJPGmd5LD5B0wAbO75XrYaXglRz2Gu1HSFtz9fluKVQ2AXURaeY7gH321XPi0zSlOybRvG_pJS9oxXRCkmJ5DQUUdAEEbi4tBNVMFCT8H5NCqFjdsDTMLCkSDOBLjle4QwjyKpdkTgZkWhoTlY0XTyYnGbWa2LbhgYG7qQqU43xPf6Ura66PWiIQ0SdzA8RHeRTt_ymSy5IyNsdrbzR1a8CtSE7NH4DWxwUfnRY12VMKpbeATnOK1Y9JOvg1BwlSKs7w9-B92oadOwul9aSQ103VsOEzOhqR7MYOjVYgN7tciJIBmX2pAKFKiHbcSoNinuP6jW4UfH8JiS53seqwDX3jaoQczvkMFLAnkwNxd4YtYxGmIRmUPiH3QVn9AsuV7-2BlICU8GlQhQw9n-pJsWz6ckJ9M5JHU3Tk1bP3tBpeHQx_92YiClgPybOCrY3aGsqRYCUFY0LTsA6_pnCxuDO4qsgvFpcXc53n97PXhZzfuyRy8ORqUWYHYrcXKPu2j64fAJtL3qq7fx-B23UnsMoL3jW7bRhlF2rL-dAfUvV7DxGJbQy_144C68lBn7dN_QwxFthjD71qpbbyNTuPFIGlPhVRHstxcjDH4GKLw5oQmUVNmY-avAVFDF6wTKyAxeCfnB1GI1AFtRZ15zdLquGjjqXtY8-shzQSBKiesbOXUMTPcSXdkZyDJjYd3WWdDoYpss9NIb_CsqwFTAOCDQCZ25Pep86yM5FwopolWBOnLcTA2_6nNmkKWyojGyVNAYoc1jfyb38QeK6O1x1hG1sf80yCnZDdzmw7Vci4RS0kHAoMBcfLItm8CR4B6tYzFmRV2-c7yuSktjsHj3c3TNH2tjZoAl2DTjQSpJlVKD3uRrTw8eelt8ElWZyAu2qkPX5RxKcumPP80YTt-ITnVnYymqwVNPtdeYHaLuEkJvvojOQ8w3KMowGBKwjKyU8xTSyfOtWvVhasE-oevDhMsJ8oxy7Azq1QS12WWj5khfkyCpyKCwyLxd5C-KdCHia4-wfxjr3ln9r3Vi-PfNOnJPZaHR2ejyZzqbj0yNrZ_lnY2d8PJ15k9kIHk-96d2R9UVLGDszb-qdHY9G49FoNgJyGBDgx-vyHx79R8_df1dCyJo)

Let's dig into how all the above pieces fit together.


## A three-tier monolith

TL;DR:
- **Front-end**
  - Fastly
  - Fly.io Proxy
  - Cloudflare R2
- **Application**
  - Elixir / Phoenix
- **Database**
  - PostgreSQL

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

The production database - PostgreSQL - is running on Fly.io too. It is a
replicated setup, with one leader & one replica.

```
Application (changelog-2022-03-13.fly.dev)
↓
PostgreSQL Leader
↓
PostgreSQL Replica
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
the **Shared** Vault. Currently, they are manually declared in Fly.io via
`flyctl`. They are pasted manually in [GitHub Actions
secrets](https://github.com/thechangelog/changelog.com/settings/secrets/actions).


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
time, and we talk about them every 10 weeks in the context of our [Ship It!
Kaizen episodes](https://changelog.com/topic/kaizen). For example, this diagram
and document were created in the context of [🎧 Kaizen 8: 24 improvements & a
lot more](https://shipit.show/80). If you would prefer to stay in reading mode,
check out [GitHub discussion
#433](https://github.com/thechangelog/changelog.com/discussions/433).

If anything on this page is missing, or could be clearer, please [open an
issue](https://github.com/thechangelog/changelog.com/issues/new/choose). Thank
you very much!

---

## How to upgrade our PostgreSQL instance running on Fly.io?

1. Provision a new PostgreSQL instance
```console
flyctl postgres create \
    --org changelog --region iad \
    --name changelog-postgres-2023-07-31 \
    --initial-cluster-size 2 \
    --vm-size performance-2x \
    --volume-size 10
```

2. Connect to newly created instance (we want to use the new `pd_dump`, with the latest improvements)
```console
flyctl ssh console --app changelog-postgres-2023-07-31
```

3. Create new db
```console
createdb changelog --host localhost --username postgres
```

4. Dump database to local file
```console
pg_dump --host postgres-2022-03-12.internal --username postgres changelog > changelog.sql
```

5. Restore database from local file
```console
psql --host localhost --username postgres --single-transaction changelog < changelog.sql
psql --host localhost --command 'ANALYZE VERBOSE;' changelog postgres 
```

> **Note**
> If a previous restore failed, run `dropdb --force --host localhost --username postgres changelog`, then `createdb ...` again.

6. Configure app to use new PostgreSQL instance
```console
flyctl secrets set DB_HOST=changelog-postgres-2023-07-31.flycast DB_PASS=<NEW_DB_PASSWORD> --app changelog-2022-03-13
```

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

### Step-by-step guide

1. Connect to the **replica** instance:
```console
flyctl ssh console --select --app changelog-postgres-2023-07-31
```

2. Backup db to local file, then restore to remote host:
```console
time pg_dump --dbname="<FLY_POSTGRES_URL>" --format=c --verbose > /data/changelog.sql
time pg_restore --dbname="<NEON_POSTGRES_URL>" --format=c --clean --exit-on-error --no-owner --no-privileges < /data/changelog.sql
```

> **Note**
> This step can be re-run as many times as needed. It performs a point-in-time
> db dump & restore - cleans existing data!

3. [Warm-up the query planner](https://www.postgresql.org/docs/current/sql-analyze.html):
```console
time psql "<NEON_POSTGRES_URL>" --command "ANALYZE VERBOSE;"
```
