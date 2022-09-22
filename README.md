# changelog.com [![All Contributors](https://img.shields.io/badge/all_contributors-31-orange.svg?style=flat-square)](#contributors)

[Read the announcement post!](https://changelog.com/posts/changelog-is-open-source)

## What is this?

This is the CMS behind [changelog.com](https://changelog.com). It's an [Elixir](http://elixir-lang.org) application built with the [Phoenix](http://www.phoenixframework.org) web framework, [PostgreSQL](https://www.postgresql.org), and [many](https://github.com/thechangelog/changelog.com/blob/master/mix.exs#L33) [other](https://github.com/thechangelog/changelog.com/blob/master/assets/package.json) great open source efforts.

## Dependencies

- Elixir 1.13
- Erlang/OTP 24

## Why is it open source?

A few reasons:

1. We _love_ open source. Our careers (and livelihoods) wouldn't be possible without open source. Keeping it closed just feels _wrong_.
2. Phoenix is really great, but it's young enough in its lifecycle that there aren't _too many_ in-production, open source sites for people to refer to as examples or inspiration. We want to throw our hat into that ring and hopefully others will follow.
3. Changelog is a community of hackers. We know open sourcing the website will lead to good things from y'all (such as bug reports, feature requests, and pull requests).

## Should I fork this and use it as a platform?

Probably not. We won't stop you from doing it, but we don't advise it. _This is not a general purpose podcasting CMS_. It is a CMS that is specific to Changelog and our needs. From the design and layout to the data structures and file hosting, we built this for us. An example of just how custom it is — [we literally have our podcast names hardcoded in areas of the code](https://github.com/thechangelog/changelog.com/blob/14e2f412400df7648be2b77ec88b393e80d81eae/lib/changelog/buffer/buffer.ex#L7-L12). Yuck.

## What is it good for?

If you're building a web application with Phoenix (or aspire to), this is a great place to poke around and see what one looks like when it's all wired together. It's not perfect by any means, but it works. And that's something. We've also been told that [it is ridiculously fast](https://twitter.com/augiedb/status/788344626663096320).

If you have questions about any of the code, holler [@Changelog](https://twitter.com/changelog). Better yet, [join the community](https://changelog.com/community) where we have in-depth discussions about software development, industry trends, and everything else under the sun.

## How can I contribute?

Assuming that you have [Docker](https://docs.docker.com/install/) running locally and `docker-compose` available, all that you have to do is run `./start_dev_stack up` in your terminal.

When you run this command for the first time, it will take around 7 minutes to pull all Docker images, build the app image and start the app and db containers.
Depending on your internet connection and CPUs used for compiling various artefacts, this can easily take 30 minutes or more.
Next time you run this command, since all Docker images will be cached, you can expect all containers to be up and running within 30 seconds.

When all containers are up and running, you should see the following output in your terminal session:

```
Starting dev_docker_postgres_1   ... done
Starting dev_docker_prometheus_1 ... done
Starting dev_docker_grafana_1    ... done
Starting dev_docker_changelog_app_1 ... done
Attaching to dev_docker_prometheus_1, dev_docker_postgres_1, dev_docker_grafana_1, dev_docker_changelog_app_1
...
grafana_1        | t=2021-02-03T20:53:58+0000 lvl=info msg="Starting Grafana" logger=server version=7.1.3 commit=5723d951af branch=HEAD compiled=2020-08-06T08:44:32+0000
grafana_1        | t=2021-02-03T20:53:58+0000 lvl=info msg="Config loaded from" logger=settings file=/usr/share/grafana/conf/defaults.ini
grafana_1        | t=2021-02-03T20:53:58+0000 lvl=info msg="Config loaded from" logger=settings file=/etc/grafana/grafana.ini
...
prometheus_1     | level=info ts=2021-02-03T20:53:58.108Z caller=main.go:308 msg="No time or size retention was set so using the default time retention" duration=15d
prometheus_1     | level=info ts=2021-02-03T20:53:58.109Z caller=main.go:343 msg="Starting Prometheus" version="(version=2.20.1, branch=HEAD, revision=983ebb4a513302315a8117932ab832815f85e3d2)"
...
postgres_1         | LOG:  autovacuum launcher started
postgres_1         | LOG:  database system is ready to accept connections
...
changelog_app_1    | [info] Running ChangelogWeb.Endpoint with Cowboy using http://0.0.0.0:4000
changelog_app_1    | yarn run v1.6.0
changelog_app_1    | warning package.json: No license field
changelog_app_1    | $ webpack --mode=development --watch-stdin --color
changelog_app_1    |
changelog_app_1    | Webpack is watching the files…
...
```

You can now access a dev copy of changelog.com locally, at `http://localhost:4000` or at `https://localhost:4001` if you
would like to access the HTTPS version.

If you are using Google Chrome as your browser and notice `ERR_CERT_AUTHORITY_INVALID` errors in your console, you will need to enable Chrome's `allow-insecure-localhost` flag, which you can do by opening `chrome://flags/#allow-insecure-localhost`. There will be a log in your terminal warning about this, but it quickly gets hidden by other logs:

```
dev_docker-changelog_app-1  | * creating priv/cert/selfsigned_key.pem
...
dev_docker-changelog_app-1  | NOTE: when using Google Chrome, open chrome://flags/#allow-insecure-localhost
dev_docker-changelog_app-1  | to enable the use of self-signed certificates on `localhost`.
```

When you want to stop all Docker containers, press both `CTRL` and `c` keys at the same time (`Ctrl+C`).

Please remember that we have a product roadmap in mind so [open an issue](https://github.com/thechangelog/changelog.com/issues) about the feature you'd like to contribute before putting the time in to code it up. We'd hate for you to waste _any_ of your time building something that may ultimately fall on the cutting room floor.

### How do I import a db backup locally?

First ensure that:

* the local changelog containers are stopped, i.e. `docker-compose down`
* you have an unarchived db backup file in the `priv/db` directory, e.g. `./priv/db/changelog-201910-2020-01-16T19.36.05Z`

Next, run the following commands:

```sh
docker-compose up db
# Run in a separate tab/window
docker-compose exec --user postgres db dropdb changelog_dev
docker-compose exec --user postgres db createdb changelog_dev
docker-compose exec --user postgres db psql --file=/app/priv/db/changelog-201910-2020-01-16T19.36.05Z changelog_dev
```

Finally, stop the db container by pressing both `CTRL` and `c` keys and the same time in the window/tab that you have `docker-compose up db` running.

You can now start the app normally, all changelog.com content at the time the db backup was taken will be available locally.

### How to upgrade Elixir?

1. Pick an image from [hexpm/elixir](https://hub.docker.com/r/hexpm/elixir/tags?page=1&ordering=last_updated&name=ubuntu-jammy)
1. Update `docker/Dockerfile.runtime` to use an image from the URL above
1. Run `make runtime-image` to publish the new container image
1. Update `docker/Dockerfile.production` to the exact runtime version that was published in the previous step
1. Update `2021/dagger/prod_image/main.cue` to the exact runtime version used above
1. Update `dev_docker/changelog.yml` to the exact runtime version used above
1. Update the Elixir version in `README.md` & `mix.exs`
1. Commit and push everything, then wait for the pipeline to deploy everything into production

You may want to test everything locally by running `make ship-it` from within the `2021` dir. This makes it easy to debug any potential issues locally.

### How to build a new container image using Docker Engine running on Fly.io?

Ensure that you have a [Fly.io Wireguard Tunnel configured locally](https://fly.io/docs/reference/private-networking/#creating-your-tunnel-configuration).
You may also need to [install `flyctl`](https://fly.io/docs/hands-on/install-flyctl/).

Given an active Fly.io Wireguard tunnel:

1. Check that the Wireguard tunnel works:
```
dig +noall +answer _apps.internal txt
_apps.internal.		5	IN	TXT	"changelog-2022-03-13,docker-2022-06-13,old-flower-9005,postgres-2022-03-12"
```
1. Configure `docker` CLI to use Docker Engine running on Fly.io:
```
export DOCKER_HOST=tcp://[fdaa:0:4556:a7b:21e0:1:1f9d:2]:2375
```
1. Check that `docker` CLI can connect to the remote Docker Engine:
```
docker info
...
Server:
 Containers: 1
  Running: 1
  Paused: 0
  Stopped: 0
 Server Version: 20.10.17
...
```

Any `docker` commands will now run against this remote Docker Engine now, including `make runtime-image`.

## Code of Conduct

[Contributor Code of Conduct](https://changelog.com/coc). By participating in this project you agree to abide by its terms.

## Contributors

Thanks goes to these wonderful people ([emoji key](https://github.com/kentcdodds/all-contributors#emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://jerodsanto.net"><img src="https://avatars3.githubusercontent.com/u/8212?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Jerod Santo</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=jerodsanto" title="Code">💻</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=jerodsanto" title="Documentation">📖</a> <a href="#infra-jerodsanto" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
    <td align="center"><a href="https://changelog.com/"><img src="https://avatars2.githubusercontent.com/u/2933?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Adam Stacoviak</b></sub></a><br /><a href="#design-adamstac" title="Design">🎨</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=adamstac" title="Code">💻</a> <a href="#financial-adamstac" title="Financial">💵</a></td>
    <td align="center"><a href="http://humanshapes.co"><img src="https://avatars0.githubusercontent.com/u/378665?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Cody Peterson</b></sub></a><br /><a href="#design-codyjames" title="Design">🎨</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=codyjames" title="Code">💻</a></td>
    <td align="center"><a href="http://elevate.co"><img src="https://pbs.twimg.com/profile_images/1478390251617935370/m37j1lyg_400x400.jpg" width="100px;" alt=""/><br /><sub><b>Jake Stutzman</b></sub></a><br /><a href="#design-jakestutzman" title="Design">🎨</a></td>
    <td align="center"><a href="https://github.com/TuckerCowie"><img src="https://avatars2.githubusercontent.com/u/7838530?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Tucker Cowie</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=TuckerCowie" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/gerhard"><img src="https://avatars2.githubusercontent.com/u/3342?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Gerhard Lazu</b></sub></a><br /><a href="#infra-gerhard" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=gerhard" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://www.xinjiangshao.com"><img src="https://avatars3.githubusercontent.com/u/635858?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Xinjiang Shao</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=soleo" title="Documentation">📖</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=soleo" title="Code">💻</a></td>
    <td align="center"><a href="http://beforeitwasround.com"><img src="https://avatars0.githubusercontent.com/u/28044?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Steve Agalloco</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=stve" title="Code">💻</a></td>
    <td align="center"><a href="http://david.gasperoni.org"><img src="https://avatars1.githubusercontent.com/u/898057?v=3?s=100" width="100px;" alt=""/><br /><sub><b>David Gasperoni</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=mcdado" title="Code">💻</a></td>
    <td align="center"><a href="https://nathany.com"><img src="https://avatars2.githubusercontent.com/u/4566?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Nathan Youngman</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=nathany" title="Tests">⚠️</a></td>
    <td align="center"><a href="http://mavimo.org"><img src="https://avatars3.githubusercontent.com/u/43941?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Marco Vito Moscaritolo</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=mavimo" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/fallenpeace"><img src="https://avatars0.githubusercontent.com/u/5904417?v=3?s=100" width="100px;" alt=""/><br /><sub><b>0x4e</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=fallenpeace" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/lucidstack"><img src="https://avatars2.githubusercontent.com/u/1248581?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Andrea Rossi</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=lucidstack" title="Code">💻</a></td>
    <td align="center"><a href="http://tuxified.com"><img src="https://avatars3.githubusercontent.com/u/51889?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Tonći Galić</b></sub></a><br /><a href="#infra-Tuxified" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
    <td align="center"><a href="http://jearvondharrie.com"><img src="https://avatars2.githubusercontent.com/u/321306?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Jearvon Dharrie</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=iamjarvo" title="Code">💻</a></td>
    <td align="center"><a href="http://twitter.com/lee_jarvis"><img src="https://avatars2.githubusercontent.com/u/197567?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Lee Jarvis</b></sub></a><br /></td>
    <td align="center"><a href="https://github.com/agustif"><img src="https://avatars0.githubusercontent.com/u/6601142?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Agusti Fernandez</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=agustif" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/LenPayne"><img src="https://avatars3.githubusercontent.com/u/1460304?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Len Payne</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=LenPayne" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="http://joebew42.github.io/about/"><img src="https://avatars2.githubusercontent.com/u/1238549?v=4?s=100" width="100px;" alt=""/><br /><sub><b>JoeBew42</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=joebew42" title="Code">💻</a></td>
    <td align="center"><a href="http://griffinbyatt.com"><img src="https://avatars3.githubusercontent.com/u/6545494?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Griffin Byatt</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=GriffinMB" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/r-frederick"><img src="https://avatars1.githubusercontent.com/u/13277581?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ridge Frederick</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=r-frederick" title="Code">💻</a> <a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Ar-frederick" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://keybase.io/hhrutter"><img src="https://avatars0.githubusercontent.com/u/11322155?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Horst Rutter</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Ahhrutter" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://nickjanetakis.com"><img src="https://avatars2.githubusercontent.com/u/813219?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nick Janetakis</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Anickjj" title="Bug reports">🐛</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=nickjj" title="Code">💻</a></td>
    <td align="center"><a href="https://ryanwilldev.com"><img src="https://avatars0.githubusercontent.com/u/12587988?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ryan Will</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3ARyanWillDev" title="Bug reports">🐛</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=RyanWillDev" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://dennisreimann.de"><img src="https://avatars1.githubusercontent.com/u/886?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Dennis Reimann</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=dennisreimann" title="Code">💻</a></td>
    <td align="center"><a href="https://juansoto.me"><img src="https://avatars1.githubusercontent.com/u/8217766?v=3?s=100" width="100px;" alt=""/><br /><sub><b>Juan Soto</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=sotojuan" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/JordyZomer"><img src="https://avatars3.githubusercontent.com/u/17198473?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jordy Zomer</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=JordyZomer" title="Code">💻</a></td>
    <td align="center"><a href="https://zendev.com"><img src="https://avatars0.githubusercontent.com/u/44007?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Kevin Ball</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=kball" title="Code">💻</a></td>
    <td align="center"><a href="http://matryer.com"><img src="https://avatars3.githubusercontent.com/u/101659?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mat Ryer</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=matryer" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/yanokwa"><img src="https://avatars3.githubusercontent.com/u/32369?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Yaw Anokwa</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=yanokwa" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="http://choly.ca"><img src="https://avatars1.githubusercontent.com/u/943597?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ilia Choly</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=icholy" title="Code">💻</a></td>
    <td align="center"><a href="http://wojtekmach.pl"><img src="https://avatars0.githubusercontent.com/u/76071?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Wojtek Mach</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=wojtekmach" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/type1fool"><img src="https://avatars3.githubusercontent.com/u/13895134?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Owen Bickford</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=type1fool" title="Code">💻</a> <a href="#blog-type1fool" title="Blogposts">📝</a></td>
    <td align="center"><a href="http://underjord.io"><img src="https://avatars1.githubusercontent.com/u/1971237?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Lars Wikman</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=lawik" title="Code">💻</a></td>
    <td align="center"><a href="https://marceloandrader.github.io/"><img src="https://avatars0.githubusercontent.com/u/57552?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Marcelo Andrade</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=marceloandrader" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/axelson"><img src="https://avatars1.githubusercontent.com/u/9973?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jason Axelson</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=axelson" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://akoutmos.com/"><img src="https://avatars0.githubusercontent.com/u/4753634?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Alexander Koutmos</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=akoutmos" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/d-m-u"><img src="https://avatars.githubusercontent.com/u/16326669?v=4?s=100" width="100px;" alt=""/><br /><sub><b>d-m-u</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Ad-m-u" title="Bug reports">🐛</a></td>
    <td align="center"><a href="http://sorentwo.com"><img src="https://avatars.githubusercontent.com/u/270831?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Parker Selbert</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=sorentwo" title="Code">💻</a></td>
    <td align="center"><a href="http://hailelagi.com"><img src="https://avatars.githubusercontent.com/u/52631736?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Haile Lagi</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=hailelagi" title="Code">💻</a></td>
    <td align="center"><a href="http://nezteb.net"><img src="https://avatars.githubusercontent.com/u/3588798?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Noah</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=Nezteb" title="Documentation">📖</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/kentcdodds/all-contributors) specification. Contributions of any kind welcome!
