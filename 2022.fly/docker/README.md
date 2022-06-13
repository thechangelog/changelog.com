# Fly Docker Daemon

This is a Docker Daemon that runs on Fly.io and is used for https://github.com/thechangelog/changelog.com builds primarily.

## Install

1. Create a volume in a region of your choice: `fly volumes create data --size 20 --region iad`
1. Create a new app: `fly apps create docker-2022-06-12`
1. Deploy app: `fly deploy`

## Test

1. Create a WireGuard peer with `fly wireguard create`
1. Setup WireGuard with generated config
1. `fly ips private` to get the IP of your Daemon
1. Set the `DOCKER_HOST` env variable using that IP:
    ```
    export DOCKER_HOST=tcp://[fdaa:0:5d2:a7b:81:0:26d4:2]:2375
    ```

# Scale

1. You probably want to scale your remote Daemon: `fly scale vm dedicated-cpu-2x`

Other VM sizes available: https://fly.io/docs/about/pricing/
