# changelog.com [![ci.changelog.com](https://ci.changelog.com/api/v1/pipelines/changelog.com/jobs/deploy/badge)](https://ci.changelog.com/teams/main/pipelines/changelog.com/jobs/deploy) [![codecov](https://codecov.io/gh/thechangelog/changelog.com/branch/master/graph/badge.svg)](https://codecov.io/gh/thechangelog/changelog.com) [![All Contributors](https://img.shields.io/badge/all_contributors-19-orange.svg?style=flat-square)](#contributors)

[Read the announcement post!](https://changelog.com/posts/changelog-is-open-source)

## What is this?

This is the CMS behind [changelog.com](https://changelog.com). It's an [Elixir](http://elixir-lang.org) application built on the [Phoenix](http://www.phoenixframework.org) web framework, [PostgreSQL](https://www.postgresql.org), and [many](https://github.com/thechangelog/changelog.com/blob/master/mix.exs#L33) [other](https://github.com/thechangelog/changelog.com/blob/master/package.json) great open source efforts.

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

## How do I run the code?

Assuming you're on macOS:

  1. `./script/setup`
  2. `mix ecto.setup`
  3. `mix phoenix.server`

Now visit [`localhost:4000`](http://localhost:4000) in your browser.
The database contains some seed data you can start with.

## Contributors

Thanks goes to these wonderful people ([emoji key](https://github.com/kentcdodds/all-contributors#emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
| [<img src="https://avatars3.githubusercontent.com/u/8212?v=3" width="100px;"/><br /><sub>Jerod Santo</sub>](https://jerodsanto.net)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=jerodsanto) [📖](https://github.com/thechangelog/changelog.com/commits?author=jerodsanto) 🚇 | [<img src="https://avatars2.githubusercontent.com/u/2933?v=3" width="100px;"/><br /><sub>Adam Stacoviak</sub>](https://changelog.com/)<br />🎨 [💻](https://github.com/thechangelog/changelog.com/commits?author=adamstac) 💵 | [<img src="https://avatars0.githubusercontent.com/u/378665?v=3" width="100px;"/><br /><sub>Cody Peterson</sub>](http://humanshapes.co)<br />🎨 [💻](https://github.com/thechangelog/changelog.com/commits?author=codyjames) | [<img src="https://pbs.twimg.com/profile_images/562681393130377216/9Vyehvz8.jpeg" width="100px;"/><br /><sub>Jake Stutzman</sub>](http://elevate.co)<br />🎨 | [<img src="https://avatars2.githubusercontent.com/u/7838530?v=3" width="100px;"/><br /><sub>Tucker Cowie</sub>](https://github.com/TuckerCowie)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=TuckerCowie) | [<img src="https://avatars2.githubusercontent.com/u/3342?v=3" width="100px;"/><br /><sub>Gerhard Lazu</sub>](https://github.com/gerhard)<br />🚇 [💻](https://github.com/thechangelog/changelog.com/commits?author=gerhard) | [<img src="https://avatars1.githubusercontent.com/u/886?v=3" width="100px;"/><br /><sub>Dennis Reimann</sub>](https://dennisreimann.de)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=dennisreimann) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| [<img src="https://avatars3.githubusercontent.com/u/635858?v=3" width="100px;"/><br /><sub>Xinjiang Shao</sub>](https://www.xinjiangshao.com)<br />[📖](https://github.com/thechangelog/changelog.com/commits?author=soleo) [💻](https://github.com/thechangelog/changelog.com/commits?author=soleo) | [<img src="https://avatars0.githubusercontent.com/u/28044?v=3" width="100px;"/><br /><sub>Steve Agalloco</sub>](http://beforeitwasround.com)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=stve) | [<img src="https://avatars1.githubusercontent.com/u/898057?v=3" width="100px;"/><br /><sub>David Gasperoni</sub>](http://david.gasperoni.org)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=mcdado) | [<img src="https://avatars2.githubusercontent.com/u/4566?v=3" width="100px;"/><br /><sub>Nathan Youngman</sub>](https://nathany.com)<br />[⚠️](https://github.com/thechangelog/changelog.com/commits?author=nathany) | [<img src="https://avatars3.githubusercontent.com/u/43941?v=3" width="100px;"/><br /><sub>Marco Vito Moscaritolo</sub>](http://mavimo.org)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=mavimo) | [<img src="https://avatars0.githubusercontent.com/u/5904417?v=3" width="100px;"/><br /><sub>0x4e</sub>](https://github.com/fallenpeace)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=fallenpeace) | [<img src="https://avatars1.githubusercontent.com/u/8217766?v=3" width="100px;"/><br /><sub>Juan Soto</sub>](https://juansoto.me)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=sotojuan) |
| [<img src="https://avatars2.githubusercontent.com/u/1248581?v=3" width="100px;"/><br /><sub>Andrea Rossi</sub>](https://github.com/lucidstack)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=lucidstack) | [<img src="https://avatars3.githubusercontent.com/u/51889?v=3" width="100px;"/><br /><sub>Tonći Galić</sub>](http://tuxified.com)<br />🚇 | [<img src="https://avatars2.githubusercontent.com/u/321306?v=3" width="100px;"/><br /><sub>Jearvon Dharrie</sub>](http://jearvondharrie.com)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=iamjarvo) | [<img src="https://avatars2.githubusercontent.com/u/197567?v=3" width="100px;"/><br /><sub>Lee Jarvis</sub>](http://twitter.com/lee_jarvis)<br /> | [<img src="https://avatars0.githubusercontent.com/u/6601142?v=3" width="100px;"/><br /><sub>Agusti Fernandez</sub>](https://github.com/agustif)<br />[💻](https://github.com/thechangelog/changelog.com/commits?author=agustif) |
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/kentcdodds/all-contributors) specification. Contributions of any kind welcome!
