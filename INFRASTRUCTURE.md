[![shields.io](https://img.shields.io/badge/Last%20updated%20on-Mar.%2016%2C%202023-success?style=for-the-badge)](https://shipit.show/80)

This diagram shows the current changelog.com setup:

```mermaid
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
        
        cicd ----> |success #dev| chat
        
    end
    
    repo -.- |2022.fly| app
    
    registry ---> |ghcr.io/changelog/changelog-prod| app
    container ---> |flyctl deploy| app
        
    repo -.- |2022.fly/docker| container

    %% PaaS - https://fly.io/dashboard/changelog
    subgraph Fly.io
    
        proxy{fa:fa-globe Proxy}
        proxy ====> |https| app


        container([ fab:fa-docker Docker Engine 2022-03-13 ]):::link
        click container "https://fly.io/apps/docker-2022-06-13"
            
        app(( fab:fa-phoenix-framework App changelog-2022-03-13.fly.dev )):::link
        style app fill:#488969;
        click app "https://fly.io/apps/changelog-2022-03-13"
            
        dbw([ fa:fa-database PostgreSQL Leader 2022-03-12 ]):::link
        click dbw "https://fly.io/apps/postgres-2022-03-12"
            
        dbr1([ fa:fa-database PostgreSQL Replica 2022-03-12 ])

        app <==> |pgsql| dbw
        dbw -.-> |replication| dbr1

        automation ---> |wireguard| container
        container --> |ghcr.io/changelog/changelog-runtime| registry
        container --> |ghcr.io/changelog/changelog-prod| registry

        metricsdb([ fa:fa-chart-line Prometheus ])
        metrics[ fa:fa-columns Grafana fly-metrics.net ]:::link
        click metrics "https://fly-metrics.net"
        metrics --- |promql| metricsdb
        metricsdb -..- |metrics| app
        metricsdb -..- |metrics| dbw
        metricsdb -..- |metrics| container
    end

    secrets(( fa:fa-key 1Password )):::link
    click secrets "https://changelog.1password.com/"
    secrets -.-> |secrets| app
    secrets -.-> |secrets| cicd
        
    %% Exceptions
    exceptions(( fa:fa-car-crash Sentry )):::link
    click exceptions "https://sentry.io/organizations/changelog-media/issues/?project=5668962"
    app -..-> |exceptions| exceptions

    %% CDN - https://manage.fastly.com/configure/services/7gKbcKSKGDyqU7IuDr43eG
    subgraph Fastly
        apex[ changelog.com ]:::link
        click apex "https://changelog.com"
        
        subgraph Ashburn
            cdn[ cdn.changelog.com ]
        end
    end
    observability(( fa:fa-bug Honeycomb )):::link
    click observability "https://ui.honeycomb.io/changelog/boards"
    apex -.-> |logs| observability
    apex ==> |https| proxy
    subgraph AWS.S3
        subgraph us-east-1
            assets[ fab:fa-aws changelog-assets.s3.amazonaws.com ]
        end
    end
    cdn ==> |https| assets

    %% Monitoring
    monitoring(( fa:fa-table-tennis Pingdom )):::link
    click monitoring "https://my.pingdom.com/app/newchecks/checks"
    monitoring -.-> |monitors| apex
    monitoring -.-> |monitors| cdn
    monitoring -.-> |monitors| app
```


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

All app errors - e.g. `Plug.Conn.InvalidQueryError` - show up in Sentry.io.

Pingdom.com monitors our public HTTPS endpoints & alerts us when they become unhealthy.


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
