[![All Contributors](https://img.shields.io/badge/all_contributors-31-orange.svg?style=flat-square)](#contributors-)

## What is this?

This is the CMS behind [changelog.com](https://changelog.com).
It is an [Elixir](http://elixir-lang.org) application built with the [Phoenix](http://www.phoenixframework.org) web framework and [many](https://github.com/thechangelog/changelog.com/blob/master/mix.exs#L33) [other](https://github.com/thechangelog/changelog.com/blob/master/assets/package.json) great open source efforts.
It uses [Node.js](https://nodejs.org/en/) for static assets & [PostgreSQL](https://www.postgresql.org) for persistence.

[More details in our 2016 announcement post!](https://changelog.com/posts/changelog-is-open-source)

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

That is an excellent idea! Here is [our contributing guide](CONTRIBUTING.md). Kaizen 改善!

## CONTRIBUTORS ✨

Thanks goes to these wonderful people ([emoji key](https://github.com/kentcdodds/all-contributors#emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://jerodsanto.net"><img src="https://avatars3.githubusercontent.com/u/8212?v=3?s=100" width="100px;" alt="Jerod Santo"/><br /><sub><b>Jerod Santo</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=jerodsanto" title="Code">💻</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=jerodsanto" title="Documentation">📖</a> <a href="#infra-jerodsanto" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://changelog.com/"><img src="https://avatars2.githubusercontent.com/u/2933?v=3?s=100" width="100px;" alt="Adam Stacoviak"/><br /><sub><b>Adam Stacoviak</b></sub></a><br /><a href="#design-adamstac" title="Design">🎨</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=adamstac" title="Code">💻</a> <a href="#financial-adamstac" title="Financial">💵</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://humanshapes.co"><img src="https://avatars0.githubusercontent.com/u/378665?v=3?s=100" width="100px;" alt="Cody Peterson"/><br /><sub><b>Cody Peterson</b></sub></a><br /><a href="#design-codyjames" title="Design">🎨</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=codyjames" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://elevate.co"><img src="https://pbs.twimg.com/profile_images/1053277843176677379/7y-9aoX5_400x400.jpg?s=100" width="100px;" alt="Jake Stutzman"/><br /><sub><b>Jake Stutzman</b></sub></a><br /><a href="#design-jakestutzman" title="Design">🎨</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/TuckerCowie"><img src="https://avatars2.githubusercontent.com/u/7838530?v=3?s=100" width="100px;" alt="Tucker Cowie"/><br /><sub><b>Tucker Cowie</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=TuckerCowie" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/gerhard"><img src="https://avatars2.githubusercontent.com/u/3342?v=3?s=100" width="100px;" alt="Gerhard Lazu"/><br /><sub><b>Gerhard Lazu</b></sub></a><br /><a href="#infra-gerhard" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=gerhard" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://www.xinjiangshao.com"><img src="https://avatars3.githubusercontent.com/u/635858?v=3?s=100" width="100px;" alt="Xinjiang Shao"/><br /><sub><b>Xinjiang Shao</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=soleo" title="Documentation">📖</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=soleo" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://beforeitwasround.com"><img src="https://avatars0.githubusercontent.com/u/28044?v=3?s=100" width="100px;" alt="Steve Agalloco"/><br /><sub><b>Steve Agalloco</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=stve" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://david.gasperoni.org"><img src="https://avatars1.githubusercontent.com/u/898057?v=3?s=100" width="100px;" alt="David Gasperoni"/><br /><sub><b>David Gasperoni</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=mcdado" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://nathany.com"><img src="https://avatars2.githubusercontent.com/u/4566?v=3?s=100" width="100px;" alt="Nathan Youngman"/><br /><sub><b>Nathan Youngman</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=nathany" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://mavimo.org"><img src="https://avatars3.githubusercontent.com/u/43941?v=3?s=100" width="100px;" alt="Marco Vito Moscaritolo"/><br /><sub><b>Marco Vito Moscaritolo</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=mavimo" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/fallenpeace"><img src="https://avatars0.githubusercontent.com/u/5904417?v=3?s=100" width="100px;" alt="0x4e"/><br /><sub><b>0x4e</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=fallenpeace" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/lucidstack"><img src="https://avatars2.githubusercontent.com/u/1248581?v=3?s=100" width="100px;" alt="Andrea Rossi"/><br /><sub><b>Andrea Rossi</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=lucidstack" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://tuxified.com"><img src="https://avatars3.githubusercontent.com/u/51889?v=3?s=100" width="100px;" alt="Tonći Galić"/><br /><sub><b>Tonći Galić</b></sub></a><br /><a href="#infra-Tuxified" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://jearvondharrie.com"><img src="https://avatars2.githubusercontent.com/u/321306?v=3?s=100" width="100px;" alt="Jearvon Dharrie"/><br /><sub><b>Jearvon Dharrie</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=iamjarvo" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://twitter.com/lee_jarvis"><img src="https://avatars2.githubusercontent.com/u/197567?v=3?s=100" width="100px;" alt="Lee Jarvis"/><br /><sub><b>Lee Jarvis</b></sub></a><br /></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/agustif"><img src="https://avatars0.githubusercontent.com/u/6601142?v=3?s=100" width="100px;" alt="Agusti Fernandez"/><br /><sub><b>Agusti Fernandez</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=agustif" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/LenPayne"><img src="https://avatars3.githubusercontent.com/u/1460304?v=4?s=100" width="100px;" alt="Len Payne"/><br /><sub><b>Len Payne</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=LenPayne" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="http://joebew42.github.io/about/"><img src="https://avatars2.githubusercontent.com/u/1238549?v=4?s=100" width="100px;" alt="JoeBew42"/><br /><sub><b>JoeBew42</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=joebew42" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://griffinbyatt.com"><img src="https://avatars3.githubusercontent.com/u/6545494?v=4?s=100" width="100px;" alt="Griffin Byatt"/><br /><sub><b>Griffin Byatt</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=GriffinMB" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/r-frederick"><img src="https://avatars1.githubusercontent.com/u/13277581?v=4?s=100" width="100px;" alt="Ridge Frederick"/><br /><sub><b>Ridge Frederick</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=r-frederick" title="Code">💻</a> <a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Ar-frederick" title="Bug reports">🐛</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://keybase.io/hhrutter"><img src="https://avatars0.githubusercontent.com/u/11322155?v=4?s=100" width="100px;" alt="Horst Rutter"/><br /><sub><b>Horst Rutter</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Ahhrutter" title="Bug reports">🐛</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://nickjanetakis.com"><img src="https://avatars2.githubusercontent.com/u/813219?v=4?s=100" width="100px;" alt="Nick Janetakis"/><br /><sub><b>Nick Janetakis</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Anickjj" title="Bug reports">🐛</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=nickjj" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://ryanwilldev.com"><img src="https://avatars0.githubusercontent.com/u/12587988?v=4?s=100" width="100px;" alt="Ryan Will"/><br /><sub><b>Ryan Will</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3ARyanWillDev" title="Bug reports">🐛</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=RyanWillDev" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://dennisreimann.de"><img src="https://avatars1.githubusercontent.com/u/886?v=3?s=100" width="100px;" alt="Dennis Reimann"/><br /><sub><b>Dennis Reimann</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=dennisreimann" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://juansoto.me"><img src="https://avatars1.githubusercontent.com/u/8217766?v=3?s=100" width="100px;" alt="Juan Soto"/><br /><sub><b>Juan Soto</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=sotojuan" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/JordyZomer"><img src="https://avatars3.githubusercontent.com/u/17198473?v=4?s=100" width="100px;" alt="Jordy Zomer"/><br /><sub><b>Jordy Zomer</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=JordyZomer" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://zendev.com"><img src="https://avatars0.githubusercontent.com/u/44007?v=4?s=100" width="100px;" alt="Kevin Ball"/><br /><sub><b>Kevin Ball</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=kball" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://matryer.com"><img src="https://avatars3.githubusercontent.com/u/101659?v=4?s=100" width="100px;" alt="Mat Ryer"/><br /><sub><b>Mat Ryer</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=matryer" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/yanokwa"><img src="https://avatars3.githubusercontent.com/u/32369?v=4?s=100" width="100px;" alt="Yaw Anokwa"/><br /><sub><b>Yaw Anokwa</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=yanokwa" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="http://choly.ca"><img src="https://avatars1.githubusercontent.com/u/943597?v=4?s=100" width="100px;" alt="Ilia Choly"/><br /><sub><b>Ilia Choly</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=icholy" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://wojtekmach.pl"><img src="https://avatars0.githubusercontent.com/u/76071?v=4?s=100" width="100px;" alt="Wojtek Mach"/><br /><sub><b>Wojtek Mach</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=wojtekmach" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/type1fool"><img src="https://avatars3.githubusercontent.com/u/13895134?v=4?s=100" width="100px;" alt="Owen Bickford"/><br /><sub><b>Owen Bickford</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=type1fool" title="Code">💻</a> <a href="#blog-type1fool" title="Blogposts">📝</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://underjord.io"><img src="https://avatars1.githubusercontent.com/u/1971237?v=4?s=100" width="100px;" alt="Lars Wikman"/><br /><sub><b>Lars Wikman</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=lawik" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://marceloandrader.github.io/"><img src="https://avatars0.githubusercontent.com/u/57552?v=4?s=100" width="100px;" alt="Marcelo Andrade"/><br /><sub><b>Marcelo Andrade</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=marceloandrader" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/axelson"><img src="https://avatars1.githubusercontent.com/u/9973?v=4?s=100" width="100px;" alt="Jason Axelson"/><br /><sub><b>Jason Axelson</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=axelson" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://akoutmos.com/"><img src="https://avatars0.githubusercontent.com/u/4753634?v=4?s=100" width="100px;" alt="Alexander Koutmos"/><br /><sub><b>Alexander Koutmos</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=akoutmos" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/d-m-u"><img src="https://avatars.githubusercontent.com/u/16326669?v=4?s=100" width="100px;" alt="d-m-u"/><br /><sub><b>d-m-u</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Ad-m-u" title="Bug reports">🐛</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://sorentwo.com"><img src="https://avatars.githubusercontent.com/u/270831?v=4?s=100" width="100px;" alt="Parker Selbert"/><br /><sub><b>Parker Selbert</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=sorentwo" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://hailelagi.com"><img src="https://avatars.githubusercontent.com/u/52631736?v=4?s=100" width="100px;" alt="Haile Lagi"/><br /><sub><b>Haile Lagi</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=hailelagi" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://nezteb.net"><img src="https://avatars.githubusercontent.com/u/3588798?v=4?s=100" width="100px;" alt="Noah"/><br /><sub><b>Noah</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=Nezteb" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/pilor"><img src="https://avatars.githubusercontent.com/u/718813?v=4?s=100" width="100px;" alt="Chris Eggert"/><br /><sub><b>Chris Eggert</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=pilor" title="Code">💻</a> <a href="https://github.com/thechangelog/changelog.com/commits?author=pilor" title="Documentation">📖</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://reintegrate-web-development.fly.dev/"><img src="https://avatars.githubusercontent.com/u/34007453?v=4?s=100" width="100px;" alt="Kenneth Kostrešević"/><br /><sub><b>Kenneth Kostrešević</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=ken-kost" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/gorosgobe"><img src="https://avatars.githubusercontent.com/u/26676483?v=4?s=100" width="100px;" alt="Pablo Gorostiaga"/><br /><sub><b>Pablo Gorostiaga</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/issues?q=author%3Agorosgobe" title="Bug reports">🐛</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://www.patrickhyatt.com"><img src="https://avatars.githubusercontent.com/u/296125?v=4?s=100" width="100px;" alt="Patrick Hyatt"/><br /><sub><b>Patrick Hyatt</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=patHyatt" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://lentner.io"><img src="https://avatars.githubusercontent.com/u/8965948?v=4?s=100" width="100px;" alt="Geoffrey Lentner"/><br /><sub><b>Geoffrey Lentner</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=glentner" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://bws.bio"><img src="https://avatars.githubusercontent.com/u/26674818?v=4?s=100" width="100px;" alt="Brendon Smith"/><br /><sub><b>Brendon Smith</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=br3ndonland" title="Code">💻</a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/zamai"><img src="https://avatars.githubusercontent.com/u/10281047?v=4?s=100" width="100px;" alt="Alex Zamai"/><br /><sub><b>Alex Zamai</b></sub></a><br /><a href="https://github.com/thechangelog/changelog.com/commits?author=zamai" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/kentcdodds/all-contributors) specification. Contributions of any kind welcome!

## LICENSE

[MIT](LICENSE)
