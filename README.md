# changelog.com [![ci.changelog.com](https://ci.changelog.com/api/v1/pipelines/changelog.com/jobs/deploy/badge)](https://ci.changelog.com/teams/main/pipelines/changelog.com/jobs/deploy)

[Read the announcement post!](https://changelog.com/posts/changelog-is-open-source)

## What is this?

This is the CMS behind [changelog.com](https://changelog.com). It's an [Elixir](http://elixir-lang.org) application built on the [Phoenix](http://www.phoenixframework.org) web framework, [PostgreSQL](https://www.postgresql.org), and [many](https://github.com/thechangelog/changelog.com/blob/master/mix.exs#L33) [other](https://github.com/thechangelog/changelog.com/blob/master/package.json) great open source efforts.

## Why is it open source?

A few reasons:

1. We _love_ open source. Our careers (and livelihoods) wouldn't be possible without open source. Keeping it closed just feels _wrong_.
2. Phoenix is really great, but it's young enough in its lifecycle that there aren't _too many_ in-production, open source sites for people to refer to as examples or inspiration. We want to throw our hat into that ring and hopefully others will follow.
3. Changelog is a community of hackers. We know open sourcing the website will lead to good things from y'all (such as bug reports, feature requests, and pull requests).

## Should I fork this and use it as a platform?

Probably not. We won't stop you from doing it, but we don't advise it. _This is not a general purpose podcasting CMS_. It is a CMS that is specific to Changelog and our needs. From the design and layout to the data structures and file hosting, we built this for us. An example of just how custom it is — [we literally have our podcast slugs hardcoded in areas of the code](https://github.com/thechangelog/changelog.com/blob/master/web/controllers/slack_controller.ex#L8). Yuck.

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
