[![shields.io](https://img.shields.io/badge/Last%20updated%20on-Oct.%2005%2C%202025-success?style=for-the-badge)](https://shipit.show/80)

This diagram shows the current changelog.com setup:

```mermaid
%% https://fontawesome.com/search
graph TD
    classDef link stroke:#59b287,stroke-width:3px;

    %% Secrets
    secrets(( fa:fa-key 1Password )):::link
    click secrets "https://changelog.1password.com/"
    secrets -.-> |secrets| app
    secrets -.-> |secrets| repo

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

    repo -.- |fly.io/changelog-2025-05-05| app

    registry ---> |ghcr.io/changelog/changelog-prod| app
    runner --> |flyctl deploy| app

    repo -.- |fly.io/pghero-2024-03-27| pghero

    %% PaaS - https://fly.io/dashboard/changelog
    subgraph Fly.io
        proxy{fa:fa-globe Proxy}
        proxy ==> |https| app

        pipedream[ fa:fa-bolt changelog.com cdn.changelog.com ]:::link
        click pipedream "https://changelog.com"

        app(( fab:fa-phoenix-framework IAD & EWR changelog-2025-05-05.fly.dev )):::link
        style app fill:#488969;
        click app "https://fly.io/apps/changelog-2025-05-05"

        pghero([ fa:fa-gem PgHero 2024-03-27 ]):::link
        click pghero "https://fly.io/apps/pghero-2024-03-27"
    end

    app <==> |Postgres| dbrw
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

    %% Search
    search(( fa:fa-magnifying-glass Typesense ))
    app -..-> |search| search

    %% Exceptions
    exceptions(( fa:fa-car-crash Sentry )):::link
    click exceptions "https://sentry.io/organizations/changelog-media/issues/?project=5668962"
    app -..-> |exceptions| exceptions

    subgraph AWS.S3
        logs[ fab:fa-aws changelog-logs ]
    end
    pipedream -..-> |logs| logs

    %% Object storage
    proxy ==> |https| pipedream ==> app
    subgraph Cloudflare.R2
        assets[ fab:fa-cloudflare changelog-assets changelog.place ]
        feeds[ fab:fa-cloudflare changelog-feeds feeds.changelog.place ]
    end
    pipedream ===> |https| assets & feeds

    %% Monitoring
    subgraph BetterStack
        status[ fa:fa-layer-group status.changelog.com ]:::link
        click status "https://status.changelog.com"

        monitoring(( fa:fa-table-tennis Uptime )):::link
        click monitoring "https://uptime.betterstack.com/team/133302/monitors"
        monitoring -...-> |monitors| pipedream
        monitoring -.-> |monitors| proxy
        monitoring -.-> |monitors| status
    end

    %% Observability
    observability(( fa:fa-bug Honeycomb )):::link
    click observability "https://ui.honeycomb.io/changelog/datasets/changelog_opentelemetry/home"
    app -.-> |traces| observability
    pipedream -.-> |logs| observability
```

> [!TIP]
> [Continue live editing this Mermaid diagram](https://mermaid.live/edit#pako:eNqVWAlv2zYU_iuEghYNEEm-Y7vLhq7p2mLoGtQdCjQuCkp6ljRLpEBSdZw4_32Pok4fPYwAsah3fO_6-JIHy-cBWHPryRMSKZXJueuuOFN0A5Kn4Pg8dSVQ4UdLFgqaReTj9ZIR_PgJlfIaViSJ2ZpIJfga5mfjmTeYXl6YR3sTByqaD7O750tmtNDNAnwBSppnaR6ePSMrOl9Rew1b0r9ByxsuAnJ-Pp_Ptf3KZeyvKxWytCrAfkRZCAkPnX5WqhbAl1bHCbEd-3eyK592hGbZd98LyHgL90tMFHlK0EGDPvdMUl7H6k3umUP90aoPDxiTp4MKYxXlHlER1EhbmBEpeXzsBNoEqw21IjWWiuBOW9Nht-zEfnDrlun1Y-EnYPuouy5Bkxe-ijkjNllEcUbeKrJcfjmBRtv6VTQuLexLF8uyXiV8I12Jjr7GytmmSRcrzRVPqRa_XS7r7PEEzZFrGoYgyGtOFtd_E_cUxMbELwP1Eu65KZUKBP4KYRUnIJtvTsi7aAWEMTb6tmjedqHDyBdOzPfbt11Vo3kcIheh7OLMqL9GGHKvshFVje978jlPsIAnnWrxo0Nzr_X028L7GaNC8E3xnkHijsbj3uzSXtP4HpireBb7rh4FZ9ALIEv4Vu5nBTvWTJJjgjpe-V3RTd0-JbZWO577Xau0-_1t9GTu-yAlOTNYiWa2XRG2kQYWVIoVSLJbJVssVZMNe9AbjO2e_ikZotIoS2YXvsoSu0d6yc4ED1rsInLMozAQ0ZuvEmISt2d_D1EWRiC4hjOye0N7cLkj5qhFSTeULnBwa-I2mgGVkcepCBpMe3T1VyHY5BAR320fDEWEOAVAbvTJ454EubrCGApvHeyFQJxBIICmtyXVeDxRpMtyfsCc7smpKa6tHW3YA45DLM0gZBEHFt_ZK0FT0K1H3r64RuJ-9ekDOVZmR6ctgG_HJkeqbQLaPME2TOZno-l0Npk9PyAdFGiAlmXAQ3m0r7rYTVGfVWkLISU34Rs8Ik3pyZdTQ220Tzg_aKHqQmxNgob-W1HXGy5VKABLG3hiY96W5nXvmsO9RvoHOHMU6O2gwqXl6mgCqqhHJZCUxox4gjI_wl6KU4qTdDIobaJdeLw9eAIOq5zp6FzsyP_AVxLpUqfYljxngT2dTHqj2XTiGl_IIZ6wN5QFIGIW2jLVa8nldDSZ9sezbiHQK-9_HzkOKQKkiLwbb8l35WsFO2PsINlN3rA1JbI6OLI1hoYpaggZCMmZrU8Re3VdfzB0cjJ5Jd200pfwPHBYy6M7k9No9Y3nkiUU3DAyOvLUZWy4C4Wkzdmc1KY002l6tusu35Xu92MiPyRNlFNxCruaaH_dhOHdRv8g_cXyaXZZs_bp7_XqiZcNi1db3Sah3m3Jx20GEhj2wPl5Myy2U26JWnlHquW49vDqzoes2HhK__Vz7cmnwvYFsjTCYfpOObrnNoqtYspCQWcAtwTK4ntqlqsmCykEMXVjKXNs_j_KKbkaTybIXIOKAFqBNG52LZcHHfvi08JZDJuioCt5W1Eu3cgWtepX5Esr-537ofKrpXaFmVby3nsaLdIuDnUIpebB1dPY0qfNGl9hfak7fpVQAc6HQauhi829Bu3XUi3sRqZ1b2UJNnoVjf6sAIIfGClEjKBzwtKRvFx1bleD46mx0srQO85izA526V7Qf4LCxXWhcFVs319U5bIilIRuQdih4HlWvvnJ69gIt9vwiHaXPdIaZ932SKjIFQqQziT5N9PjfnpbbfRbbvNCyfGKUKUO1ez0mD63PxwOewO31JNVp3ex6OYruq8SazXTCfk9ad2MPyVpUnSMg957EsQ36sVJrEpbvH1UJ8zLQ_KGM9hikN5xkugotjMVO1Gl2eVLfbHp3mqOvvIMWQUSSAG5xY3w7_4uT-jAlMDuxbD4Ifj2aDeT3RG0LqxQxIE1VyKHCysFgdcqPloP2sTSwr92tNM5fg2oWGv3j6iTUfaZ87RSw8YNIwszk0h8yjMMBa5jiv2f1qf61lpsmV_poAlr_mDdWfP-eOr0RqPhbNQfD3qz8XR4YW3xuDd0RsPhdDIe9Ie9_njUf7yw7guvPWc6GfWGl-NL7K3L8Xg0u7CQXbG-78w_TYr_nSAu0PvFS1xAFNqbDUaP_wM097cl)

Let's dig into how all the above pieces fit together.


## A three-tier monolith

TL;DR:
- **Front-end**
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
They are served via Pipedream, specifically https://cdn.changelog.com.

```
Pipedream (cdn.changelog.com)
↓
Cloudflare R2 (changelog.place)
````

The production instance of our application is running on Fly.io, as 2 instances
spread across 2 regions: IAD & EWR. All https://changelog.com requests are
served via Pipedream, which is Varnish HTTP Cache behind Fly.io Proxy.

```
Fly.io Proxy
↓
Pipedream (changelog.com)
↓
Application (changelog-2025-05-05.fly.dev)
```

The production database - PostgreSQL - is running on Neon.tech. It is
replicated setup, with one leader (RW) & one replica (RO). We are currently not
using the replica, and since Neon.tech scales down to 0, this doesn't cost
anything.

```
Application (changelog-2025-05-05.fly.dev)
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
  - Notifies [`#kaizen / Code
  deploys`](https://changelog.zulipchat.com/#narrow/channel/455097-kaizen/topic/Code.20deploys/with/543183853)
  channel in changelog.zulipchat.com if **CI/CD** succeeds


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

All logs from Pipedream are streamed into Honeycomb.io. This allows us to ask
unknown questions about how various HTTP clients interact with our content. It
also helps us explore how Pipedream interacts with the app.

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
5. Set `APP_INSTANCE=experimental` env var in `fly.toml`
  - Otherwise Oban and other production components will treat this app as current production
5. Set the one secret required by the app to be able to access all other secrets

        flyctl secrets set --stage \
            OP_SERVICE_ACCOUNT_TOKEN="$(op read op://changelog/op/credential --account changelog.1password.com --cache)"

6. Deploy the latest app image from <https://github.com/thechangelog/changelog.com/pkgs/container/changelog-prod>

        flyctl deploy --ha=false --image=ghcr.io/thechangelog/changelog-prod:<LATEST_IMAGE_SHA>

## How to promote a new app instance to production?

1. Update `APP_PROD_INSTANCE` in `.envrc` to match the newly created app name, e.g. `changelog-2025-05-05`

        direnv allow
        env | rg APP_PROD_INSTANCE

2. Ensure that the app is scaled across multiple regions & is resilient to a single region failure:

        just prod-region-resilient

3. Set `APP_INSTANCE=production` env var in `fly.toml`
  - Remove any env variables that should not be there (e.g. `URL_HOST`, `STATIC_URL_HOST`, etc.)

4. Update the app origin in the CDN with the new app instance URL, e.g. `https://changelog-2025-05-05.fly.dev`

5. Update the previous app instance reference everywhere in this repository - starting with the diagrams in this file.

6. Update [`APP_PROD_INSTANCE` in GitHub Actions](https://github.com/thechangelog/changelog.com/settings/variables/actions/APP_PROD_INSTANCE)

## How to branch the production db instance?

See [Enable changelog.com devs to create prod db forks with a single command](https://github.com/thechangelog/changelog.com/pull/508).
