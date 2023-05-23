# Dagger Engine on Fly.io

## Deploy

Follow these steps to deploy a Dagger Engine on Fly.io:

1. Create the `fly.toml`
2. `flyctl apps create dagger-engine-2023-05-20 --org changelog`
3. `flyctl volumes create dagger_engine_2023_05_20 --size 50 --region iad`
4. `flyctl deploy --vm-size performance-4x`

## Connect

Now connect to this Dagger Engine running on Fly.io:

1. Create a Wireguard peer: `flyctl wireguard create changelog iad gerhard-2023-05-20`
2. Save it to e.g. `~/Desktop/fly.io-changelog-iad-gerhard-2023-05-20.conf`
3. **Import Tunnel(s) from File...** it in WireGuard - [install](https://www.wireguard.com/install/) if needed
4. Activate new Tunnel
5. Connect to this Dagger Engine via `_EXPERIMENTAL_DAGGER_RUNNER_HOST=tcp://dagger-engine-2023-05-20.internal:8080`

## Delete

`flyctl machine stop --select` stops the machine. 💡 There is a `restart` command.

`flyctl machine destroy --select` deletes the machine. 💡 As long as the volume
is not deleted, `flyctl deploy` will restore the machine with the same state.

Delete the volume: `flyctl volume list` && `flyctl volume destroy <VOLUME_ID>`.
💡 Even if all data gets wiped, it just means that subsequent builds will be
**slower**. After the first run, the build cache will get populated &
everything will continue being just as fast as when we had data on this volume.

## Benchmark

TL;DR `performance-4x` continues being the sweet spot.

We ran
`_EXPERIMENTAL_DAGGER_RUNNER_HOST=tcp://dagger-engine-2023-05-20.internal:8080
dagger run mage ci` multiple times - COLD (no cache) & HOT (cache) - to see the
performance gain from using more CPUs / memory. 


| VM SIZE         | COLD     | HOT      |
| ---             | ---      | ---      |
| performance-16x | `5m 1s`  | `1m 44s` |
| performance-8x  | `4m 58s` | `1m 35s` |
| performance-4x  | `5m 30s` | `1m 25s` |
| performance-2x  | `8m 2s`  | `1m 42s` |
