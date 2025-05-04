[![shields.io](https://img.shields.io/badge/Last%20updated%20on-Feb.%2022%2C%202025-success?style=for-the-badge)](https://shipit.show/80)

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

        chat(( fab:fa-z Zulip )):::link
        click chat "https://changelog.zulipchat.com/#narrow/channel/455097-kaizen/topic/Code.20deploys"

        repo -.-> |.github/workflows/ship_it.yml| cicd
        cicd --> |magefiles/magefiles.go| automation

        cicd --> |success #kaizen code| chat
    end

    repo -.- |fly.io/changelog-2024-01-12| app

    registry --> |ghcr.io/changelog/changelog-prod| app
    runner --> |flyctl deploy| app

    repo -.- |fly.io/pghero-2024-03-27| pghero

    %% PaaS - https://fly.io/dashboard/changelog
    subgraph Fly.io
        proxy{fa:fa-globe Proxy}
        proxy ==> |https| app


        app(( fab:fa-phoenix-framework IAD & EWR changelog-2024-01-12.fly.dev )):::link
        style app fill:#488969;
        click app "https://fly.io/apps/changelog-2024-01-12"

        pghero([ fa:fa-gem PgHero 2024-03-27 ]):::link
        click pghero "https://fly.io/apps/pghero-2024-03-27"

        grafana[ fa:fa-columns Grafana fly-metrics.net ]:::link
        click grafana "https://fly-metrics.net"
        grafana -.- |metrics| app
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

    subgraph Namespace.so
        runner([ fa:fa-person-running GitHub Runner ]):::link
        click runner "https://cloud.namespace.so/9s8hfvousnlae/ghrunners"

        automation --> |runs-on: namespace-profile-changelog| runner
        runner --> |ghcr.io/changelog/changelog-runtime| registry
        runner --> |ghcr.io/changelog/changelog-prod| registry

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
> [Continue live editing this Mermaid diagram](https://mermaid.live/edit#pako:eNqVWAtv27YW_iuEihUtEEl-v7bei67eTYtiW1BvGLB4GCjpWNIskbok1cSJ8993KOpBOfa6BkUqUed9vvNgHp2QR-CsnG--IYlShVz5_o4zRe9A8hy8kOe-BCrCZMtiQYuE_LLeMoI_YUalXMOOZCnbE6kE38PqxXQZjBbzK_Pq3qWRSlbj4v5bw2N-o6p3qJS8JCgBlDSnsgyMgutUvS8Dc6h_BBT88ZHsaLDaUTdOVVIGRCUQJpTFkPHYb5-0ueTpabVaaaM6EWGWhvtKENk6jZtGUuXhZWlbZ8ssOWkY3fpoirYkTEWYgRsi7742mrwNVcoZcckmSQvyQZHt9o8L1mhZX2uNTyv50r_jYr_L-J30JSr6M1XeIc-0rY2O7omWiudUs91ut20UeYZiyZrGMQhyzclm_ZH4l0ztRHy1wUHGAz-nUoHA_2LYpRnI7smLeT_CAuIUwXN49eok4XESCi_l5PXri9k1nOdN5CKWfTsLGu7RDHmS4YSqTvcD-b3MMJEXlWpyS2Hn-4Pm018r7S8YFYLfVd8ZZP5kOh0s5-6epg_AfMWLNPR1SXijQQRFxg_yNCqIXNdz_0OOnnHqPAKOFar6eCWuZjsf-6OV2nPY6fhlGYYgJXlhbCa6axwr9w01sMgu8cZgctxlB0xbFxl3NBhN3MHQHY5Qe1H0ueoUVirrjPtnoOUWgkcWuygxrMKwocJQZcTEsaa5YFQRJyB4bdHYHc2PxBw1HNipbijdYD23vdFwRlQmAaci6mw66WL_qwi7UKLF94dH0zliLAogN_rk6YSCvHmDPlTaLP-eZ8aq76LoAFskHFh67-4EzUFDhHx4u8ZG-8Nvn8i5FHjanwg-n0O4VIcMtHiCcMlWLyaLxXK2_PZZc0CCrgLq-OChPJvzPq5NtF_d1h01hpzcxO_xiHQ5IX9cKj7DfUH5s9z2NWOSdpTRRnPIszJnklybY4KS3ByUSEPpMVDkUmesxfRtsDntntwQVxCsaU6SfJ6kAWVbaOZRR_67NxVgbrhUsQCkjQJxZz7X4dFFYQ5PEPoTcOYp0JO9Ua_p2mxEVNGASiA5TRkJBGVhgiBNc4oVejEpWoTdEXFa8QwwFLUynR0fof4XhEpiW9YQcSUvWeQuZrPBZLmY-UYX9qpAuHeURSBSFrsy1yvFfDGZLYbTZT-dqJUP_9lyrH40kKLlfX_rvlp_VnA0wp5Fu4sblpbE6QGetOrbtKDWhAKE5MzVp2h7sx58Mn3qYvDqPmaFL-Nl5DFLo7-Ui2T3mZeSZRT8ODE8JwPDmthVU0Qi6XK2Iq0o3UL1GHDbKj3W6k99-nI3RjqV5hi5poF_vQjT0Dv-Z-HHVryBUHTronmpWp8O-B4OZHiDCyV2vei0nZno1ixn5_WwqFmred1UbcNhIFK_WSV74bseND27zf5sOPRzazUOY5buDhresd6nyS-HAiQwxO7r112Vu16tQDMfSbOQtxp-uA-hqDbDOm7te6sppMINBY4tNIfpGXs2RB2jFSVZMejM4RZFWfpAzRLaZS-HKKV-KmWJRfvfurrfTGcznBijJpiWI52ao6XScujd-idr6ObYEmPwdrhGYofXCcK2skvjUgAaJz6nuJr48_hjEH7cfLxeH_7_6_xDuRaTMVyfTuVKhD084f6W9O8PF7dgpD2Lnfqa8Hw0t2rf4rZQCtYf5mHEbvUv70R9R9UuVefa0NvfNt5m3BEjv7xt9gB6J615rz81cluZlTsvtQEGvZroWEmx8vBzoONLgzRLVR02bh-18ArKmLznDA7oQnAeWz1GK5Bl6iUNZ7896D6uL4jd0Z-8QDBCBno2HvwEr6h9eGlPlMD-hr7w58ZXkbD9PUNjOa9hjHsQTqkYrKjZO1q1tZ2k5p3u2ruMCvA-jSywVbfdNkdhS2WlytBYiCwydMYGxQ4g-oKQisQQehcktTDA_Pd3TmPAS8NuQeFHzlKMBLaqE2-_B4W3u43C-5S9PFJVymYaZvQAwo0FL4v6i_fvas4Q273oDHd_9OWtnS04cRvAQacAZ7EkvxZ6Vl2-0nX8NkYrJi-oXJXaVXPxBZr7w_F4PBj5NZ-0W4ElCzuf6X0N3bHC0gXaPiHm6F_RWVj8AqUJowUF58rJQeC-FDkr51F_2Dp4XdbltcLHiIq9duwJ6fRusTmw0FkpUcKVUxZYp7BOKcIhbw4Lyn7n3H51Vo_OvbNyR1NvvFxM57PhcDoYLebLK-fgrCYzb7lcDvHfYDwdTcazpyvnoRIw9Aaz6XIwHkzH8-FospxOrhwcN-jHj-YvV9UfsK4cBFecOJjuTMLT342nIgg)

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

The production instance of our application is running on Fly.io, as 2 instances
spread across 2 regions: IAD & EWR. All https://changelog.com requests are
served via Fastly. Each Fastly request gets proxied to our application instance
via the Fly.io Proxy.

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
  - [Uses a Namespace.so GitHub
    Runner](https://github.com/thechangelog/changelog.com/pull/522) so that
    caching is reliable & persistent across workflow runs
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

1. Start by creating a new app, e.g. `flyctl apps create changelog-2025-05-05 --org changelog`
2. Copy the existing app instance config, e.g. `cp -r fly.io/changelog-{2024-01-12,2025-05-05}`
3. Run all following commands in the app directory, e.g. `cd fly.io/changelog-2025-05-05`
4. Update the app name in e.g. `fly.toml` to match the newly created app
5. Set the few secrets required by the app to work correctly before promoting to live

        flyctl secrets set --stage \
            OP_SERVICE_ACCOUNT_TOKEN="$(op read op://changelog/op/credential --account changelog.1password.com --cache)" \
            STATIC_URL_HOST=cdn2.changelog.com \
            URL_HOST=changelog-2025-05-05.fly.dev

6. Deploy the latest app image from <https://github.com/thechangelog/changelog.com/pkgs/container/changelog-prod>

        flyctl deploy --vm-size performance-4x --image <LATEST_IMAGE_SHA>

## How to promote a new app instance to production?

1. Update `APP_PROD_INSTANCE` in `.envrc` to match the newly created app name, e.g. `changelog-2025-05-05`

        direnv allow
        env | rg APP_PROD_INSTANCE

2. Ensure that the app is scaled across multiple regions & is resilient to a single region failure:

        just prod-region-resilient

3. Unset the following app secrets

        flyctl secrets unset STATIC_URL_HOST URL_HOST

4. Update the app origin in the CDN with the new app instance URL, e.g. `https://changelog-2025-05-05.fly.dev`

5. Update the previous app instance reference everywhere in this repository - starting with the diagrams in this file.

6. Update [`APP_PROD_INSTANCE` in GitHub Actions](https://github.com/thechangelog/changelog.com/settings/variables/actions/APP_PROD_INSTANCE)

## How to branch the production db instance?

See [Enable changelog.com devs to create prod db forks with a single command](https://github.com/thechangelog/changelog.com/pull/508).
