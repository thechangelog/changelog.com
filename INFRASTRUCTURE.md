[![shields.io](https://img.shields.io/badge/Last%20updated%20on-Sep.%202%2C%202024-success?style=for-the-badge)](https://shipit.show/80)

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
    runner --> |flyctl deploy| app
        
    repo -.- |fly.io/dagger-engine-2024-03-28| dagger010

    repo -.- |fly.io/pghero-2024-03-27| pghero

    %% PaaS - https://fly.io/dashboard/changelog
    subgraph Fly.io
        proxy{fa:fa-globe Proxy}
        proxy ==> |https| app

        dagger010([ fa:fa-project-diagram Dagger Engine v0.10 2024-03-28 ]):::link
        click dagger010 "https://fly.io/apps/dagger-engine-2024-03-28"
            
        app(( fab:fa-phoenix-framework App changelog-2024-01-12.fly.dev )):::link
        style app fill:#488969;
        click app "https://fly.io/apps/changelog-2024-01-12"

        pghero([ fa:fa-gem PgHero 2024-03-27 ]):::link
        click pghero "https://fly.io/apps/pghero-2024-03-27"

        grafana[ fa:fa-columns Grafana fly-metrics.net ]:::link
        click grafana "https://fly-metrics.net"
        grafana -.- |metrics| app
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
> [Continue live editing this Mermaid diagram](https://mermaid.live/edit#pako:eNqVWHlv2zYU_yqEihUtEEk-4nPrhqzp0qHYFsw7gMXDQEnPkhaJ1EgqiRfnu-9R1EE5VrvmD0em3v1-76AfnZBH4KydL74giVKFXPv-jjNF70HyHLyQ574EKsJky2JBi4T8crllBP_CjEp5CTuSpeyWSCX4LaxfzFbBZLk4M1_d-zRSyXpaPHxpeMwnqnqLSslLghJASXMqy8AouErV-zIwh_pPQMEfH8mOBusddeNUJWVAVAJhQlkMGY_99kmbS56e1uu1NqoTEWZpeFsJIluncdNIqjwclrZ1tsySk4bRjY-maEvCVIQZuCHy3tZGk4tQpZwRl2yStCDfK7Ld_jlgjZb1udb4tJIv_XsubncZv5e-REV_pcrb55m2tdHRPdFS8Zxqtpvtto0iz1AsuaRxDIJccbK5_ED8IVM7EZ9tcJDxwM-pVCDwXwy7NAPZPXkx70dYQJwiePavXh0lPE5C4aWcvH49mF3DedpELmLZt7Og4S2aIY8ynFDV6ZYZEpFN9TmoWLNYSjv_K26TNqyf9A4dfzuabi6Wv72bHHuNyHQ992ty8IzRpzN8qFDTxyNxNdvp2B6s1J3CRscvyzAEKcmLCO4OlUuGClhkl25jKDnssj2mo_PWnYwm5-5o7I4nqLUo-lx1aipVdSb9E5BxC8Eji12UjCE-KzZUGKqMRFBkfG_RfMS4qIK3CyxOGdQGTt3J8kDMm9F41GThGW8RJyB4x7Q4EHPUcGAXu6Z0g7Xe9s1Gq0wCTkXU-XXU4b6rCDvz0euH_aPpKjEWDJBrffJ0REHevME4VNpq_zuC1qFXN3V7Qpa_IVRulFLUmje1_q4KBrkbeeMR6UJC_hyCdyvZwnjtKdogB4Nsd6OjjlQUXYkVCQeWPrg7tBE06MlFUZBTsPK0VoTnqUqUap-BFkwQ-tn6xflyuZqvvnzWyJDgtBenFPZr1GS_DW8MObmO3-NRF8XFcBQN94DyZ1jra8b07SijjeaQZ2XOJLkyxwQluTkokYbSY6DIUBevxfRtsDntjDXEVUnUNEdFd5rEqqyPEzbV1HYZ86hT9NWbCunXXKpYgBYaiHvzuo6j7gjm8Ki0fgTOPAV6XWlLA-natEVU0YBKIDlNGQkEZWGC1ZXmFNvTcA2gCLvF4wjmGWDMamU6jX5dcBJnjcaSK3nJInc5n4_OV8u5b3Rhgw6Ee09ZBCJlsStzvSctlufz5Xi26ucdtfLxxy3HtoUGUrS87289TOrXCg5G2LNod3HD6pM4EsGTVmMy_bdrKSAkZ64-Rdubnedn06QHg1c3cSt8GS8jj1ka_ZVcJrs7XkqWUfDjxPAczWZrDakmAhJJl7M1aUXppqdnn9uW86FWf-zTp0cR0qk0x8g10-vzRZhp1vE_Cz_OkA2EotuBzZeqO-qA38KejK9xS8bGGB33PRPdmuXkAjIuatZqCWnKu-EwEKm_WbU98F5PyJ7d5lJgOPRzazVuICzd7TW8Y31JIL_sC5DAELuvX3dV7nq1As18IM0to9Xw7iGEolp367i131tNIRVuKHDeojlMLxgnQ9QxWlGSFYPOHK6GlKX_UrNZd9nLAUenn0pZYtF-U1f3m9l8jqNl0gTTcqRTc7BUWg69vfzR2hZybIkxeDvcjXEU6ARhW9mlcSkAjRN3Ke5j_iL-EIQfNh-uLvf__Lr4vrwU51O4Ol4nKhH2fIWHG9K_FA2u9kh7Ejv13ef59G7VXuCaUwrWn_JhxG70h3ekvqNqN8pTbeji9423mXbEyC9vmlWB3ktrMdCvGrmtzMqdl9oAg15NdKikWHn4KdDxpUGapaoOG7ePWngFZUzecwZ7dCE4ja0eoxXIMvWShrPfHnQf17fe7ugvXiAYIQM9G_d-gvfuPry0J0pgf0Nf-HPjq0jY_p6gsZzXMMaFCadUDFbU7OWyWjePUvNWd-1dRgV4P08ssFVX-DZHYUtlpcrQWIgs8GYENih2ANEnhFQkhtAbkNTCAPPfX5aNAS8NuwWFHzhLMRLYqo68_RYUXlk3Cm9w9pZJVSmbaZjRPe69seBlUb_x_l_NGWK7F53g7o--vLWzBSduAzjoFOAsluTXQs-q4Ttqx29jtGLygspVqZrLqgKa--PpdDqa-DWftFuBJQs7n-l9Dd2hwtIAbZ8Qc_S_6CwsfoLShNGCgnPm5CBwX4qctfOoX2wdlYAurzU-RlTcaseekE7vFps9C521EiWcOWWBdQqX5u7UHBaU_cG5_dVZPzoPzhqvO1NvMV3NF7PVbDWZLednzt5ZLxfebLRcjueL0Wq2XM0mT2fOv5WAsTeejyYrPJ6frxbj1eT8zMFxg378YH6Oq36Ve_oPk-hbCQ)

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

See [Enable changelog.com devs to create prod db forks with a single command](https://github.com/thechangelog/changelog.com/pull/508).
