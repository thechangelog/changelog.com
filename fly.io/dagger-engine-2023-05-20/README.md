# Dagger Engine on Fly.io

## Deploy

Follow these steps to deploy two Dagger Engines on Fly.io, the primary in `ewr
Secaucus, NJ (US)` & the secondary in `ord Chicago, Illinois (US)`:

1. Create the `fly.toml`
2. `flyctl apps create dagger-engine-2023-05-20 --org changelog`
3. `flyctl volumes create dagger_engine_2023_05_20 --size 100 --region ewr` 👈 primary region
4. `flyctl deploy --vm-size performance-4x --region ewr`
5. `flyctl machine clone --region ord <PRIMARY_MACHINE_ID>` 👈 secondary region

## Connect

Now connect to this Dagger Engine running on Fly.io:

1. Create a Wireguard peer: `flyctl wireguard create changelog iad gerhard-2023-05-20`
2. Save it to e.g. `~/Desktop/fly.io-changelog-iad-gerhard-2023-05-20.conf`
3. **Import Tunnel(s) from File...** it in WireGuard - [install](https://www.wireguard.com/install/) if needed
4. Activate new Tunnel
5. Connect to this Dagger Engine via:
```console
export _EXPERIMENTAL_DAGGER_RUNNER_HOST=tcp://dagger-engine-2023-05-20.internal:8080
``````

## Delete

`flyctl machine stop --select` stops the machine. 💡 There is a `restart` command.

`flyctl machine destroy --select` deletes the machine. 💡 As long as the volume
is not deleted, `flyctl deploy` will restore the machine with the same state.

Delete the volume: `flyctl volume list` && `flyctl volume destroy <VOLUME_ID>`.
💡 Even if all data gets wiped, it just means that subsequent builds will be
**slower**. After the first run, the build cache will get populated &
everything will continue being just as fast as when we had data on this volume.

## Benchmark on `2023.07.02`

TL;DR `performance-4x` instance sizes continues being the sweet spot for us.

We ran the command below multiple times - COLD (no cache) & HOT (cache) - to
see the performance gain from using more CPUs / memory. 💡 Once images get
pulled, ops cached & volumes filled with data, there is no measurable advantage
for our pipeline go beyond `performance-4x`.

| INSTANCE SIZE       | COLD               | HOT                |
| ---                 | ---                | ---                |
| `performance-16x`   | `4m 54s` - `1.63x` | `1m 42s` - `1.00x` |
| `performance-8x`    | `4m 52s` - `1.65x` | `1m 35s` - `1.07x` |
| 👉 `performance-4x` | `4m 59s` - `1.61x` | `1m 35s` - `1.07x` |
| `performance-2x`    | `8m 02s` - `1.00x` | `1m 42s` - `1.00x` |

```console
export _EXPERIMENTAL_DAGGER_RUNNER_HOST=tcp://dagger-engine-2023-05-20.internal:8080
dagger run mage ci
```
