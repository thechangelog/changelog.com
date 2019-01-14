# changelog.com [![CircleCI](https://circleci.com/gh/thechangelog/changelog.com.svg?style=svg)](https://circleci.com/gh/thechangelog/changelog.com) [![All Contributors](https://img.shields.io/badge/all_contributors-27-orange.svg?style=flat-square)](#contributors)

[Read the announcement post!](https://changelog.com/posts/changelog-is-open-source)

## What is this?

This is the CMS behind [changelog.com](https://changelog.com). It's an [Elixir](http://elixir-lang.org) application built on the [Phoenix](http://www.phoenixframework.org) web framework, [PostgreSQL](https://www.postgresql.org), and [many](https://github.com/thechangelog/changelog.com/blob/master/mix.exs#L33) [other](https://github.com/thechangelog/changelog.com/blob/master/assets/package.json) great open source efforts.

## Why is it open source?

A few reasons:

1. We _love_ open source. Our careers (and livelihoods) wouldn't be possible without open source. Keeping it closed just feels _wrong_.
2. Phoenix is really great, but it's young enough in its lifecycle that there aren't _too many_ in-production, open source sites for people to refer to as examples or inspiration. We want to throw our hat into that ring and hopefully others will follow.
3. Changelog is a community of hackers. We know open sourcing the website will lead to good things from y'all (such as bug reports, feature requests, and pull requests).

## Should I fork this and use it as a platform?

Probably not. We won't stop you from doing it, but we don't advise it. _This is not a general purpose podcasting CMS_. It is a CMS that is specific to Changelog and our needs. From the design and layout to the data structures and file hosting, we built this for us. An example of just how custom it is — [we literally have our podcast slugs hardcoded in areas of the code](https://github.com/thechangelog/changelog.com/blob/master/web/controllers/slack_controller.ex#L22). Yuck.

## What is it good for?

If you're building a web application with Phoenix (or aspire to), this is a great place to poke around and see what one looks like when it's all wired together. It's not perfect by any means, but it works. And that's something. We've also been told that [it is ridiculously fast](https://twitter.com/augiedb/status/788344626663096320).

If you have questions about any of the code, holler [@Changelog](https://twitter.com/changelog). Better yet, [join the community](https://changelog.com/community) where we have in-depth discussions about software development, industry trends, and everything else under the sun.

## How can I contribute?

Assuming that you have Docker running locally and docker-compose available, all you have to do is run `rm -fr deps && docker-compose up` in your terminal.
When you run this command for the first time, it will take around 7 minutes to pull all Docker images, build the app image and start all containers.
Depending on your internet connection and CPUs used for compiling various artefacts, this can easily take 30 minutes or more.
Next time you run this command, since all Docker images will be cached, you can expect all containers to be up and running within 30 seconds.

When all containers are up and running, you should see the following output in your terminal session:

```
Starting changelogcom_db_1    ... done
Starting changelogcom_proxy_1 ... done
Recreating changelogcom_app_1 ... done
Attaching to changelogcom_db_1, changelogcom_proxy_1, changelogcom_app_1
...
db_1     | LOG:  autovacuum launcher started
db_1     | LOG:  database system is ready to accept connections
...
proxy_1  | dockergen.1 | 2018/07/20 16:01:05 Generated '/etc/nginx/conf.d/default.conf' from 3 containers
...
app_1    | [info] Running ChangelogWeb.Endpoint with Cowboy using http://0.0.0.0:4000
app_1    | yarn run v1.6.0
app_1    | warning package.json: No license field
app_1    | $ webpack --mode=development --watch-stdin --color
app_1    |
app_1    | Webpack is watching the files…
...
```

You can access a dev copy of changelog.com locally, at http://localhost:4000

When you want to stop all Docker containers required to run a dev copy of changelog.com locally, press `CTRL` key and `c` at the same time (`Ctrl+C`).

If any app dependencies have changed, or the cached Docker app image has diverged from the source code, you will need to re-build it by running `docker-compose build` before you can run `docker-compose up`.

If you are running on macOS or Linux, all the above commands are available as make targets (e.g. `build` &amp; `contrib`).
Learn about all available commands by running `make` in your terminal.

By default, macOS ships with GNU Make v3.81. Our Makefile requires GNU Make >= 4 which can be installed via `brew install make`.
By default, the make version that brew installs is invoked via `gmake`. For more info, see `brew info make`.

Please remember that we have a product roadmap in mind so [open an issue](https://github.com/thechangelog/changelog.com/issues) about the feature you'd like to contribute before putting the time in to code it up. We'd hate for you to waste _any_ of your time building something that may ultimately fall on the cutting room floor.

### Why is Docker for Mac slow?

If you are running changelog.com locally via `docker-compose up` on a Mac, you might notice that pages take ~1.5s to load:

```
while true
do
  curl --silent --output /dev/null \
  --write-out '%{http_code} connect:%{time_connect} prepare:%{time_pretransfer} transfer:%{time_starttransfer} total:%{time_total}\n' \
  http://localhost:4000/
done
200 connect:0.004815 prepare:0.004849 transfer:1.488685 total:1.488921
200 connect:0.005061 prepare:0.005089 transfer:1.627873 total:1.628171
200 connect:0.005176 prepare:0.005211 transfer:1.566022 total:1.566123
^C
```

This is down to [Docker for Mac networking integration with the OS](https://github.com/docker/for-mac/issues/2814), which is still the case in [18.09.0-ce-beta1](https://github.com/docker/docker-ce/releases/tag/v18.09.0-ce-beta1).

The same test on Arch Linux 2018.10.1 running Docker 18.06.1-ce results in ~0.08s response times (20x faster):

```
200 connect:0.000569 prepare:0.000602 transfer:0.080425 total:0.080501
200 connect:0.000614 prepare:0.000650 transfer:0.083291 total:0.083407
200 connect:0.000611 prepare:0.000643 transfer:0.081731 total:0.081853
^C
```

Our thinking is: [make it work first, make it right next &amp; make it fast last](http://wiki.c2.com/?MakeItWorkMakeItRightMakeItFast).
Contributions to make changelog.com dev on Docker for Mac fast are welcome!
It would be especially interesting to know if [ipvlan on macOS](https://github.com/docker/cli/blob/master/experimental/vlan-networks.md) makes things better.

## Code of Conduct

[Contributor Code of Conduct](https://changelog.com/coc). By participating in this project you agree to abide by its terms.

## Contributors

Thanks goes to these wonderful people ([emoji key](https://github.com/kentcdodds/all-contributors#emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
| [<img src="https://avatars3.githubusercontent.com/u/8212?v=3" width="100px;"/><br /><sub><b>Jerod Santo</b></sub>](https://jerodsanto.net)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=jerodsanto "Code") [📖](https://github.com/thechangelog/changelog.com/commits?author=jerodsanto "Documentation") [🚇](#infra-jerodsanto "Infrastructure (Hosting, Build-Tools, etc)") | [<img src="https://avatars2.githubusercontent.com/u/2933?v=3" width="100px;"/><br /><sub><b>Adam Stacoviak</b></sub>](https://changelog.com/)<br />[🎨](#design-adamstac "Design") [💻](https://github.com/thechangelog/changelog.com/commits?author=adamstac "Code") [💵](#financial-adamstac "Financial") | [<img src="https://avatars0.githubusercontent.com/u/378665?v=3" width="100px;"/><br /><sub><b>Cody Peterson</b></sub>](http://humanshapes.co)<br />[🎨](#design-codyjames "Design") [💻](https://github.com/thechangelog/changelog.com/commits?author=codyjames "Code") | [<img src="https://pbs.twimg.com/profile_images/1053277843176677379/7y-9aoX5_400x400.jpg" width="100px;"/><br /><sub><b>Jake Stutzman</b></sub>](http://elevate.co)<br />[🎨](#design-jakestutzman "Design") | [<img src="https://avatars2.githubusercontent.com/u/7838530?v=3" width="100px;"/><br /><sub><b>Tucker Cowie</b></sub>](https://github.com/TuckerCowie)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=TuckerCowie "Code") | [<img src="https://avatars2.githubusercontent.com/u/3342?v=3" width="100px;"/><br /><sub><b>Gerhard Lazu</b></sub>](https://github.com/gerhard)<br />[🚇](#infra-gerhard "Infrastructure (Hosting, Build-Tools, etc)") [💻](https://github.com/thechangelog/changelog.com/commits?author=gerhard "Code") |
| :---: | :---: | :---: | :---: | :---: | :---: |
| [<img src="https://avatars3.githubusercontent.com/u/635858?v=3" width="100px;"/><br /><sub><b>Xinjiang Shao</b></sub>](https://www.xinjiangshao.com)<br />[📖](https://github.com/thechangelog/changelog.com/commits?author=soleo "Documentation") [💻](https://github.com/thechangelog/changelog.com/commits?author=soleo "Code") | [<img src="https://avatars0.githubusercontent.com/u/28044?v=3" width="100px;"/><br /><sub><b>Steve Agalloco</b></sub>](http://beforeitwasround.com)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=stve "Code") | [<img src="https://avatars1.githubusercontent.com/u/898057?v=3" width="100px;"/><br /><sub><b>David Gasperoni</b></sub>](http://david.gasperoni.org)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=mcdado "Code") | [<img src="https://avatars2.githubusercontent.com/u/4566?v=3" width="100px;"/><br /><sub><b>Nathan Youngman</b></sub>](https://nathany.com)<br />[⚠️](https://github.com/thechangelog/changelog.com/commits?author=nathany "Tests") | [<img src="https://avatars3.githubusercontent.com/u/43941?v=3" width="100px;"/><br /><sub><b>Marco Vito Moscaritolo</b></sub>](http://mavimo.org)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=mavimo "Code") | [<img src="https://avatars0.githubusercontent.com/u/5904417?v=3" width="100px;"/><br /><sub><b>0x4e</b></sub>](https://github.com/fallenpeace)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=fallenpeace "Code") |
| [<img src="https://avatars2.githubusercontent.com/u/1248581?v=3" width="100px;"/><br /><sub><b>Andrea Rossi</b></sub>](https://github.com/lucidstack)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=lucidstack "Code") | [<img src="https://avatars3.githubusercontent.com/u/51889?v=3" width="100px;"/><br /><sub><b>Tonći Galić</b></sub>](http://tuxified.com)<br />[🚇](#infra-Tuxified "Infrastructure (Hosting, Build-Tools, etc)") | [<img src="https://avatars2.githubusercontent.com/u/321306?v=3" width="100px;"/><br /><sub><b>Jearvon Dharrie</b></sub>](http://jearvondharrie.com)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=iamjarvo "Code") | [<img src="https://avatars2.githubusercontent.com/u/197567?v=3" width="100px;"/><br /><sub><b>Lee Jarvis</b></sub>](http://twitter.com/lee_jarvis)<br />&nbsp; | [<img src="https://avatars0.githubusercontent.com/u/6601142?v=3" width="100px;"/><br /><sub><b>Agusti Fernandez</b></sub>](https://github.com/agustif)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=agustif "Code") | [<img src="https://avatars3.githubusercontent.com/u/1460304?v=4" width="100px;"/><br /><sub><b>Len Payne</b></sub>](https://github.com/LenPayne)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=LenPayne "Code") |
| [<img src="https://avatars2.githubusercontent.com/u/1238549?v=4" width="100px;"/><br /><sub><b>JoeBew42</b></sub>](http://joebew42.github.io/about/)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=joebew42 "Code") | [<img src="https://avatars3.githubusercontent.com/u/6545494?v=4" width="100px;"/><br /><sub><b>Griffin Byatt</b></sub>](http://griffinbyatt.com)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=GriffinMB "Code") | [<img src="https://avatars1.githubusercontent.com/u/13277581?v=4" width="100px;"/><br /><sub><b>Ridge Frederick</b></sub>](https://github.com/r-frederick)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=r-frederick "Code") [🐛](https://github.com/thechangelog/changelog.com/issues?q=author%3Ar-frederick "Bug reports") | [<img src="https://avatars0.githubusercontent.com/u/11322155?v=4" width="100px;"/><br /><sub><b>Horst Rutter</b></sub>](https://keybase.io/hhrutter)<br />[🐛](https://github.com/thechangelog/changelog.com/issues?q=author%3Ahhrutter "Bug reports") | [<img src="https://avatars2.githubusercontent.com/u/813219?v=4" width="100px;"/><br /><sub><b>Nick Janetakis</b></sub>](https://nickjanetakis.com)<br />[🐛](https://github.com/thechangelog/changelog.com/issues?q=author%3Anickjj "Bug reports") [💻](https://github.com/thechangelog/changelog.com/commits?author=nickjj "Code") | [<img src="https://avatars0.githubusercontent.com/u/12587988?v=4" width="100px;"/><br /><sub><b>Ryan Will</b></sub>](https://ryanwilldev.com)<br />[🐛](https://github.com/thechangelog/changelog.com/issues?q=author%3ARyanWillDev "Bug reports") [💻](https://github.com/thechangelog/changelog.com/commits?author=RyanWillDev "Code") |
| [<img src="https://avatars1.githubusercontent.com/u/886?v=3" width="100px;"/><br /><sub><b>Dennis Reimann</b></sub>](https://dennisreimann.de)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=dennisreimann "Code") |  [<img src="https://avatars1.githubusercontent.com/u/8217766?v=3" width="100px;"/><br /><sub><b>Juan Soto</b></sub>](https://juansoto.me)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=sotojuan "Code") |  [<img src="https://avatars3.githubusercontent.com/u/17198473?v=4" width="100px;"/><br /><sub><b>Jordy Zomer</b></sub>](https://github.com/JordyZomer)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=JordyZomer "Code") | | | |
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/kentcdodds/all-contributors) specification. Contributions of any kind welcome!
