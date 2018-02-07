# changelog.com [![ci.changelog.com](https://ci.changelog.com/api/v1/pipelines/changelog.com/jobs/deploy/badge)](https://ci.changelog.com/teams/main/pipelines/changelog.com/jobs/deploy) [![codecov](https://codecov.io/gh/thechangelog/changelog.com/branch/master/graph/badge.svg)](https://codecov.io/gh/thechangelog/changelog.com) [![All Contributors](https://img.shields.io/badge/all_contributors-22-orange.svg?style=flat-square)](#contributors)

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

## Can I contribute?

Absolutely! Please remember that we have a product roadmap in mind so [open an issue](https://github.com/thechangelog/changelog.com/issues) about the feature you'd like to contribute before putting the time in to code it up. We'd hate for you to waste _any_ of your time building something that may ultimately fall on the cutting room floor.

## Code of Conduct

[Contributor Code of Conduct](https://changelog.com/coc). By participating in this project you agree to abide by its terms.

## How do I run the code?

Assuming you're on macOS:

  1. `./script/setup`
  2. `mix ecto.setup`
  3. `mix phx.server`

Now visit [`localhost:4000`](http://localhost:4000) in your browser.
The database contains some seed data you can start with.

## Contributors

Thanks goes to these wonderful people ([emoji key](https://github.com/kentcdodds/all-contributors#emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
| [<img src="https://avatars3.githubusercontent.com/u/8212?v=3" width="100px;"/><br /><sub><b>Jerod Santo</b></sub>](https://jerodsanto.net)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=jerodsanto "Code") [📖](https://github.com/thechangelog/changelog.com/commits?author=jerodsanto "Documentation") [🚇](#infra-jerodsanto "Infrastructure (Hosting, Build-Tools, etc)") | [<img src="https://avatars2.githubusercontent.com/u/2933?v=3" width="100px;"/><br /><sub><b>Adam Stacoviak</b></sub>](https://changelog.com/)<br />[🎨](#design-adamstac "Design") [💻](https://github.com/thechangelog/changelog.com/commits?author=adamstac "Code") [💵](#financial-adamstac "Financial") | [<img src="https://avatars0.githubusercontent.com/u/378665?v=3" width="100px;"/><br /><sub><b>Cody Peterson</b></sub>](http://humanshapes.co)<br />[🎨](#design-codyjames "Design") [💻](https://github.com/thechangelog/changelog.com/commits?author=codyjames "Code") | [<img src="https://pbs.twimg.com/profile_images/562681393130377216/9Vyehvz8.jpeg" width="100px;"/><br /><sub><b>Jake Stutzman</b></sub>](http://elevate.co)<br />[🎨](#design-jakestutzman "Design") | [<img src="https://avatars2.githubusercontent.com/u/7838530?v=3" width="100px;"/><br /><sub><b>Tucker Cowie</b></sub>](https://github.com/TuckerCowie)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=TuckerCowie "Code") | [<img src="https://avatars2.githubusercontent.com/u/3342?v=3" width="100px;"/><br /><sub><b>Gerhard Lazu</b></sub>](https://github.com/gerhard)<br />[🚇](#infra-gerhard "Infrastructure (Hosting, Build-Tools, etc)") [💻](https://github.com/thechangelog/changelog.com/commits?author=gerhard "Code") | [<img src="https://avatars1.githubusercontent.com/u/886?v=3" width="100px;"/><br /><sub><b>Dennis Reimann</b></sub>](https://dennisreimann.de)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=dennisreimann "Code") |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| [<img src="https://avatars3.githubusercontent.com/u/635858?v=3" width="100px;"/><br /><sub><b>Xinjiang Shao</b></sub>](https://www.xinjiangshao.com)<br />[📖](https://github.com/thechangelog/changelog.com/commits?author=soleo "Documentation") [💻](https://github.com/thechangelog/changelog.com/commits?author=soleo "Code") | [<img src="https://avatars0.githubusercontent.com/u/28044?v=3" width="100px;"/><br /><sub><b>Steve Agalloco</b></sub>](http://beforeitwasround.com)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=stve "Code") | [<img src="https://avatars1.githubusercontent.com/u/898057?v=3" width="100px;"/><br /><sub><b>David Gasperoni</b></sub>](http://david.gasperoni.org)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=mcdado "Code") | [<img src="https://avatars2.githubusercontent.com/u/4566?v=3" width="100px;"/><br /><sub><b>Nathan Youngman</b></sub>](https://nathany.com)<br />[⚠️](https://github.com/thechangelog/changelog.com/commits?author=nathany "Tests") | [<img src="https://avatars3.githubusercontent.com/u/43941?v=3" width="100px;"/><br /><sub><b>Marco Vito Moscaritolo</b></sub>](http://mavimo.org)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=mavimo "Code") | [<img src="https://avatars0.githubusercontent.com/u/5904417?v=3" width="100px;"/><br /><sub><b>0x4e</b></sub>](https://github.com/fallenpeace)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=fallenpeace "Code") | [<img src="https://avatars1.githubusercontent.com/u/8217766?v=3" width="100px;"/><br /><sub><b>Juan Soto</b></sub>](https://juansoto.me)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=sotojuan "Code") |
| [<img src="https://avatars2.githubusercontent.com/u/1248581?v=3" width="100px;"/><br /><sub><b>Andrea Rossi</b></sub>](https://github.com/lucidstack)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=lucidstack "Code") | [<img src="https://avatars3.githubusercontent.com/u/51889?v=3" width="100px;"/><br /><sub><b>Tonći Galić</b></sub>](http://tuxified.com)<br />[🚇](#infra-Tuxified "Infrastructure (Hosting, Build-Tools, etc)") | [<img src="https://avatars2.githubusercontent.com/u/321306?v=3" width="100px;"/><br /><sub><b>Jearvon Dharrie</b></sub>](http://jearvondharrie.com)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=iamjarvo "Code") | [<img src="https://avatars2.githubusercontent.com/u/197567?v=3" width="100px;"/><br /><sub><b>Lee Jarvis</b></sub>](http://twitter.com/lee_jarvis)<br /> | [<img src="https://avatars0.githubusercontent.com/u/6601142?v=3" width="100px;"/><br /><sub><b>Agusti Fernandez</b></sub>](https://github.com/agustif)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=agustif "Code") | [<img src="https://avatars3.githubusercontent.com/u/1460304?v=4" width="100px;"/><br /><sub><b>Len Payne</b></sub>](https://github.com/LenPayne)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=LenPayne "Code") | [<img src="https://avatars3.githubusercontent.com/u/17198473?v=4" width="100px;"/><br /><sub><b>Jordy Zomer</b></sub>](https://github.com/JordyZomer)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=JordyZomer "Code") |
| [<img src="https://avatars2.githubusercontent.com/u/1238549?v=4" width="100px;"/><br /><sub><b>JoeBew42</b></sub>](http://joebew42.github.io/about/)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=joebew42 "Code") |
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/kentcdodds/all-contributors) specification. Contributions of any kind welcome!
