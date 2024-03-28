This is a collection of functions that makes it easy to work with the app.

These are currently intended for changelog.com core devs. In the future, we may
expand the scope to contributors too.

## Pre-requisities

- [Dagger v0.10.3](https://docs.dagger.io/install/)
- A container runtime - [Docker](https://docs.docker.com/engine/install/) is the most straightforward one
    - If you have a [Fly.io Wireguard
      Tunnel](https://fly.io/docs/networking/private-networking/) running, then
      running `source envrc` will take care of this

## What functions are available?

> [!TIP]
> Run `dagger functions` to see what is available.

### How can I connect my dev app to a fork of the production db?

1. Ensure that you have a [Neon.tech API Key](https://neon.tech/docs/manage/api-keys)
2. Set the `NEON_API_KEY` environment variable value to your Neon.tech API Key
3. Run the following command: `dagger call db-branch --neon-api-key=env:NEON_API_KEY`
    - 💡 If you want to set a specific branch name, use the `--branch` flag
4. Follow the instructions in the command output (sets a few environment variables)
5. Start the app how you normally would (e.g. `mix phx.server`)

## What functions are we missing?

If there is a function that you are missing, [open a new GitHub
issue](https://github.com/thechangelog/changelog.com/issues/new) & cc
`@gerhard`.
