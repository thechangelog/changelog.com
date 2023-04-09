[![shields.io](https://img.shields.io/badge/Last%20updated%20on-Mar.%2016%2C%202023-success?style=for-the-badge)](https://shipit.show/80)

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
            
        dbw([ fa:fa-database PostgreSQL Leader 2022-03-12 ]):::link
        click dbw "https://fly.io/apps/postgres-2022-03-12"
            
        dbr1([ fa:fa-database PostgreSQL Replica 2022-03-12 ])

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
    secrets -.-> |secrets| cicd

    %% Search
    search(( fa:fa-magnifying-glass Typesense ))
    app -.-> |search| search

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
    click observability "https://ui.honeycomb.io/changelog/boards"
    apex -.-> |logs| observability
    app -..-> |traces| observability
    
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
    monitoring -...-> |monitors| apex
    monitoring -.-> |monitors| cdn
    monitoring -.-> |monitors| app
```

> **Note**
> [Continue live editing this Mermaid diagram](https://mermaid.live/edit#pako:eNqdWG1v2zYQ_iuEig4tEEl-SWLHXTcEdZsWabds7jZgcTFQFC1zlkiVpGq7cf77jqSsF0dO0fmDbUn38tw9d8ez7zwiYupNvKdP0VLrXE3CcCG4xmuqREYDIrJQUSzJcs4TifMl-jidcwQvkmKlpnSBUsZXSGkpVnTy5OwiGoxHJ-7SX7NYLyfDfPPC6bh3cPUKnKIfEFigWrm7qoicgyum3xaRu2lekubi7g4tcDRZYD9hellESC8pWWKe0FQkYfXNwEX395PJxICqTZCUkZU1hObePkxnyUZ43Nrcm_OGHUbi2xCgGCSESZJSn4DuqgSNLolmgiMfzZYsR-80ms8_HUFjbH0vmhBb-ypcC7lapGKtQgWO_mE62Gapwbr3UX_DhRYZNmq383mVRZGCWTTFSUIluhJoNr1G4TGotYnvBhylIgozrDSV8JHQBUupqr8FiWhnWNKEQfFsnz07IDxZEhkwgZ4_P8qu0-yGKGSi2jhzTFYAQx0wvMS69q1SEEIz-37UsVFpOK3jt9qONugf9gUCf9Ubzi7Hf74eHEYNlekH_k9oFzjQ3QzvbNW06xH5Rq07t7sGdV21UeurghCqFHoS0y87G5KTojxutu4eKNoNeoNBsEi34CLP2yIlD9ZuSVvYUR9-LkXcUCdm7DAO9Wg1wTbRKYppnoqml8fAhLEgKyp3ta19lmHm3GA8g86sply6NcBirJaRwDKugR3MozdWsBmieQH4zfbOTYIEipyiG3Pn_kACvXwJsVifZQytatvDfHa7LzkXAZq6j9c8gcfIxOf3hn5_iD4dLcMqfXUtljGCX1WmxnemzsFUc1wcjIw8r3sgXwrK2cZfSJxRU5XoMs9RzWKNzTAQQP10tYrS25QawwhqM508OR2PL84vXjyYNCDQDb_L4fEI4mhtU2ozijWOsAKChNKJpLPf3qP3FMeQqcrU4HhewdQRSLmzp2pEg8cQyf6jkH6HQmcEtzE1i8Xk5kdbTnmiPsMsAGStiMsJIp0h0_M767ZlpB7ltsvWDPq1gPJv9cyD-vx2M8uCa5bRXdX__8uKGwm1idpIRrVkRMVRlUTQktpPTX9A68HzJS2UzdmBTqUg0iLjCl1JvMAcI-DSL0UCTjU6dvyVMu0qaGo2Wd8L-z7MJQgnM0xV4DvicROsvDyYc8eEWswfEzrg007yahjOKJH16uUubM-bRK3oFvVvYDmDdo8Pu9nlpFTpPPf6ealqz759cvYarkjLq0a8R567A6-B2-2iTsN8r1DDwcfZYst4AgMZEKCP25wqyqHNnpdFYVpob9_o7tB-t60cvN4Qmtslq0xbdV05Ilj6RMK5AWi4Oek6M1QrNpKkrIKpflhIMGdfsdvn6g7IaMxwyJQq4Cz_GQroX0r0y7Pzc5iX1XhxcQQ2ktrPruGzEdGr6S-NYy-Dyk9osICVDEaZIQjqZMGSQlJAJ78wWAPCUXIdkevZ9dV0-_mP0btiKk-H9OrwXLQmmvOJbm5Rexc_ulGCbGftlCv3w_lZub2E87qQvD1nScxvzVtw4L6WqhaZdh_8GpmgccRSpstYRPNWRXpUJOit4HQLdqNuxluKjegKFiz3mu3BZxcPVbMKSXHlCQ-BTvEQXMm8kdESA1edUg17zf3DbiQHLF7-NQtmw448F8qnwLDfb2fa_WSr1hW8Vo1dwD0M1DDAGf4qODx9nIeSu_aWVP4orDj6IDjTQkJju1tZdV2xA8cp_BTTlHOm0A08icFrJ0m1coOhbBvkTsmt63kecrq2v-xMb5qPPUkN_X0HlrfsMKObDrG2EMT7TRk7Fb0TL6MywyyG3-d3RmfuwSGX0bk3ga8xliuD6h7kzLE-23LiTbQs6IlX5LBi0CnDwGXmQYZSBXdzzP8WonXtTe68jTc5Pwv6F4PhcDA-Hw2Ho_HwxNt6k8EoGI_PxqdnvbPT3sXodDy6P_G-Wgv9oNfrnw-Gg9FgfHE27oMCDC4A_8H9nWD_Vbj_D0sOQh8)

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

Pingdom.com monitors our public HTTPS endpoints & alerts us when they become unhealthy.


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
