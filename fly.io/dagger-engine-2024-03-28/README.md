# Dagger Engine v0.10 on Fly.io

## Deploy

Follow these steps to deploy two Dagger Engines on Fly.io in `ord Chicago,
Illinois (US)`:

1. Create the `fly.toml`
2. `flyctl apps create dagger-engine-2024-03-28 --org changelog`
3. `flyctl volumes create dagger_engine_2024_03_28 --size 100 --region ord`
4. `flyctl deploy --vm-size performance-2x --region ord`

## Connect

> [!NOTE]
> Skip if you already have a WireGuard Tunnel configured.

Now connect to this Dagger Engine running on Fly.io:

1. Create a Wireguard peer: `flyctl wireguard create changelog lhr gerhard-2024-03-27`
2. Save it to e.g. `~/Desktop/fly.io-changelog-lhr-gerhard-2024-03-27.conf`
3. **Import Tunnel(s) from File...** it in WireGuard - [install](https://www.wireguard.com/install/) if needed
4. Activate new Tunnel
5. Connect to this Dagger Engine via:
```console
export _EXPERIMENTAL_DAGGER_RUNNER_HOST=tcp://dagger-engine-2024-03-28.internal:8080
``````

## Delete

`flyctl machine stop --select` stops the machine. 💡 There is a `restart` command.

`flyctl machine destroy --select` deletes the machine. 💡 As long as the volume
is not deleted, `flyctl deploy` will restore the machine with the same state.

Delete the volume: `flyctl volume list` && `flyctl volume destroy <VOLUME_ID>`.
💡 Even if all data gets wiped, it just means that subsequent builds will be
**slower**. After the first run, the build cache will get populated &
everything will continue being just as fast as when we had data on this volume.
