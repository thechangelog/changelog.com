# A Performance Dashboard for Postgres

This sets up [PgHero](https://github.com/ankane/pghero) (a performance
dashboard) for our Neon.tech Postgres instance.

It runs on Fly.io and is only available on our private network (requires a
running Wireguard Tunnel).

## Deploy

1. `flyctl apps create pghero-2024-03-27 --org changelog`
2. `flyctl secrets set DATABASE_URL="$(op read op://changelog/neon/url --account changelog.1password.com --cache)"`
3. `flyctl deploy --ha=false --vm-memory=512`

## Connect

> [!NOTE]
> Skip if you already have a WireGuard Tunnel configured.

Now connect to this PgHero instance running on Fly.io:

1. Create a Wireguard peer: `flyctl wireguard create changelog lhr gerhard-2024-03-27`
2. Save it to e.g. `~/Desktop/fly.io-changelog-lhr-gerhard-2024-03-27.conf`
3. **Import Tunnel(s) from File...** it in WireGuard - [install](https://www.wireguard.com/install/) if needed
4. Activate new Tunnel
5. Connect to PgHero: <http://pghero-2024-03-27.internal:8080>

## Delete

`flyctl destroy pghero-2024-03-27`

## Shout-out

- @ankane for [PgHero](https://github.com/ankane/pghero) 🦸
- @brendan-stephens for [the pairing session](https://github.com/thechangelog/changelog.com/pull/492#issuecomment-1885586669) 🍐
