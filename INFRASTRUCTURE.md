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
        
    repo -.- |2022.fly/docker| container

    %% PaaS - https://fly.io/dashboard/changelog
    subgraph Fly.io
    
        proxy{fa:fa-globe Proxy}
        proxy ==> |https| app


        container([ fab:fa-docker Docker Engine 2022-03-13 ]):::link
        click container "https://fly.io/apps/docker-2022-06-13"
            
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
    secrets -..-> |secrets| cicd

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

    %% Observability
    observability(( fa:fa-bug Honeycomb )):::link
    click observability "https://ui.honeycomb.io/changelog/datasets/changelog_opentelemetry/home"
    apex -.-> |logs| observability
    app -....-> |traces| observability
    
    %% Object storage
    apex ==> |https| proxy
    subgraph AWS.S3
        subgraph us-east-1
            assets[ fab:fa-aws changelog-assets.s3.amazonaws.com ]
        end
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
> [Continue live editing this Mermaid diagram](https://mermaid.live/edit#pako:eNqdWG1v2zYQ_iuEig4tEEm2lcSOu27I6i4t0m7d3G7A4qKgJFrmLIkqSTVR4_z3HUm9UK6ctvMHx5Lu5bm7546n3DoRi4kzdx4-RBspCzH3_TXLJb4mgmXEi1jmC4J5tFnlCcfFBr1drHIEnyjFQizIGqU03yIhOduS-YOTs3Aymx6ZS_eaxnIzD4qbJ0bHfIOrZ-AU_YDAApHC3BVlaBxcUPmiDM1N9eGkYLe3aI3D-Rq7CZWbMkRyQ6INzhOSssRvfym46O5uPp8rUJ2JKKXRVhtCK6cJ01jSER62tnJWuWWHRvGVD1AUkojyKCVuBLrbGjQ6jyRlOXLRckML9FKi1er9ATTK1vei8bG2L_xrxrfrlF0LX4CjD1R6VZYqrI2P7hcuJcuwUrtardosshTMogVOEsLRBUPLxSXyD0HtTHw34DBloZ9hIQmHPwlZ05SI7peXsH6GOUkokKd69Giv4Mkm4h5l6PHjg9U1msMQGU9EH2eBoy3AEHsV3mDZ-RYpCKGl_j7oWKlYTrv4tbYpG_QP_QSBPxsFy_PZX88n-1EDM13P_QntPAN6uMI7zZo-H5Gr1IZzu7NKN8SNTl-UUUSEQA9i8mmnQzJSJI_t1m2Aot1kNJl467QCF0XRF6nroO3WZfMH-OEWnMWWeqTGDs2Bj1oTbEcyRTEpUmZ7uQ-MH7NoS_ius9VkGWbOG4yX0JntlEsrBSzGYhMyzOMO2N48-lUL2iGqD4C_qW7NJEiA5AS9UXfu9iTQ06cQi_ZZx9BjWwPz0VVDORMBWpg_z_MEHiMVnzsK3HGA3h-kYZu-jot1jOBX1KlxjalTMGWPi72RURRdDxQbRnJ64645zohiJTovCtRVscOmKuABf4ZaRcgqJcowAm6m8wfHs9nZ6dmTLyYNCAzDH3J4OII4vNYp1RnFEodYQIGYkAknyz9eoVcEx5ApMBW4o6kbjA_nFUx9FVJhLAu3M3gfNj6-F9yfQHka4T46mzYqSz9qYhWJ-AhTATD2Yq9nCTeGVPfvtNuekW6o6367ptC5JTRCr3u-YOrX25qXuaQZ2bWT4H9ZMcOhM9EZyYjkNBJx2CYRtLh0U9Up0ITwfENKoXO2p9MqsLTMcoEuOF7jHCOoqluLeDmR6NBBWMv0-WBr2lVvhF0XJhSEk6lKteAH4jGzrL7cm3iHhHqVPyS0V08909uxuCQR75Ywc6G7XyVqSyo0fgNrGjR-vN_XJie1yuAJOC5qVX0KNslpNAxJ6ysr3u55X8CcfRZws5YaFfW7hQ1nYE7XFc0TmM0AAb2tCiJIDn32uGaF6iFwUHtQ2jvULLqti-c3ESn0xlVnrr1uXUWYuxGHQwTw5OrYG0xSp2jlSWgF1QCwneCcfsZmueuaICMxxT4VooSD_Wfg0L8kkk9PTk9heE6adNqRdH52lk8romeL36wzMAPyJ8Rbw34Gc03VCKiypknJCaDjnyjsBP40uQyjy-XlxaL6-G76slzw44Bc7B-S2oQ9osjNFeov5gfXS5AdpE-9f385Qlu353B4lzzvj9oozq_Ul7fnvpNqt5p-K_weqqBxSFMq61iYfastelgm6AXLSQV2w-GK9xSt6ErqbRrN_uxTR4F6HepufWAFUISkRHVy5W9gtHVFh5yZBgJBqDb7EntDDC0lOYZiDspZ8St-wVnNONDCcmQvMXqt2av--d9LbxkM1KcULgFmuON-hcx7X7vz4GthLRTmoScCD2f4M8vh6f31q2veX7XqN8s2ttcspxAXjIQ97L8QCS8nSwm7ur2uYFm2x0WKK9icEs7Kon7ifRuzjbDd8gPa_VeBrMXZsg02BHjPlCTPqUDvCnW4Hn4b6fRt0mklL9ShCtm8lkiCM38cBMFo4td6oneCdbZaHjVyO82MA7J9QajNN8lZzPqKpEmjRQHnyMkIzzCNnblzqx6sHNgCVL_M4WeM-VYFdgdyau9ZVnnkQGpTQY6csoDOIwuKgQ9Ze7fA-T-M9a6d-a1z48xPT7zx2SQIJrPTaRBMZ8GRUznzydSbzU5mxyejk-PR2fR4Nr07cj5rC2NvNBqfToLJdDI7O5mNQQHmOkTy2vzrRf8H5u4_mDKjsw)

Let's dig into how all the above pieces fit together.


## A three-tier monolith

TL;DR:
- **Front-end**
  - Fastly
  - Fly.io Proxy
  - AWS S3
- **Application**
  - Elixir / Phoenix
- **Database**
  - PostgreSQL

[changelog.com](https://changelog.com) is a monolithic
[Elixir](http://elixir-lang.org) application built with the
[Phoenix](http://www.phoenixframework.org) web framework. It uses
[PostgreSQL](https://www.postgresql.org) for persistence &
[Node.js](https://nodejs.org) to digest & compile static assets (CSS & JS).

Static assets, including all our mp3 episodes, are stored on AWS S3. They are
served via Fastly, specifically https://cdn.changelog.com. In summary:

```
Fastly (cdn.changelog.com)
↓
AWS S3 (changelog-assets.s3.amazonaws.com)
````

The production instance of our application is running on Fly.io. All
https://changelog.com requests are served via Fastly. Each Fastly request gets
proxied to our application instance via the Fly.io Proxy. In summary:

```
Fastly (changelog.com)
↓
Fly.io Proxy
↓
Application (changelog-2022-03-13.fly.dev)
```

The production database - PostgreSQL - is running on Fly.io too. It is a
replicated setup, with one leader & one replica. In summary:

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
  - [Connects to a Docker Engine running on
    Fly.io](https://github.com/thechangelog/changelog.com/pull/416) so that
    caching is reliable & persistent between runs
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
