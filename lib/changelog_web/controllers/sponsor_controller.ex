defmodule ChangelogWeb.SponsorController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, Podcast, SponsorStory, Subscription}

  def index(conn, _params) do
    examples = SponsorStory.examples()

    subs =
      Cache.podcasts()
      |> Enum.find(&Podcast.is_news/1)
      |> Subscription.subscribed_count()

    render(conn, :index, examples: examples, subs: subs)
  end

  def pricing(conn, _params) do
    render(conn, :pricing)
  end

  def story(conn, %{"slug" => slug}) do
    story = Changelog.SponsorStory.get_by_slug(slug)
    render(conn, :story, story: story)
  end
end
