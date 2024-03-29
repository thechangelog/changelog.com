[![shields.io](https://img.shields.io/badge/Last%20updated%20on-Mar.%2028%2C%202024-success?style=for-the-badge)](https://shipit.show/80)

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
    dagger06 --> |flyctl deploy| app
        
    repo -.- |fly.io/dagger-engine-2023-05-20| dagger06
    repo -.- |fly.io/dagger-engine-2024-03-28| dagger010

    repo -.- |fly.io/pghero-2024-03-27| pghero

    %% PaaS - https://fly.io/dashboard/changelog
    subgraph Fly.io
        proxy{fa:fa-globe Proxy}
        proxy ==> |https| app

        dagger06([ fa:fa-project-diagram Dagger Engine v0.6 2023-05-20 ]):::link
        click dagger06 "https://fly.io/apps/dagger-engine-2023-05-20"

        dagger010([ fa:fa-project-diagram Dagger Engine v0.10 2024-03-28 ]):::link
        click dagger010 "https://fly.io/apps/dagger-engine-2024-03-28"
            
        app(( fab:fa-phoenix-framework App changelog-2024-01-12.fly.dev )):::link
        style app fill:#488969;
        click app "https://fly.io/apps/changelog-2024-01-12"

        pghero([ fa:fa-gem PgHero 2024-03-27 ]):::link
        click pghero "https://fly.io/apps/pghero-2024-03-27"

        automation --> |wireguard| dagger06
        dagger06 --> |ghcr.io/changelog/changelog-runtime| registry
        dagger06 --> |ghcr.io/changelog/changelog-prod| registry

        grafana[ fa:fa-columns Grafana fly-metrics.net ]:::link
        click grafana "https://fly-metrics.net"
        grafana -.- |metrics| app
        grafana -.- |metrics| dagger06
        grafana -.- |metrics| dagger010
        grafana -.- |metrics| pghero
    end

    app <===> |Postgres| dbrw
    pghero --> dbrw

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
    app -..-> |search| search

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

    subgraph AWS.S3
        logs[ fab:fa-aws changelog-logs ]
    end
    apex & cdn-.-> |logs| logs

    %% Observability
    observability(( fa:fa-bug Honeycomb )):::link
    click observability "https://ui.honeycomb.io/changelog/datasets/changelog_opentelemetry/home"
    app -.-> |traces| observability
    logs -.-> |logs| observability
    
    %% Object storage
    apex ==> |https| proxy
    subgraph Cloudflare.R2
        assets[ fab:fa-cloudflare changelog-assets changelog.place ]
        feeds[ fab:fa-cloudflare changelog-feeds feeds.changelog.place ]
    end
    cdn ==> |https| assets & feeds

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

> [!TIP]
> [Continue live editing this Mermaid diagram](https://mermaid.live/edit#pako:eNqdWHlv2zYU_yqEihYtEEk-4iPuuqFrurQo2gVzuwGLi4KSaImLRGok1cSN8933SOqgHDtNlz8cmXr38XuPvvFinhBv4T1-jDKlSrkIwzVnCl8RyQsSxLwIJcEizlYsFbjM0MfTFUPwF-dYylOyRjlll0gqwS_J4tHkJBrNZ0f2q39FE5UtxuX1c8tjP0HVK1CKniCQQJS0p7KKrIIzqt5UkT3Uf4KU_OYGrXG0WGM_pSqrIqQyEmeYpSTnadg-aXPR7e1isdBGdSLinMaXRhBaeY2bVpLx8LC0lbdijhwaJxchmKItiamIc-LHwHtZG41exopyhny0zGiJ3iq0Wn0-YI2W9aPWhNjIl-EVF5frnF_JUIKiL1QFmyLXtjY6uidcKV5gzXaxWrVR5DmIRac4TYlAZxwtT9-h8JCpnYgfNjjKeRQWWCoi4F9K1jQnsnsKUt6PsCApheLZPH26k_A0i0VAOXr27GB2Led-E7lIZd_OEseXYIbcyXCGVadb5kCElubzoGLN4ijt_DfcNm3QP_QrOP5qMF6-nP_5erTrNVSmH_g_o21gjd6f4a2pmn49Il-z7Y_t1kndvtro-GUVx0RK9CghX7fGJUtFWOK2bmMo2q7zDaSj89YfDUbH_mDoD0egtSz7XHVqjKo6k-GekvFLwROHPTH1OZhaRlAZqxwlpMz5xqG6xzwrwCcspYxoE8f-YAL_t63ohzKCb2N_NG8Zh4MmgXd4yzQjgndMsy2yRw0HAOA5xkuAiRZyG60yizgWSReSHXD8zRB2fkPArjc3FpBS6DWCzvXJ7Q4FevECAmi01YHrCJpIPL2ogQ04_iGx8hOKQWnRoMRrEwv0dRBMURdJ9PlQX7TJ63qjdhMMkAdT0--MNtoPt244QF2-vmseUD_Qvlqii7I7SFuWHXSUGSeMXvtrsJHoZkYvyxLta5dAa4W224cwUm1yogUjaOl88eh4Pj-Znjy_A9BAsN-LfQr7Ebal2YY3JQU6T9_AURfF2eEoWu4Dyu80Ql-zM1ZMf19RAIoKqn-3O-9CwX0YIiqmaEG2Lez8HyEWiDoJnQwoujVmuIlXzPOqYBKd2WME_vsFUYLGMmBEoUMztRbTj5zL6dZZQ2xQpqbZAcD9JHfjeC-dBrX7CRsga2eDfdQF-NMLAzLnXKpUEC00Elf2dV0lOur2cAfVPhDOAkX0ktmmCujaokywwhGWBBWYMhQJzOIMgI0WGIbK4Q4HEe5ghsWJ5wRiWyvTRRrWcCJhQ9C59yWvWOLPp9PB8cl8GlpdMFYj4V9hlhBBWerLQm-3s_nxdD6cnOwgViT48H7LYWKAgRgs7_tbrwD1a0W2VtidaMP8WJJYdKuz_WLARyu9JBs0PIflGnAn2YUVG5uaZe_eMixrVrO7NHXYcFgb629OER54r6djz257l7Ac-rm1GhYXRtcbHd9U3y3Qx01JJGEQvGfPujLzg1qBZt6i5nLSanh9HZPSbMl13NrvraYYCz8WMGvBHKb3kr0h6hidKEnDoFEDNkrM6DdsF_IOOQoCkymkUlZQNb_U5fViMp0Cco-aYDqOdGq2jkrHoVenH5xNoYCeTEmwhpUakFYnCOp6TdNKEDBOfKWwxoWz9F0Uv1u-Ozvd_Ptp9rY6Fcdjcra7ShgR7vgi1xeof5c6eCMA2r21U1-Z7g7HVu1LWHEqwfpDNE7Yhf4IdtR3VO0i6vRBJ_OvZbAcd8TALy-aSYyvpDN39atGbivTuPNEG2CrVxNtjRQnD79HOr44ojlVddi4e9SWV1Sl6A1nZAMuRPtrq8foBLKiQdZw9keTBhJ9We6OvvASipHkRIPzJszgut4vL-2JEjjWWMzvGm8i4fq7h8ZxXpcx7CMAkylxouYulmbV3EnNq5xXyTrHggR_jJxiMzf_NkdxS-WkytI4FVnChYq4RbEmJPmOEENiCYMDktoygPz3F2VrwBPL7pTCe84oRAKgasfbX4mCm-5SwcXPXeKwqmQzEXK8gbUyFbwq6zfBw3rOErtYtIe7P4uK1s62OGEc5cRXhDEq0adSb0qHr7Ydv1ujhimIjKtSNXdcRXARDsfj8WAU1nzShQJHFiCfxb6Gbmtq6QBtnxBy9CA6pxa_Q2nD6JSCd-QVRMDATryFd6NfrDyVEd1eC3hMsLjUjt0CnV5hlxsWewslKnLkVSX0KTm1VxMP4p1LOC0x8xY33rW38GfjaTCdDQYn8-PRZDYZzo-8jbc4GQbD48lsPJoN4Hgyntweed84BwnDYDaejE-OB7CbDWYDIIfxAna_t7_amR_vjIK_DblRePsfsqFhlQ)

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
Application (changelog-2024-01-12.fly.dev)
```

The production database - PostgreSQL - is running on Neon.tech. It is
replicated setup, with one leader (RW) & one replica (RO). We are currently not
using the replica, and since Neon.tech scales down to 0, this doesn't cost
anything.

```
Application (changelog-2024-01-12.fly.dev)
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
  - [Starts a Dagger Engine as a Fly.io machine on-demand, then connects to
    it](https://github.com/thechangelog/changelog.com/pull/471) so that caching
    is reliable & persistent across workflow runs
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
we are still pasting them manually.

> [!NOTE]
> We should use `op` here too.


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
Kaizen episodes](https://changelog.com/topic/kaizen).

For example, this diagram and document were created in the context of [🎧
Kaizen 8: 24 improvements & a lot more](https://shipit.show/80). If you would
prefer to stay in reading mode, check out [GitHub discussion
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


## How to branch the production db instance?

See [`changelog/README.md`](changelog/README.md).
