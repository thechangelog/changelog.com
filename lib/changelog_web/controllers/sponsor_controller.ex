defmodule ChangelogWeb.SponsorController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, EpisodeSponsor, Podcast, Sponsor, SponsorStory, Subscription}

  plug :assign_sponsor when action in [:show]
  plug Authorize, [Policies.Sponsor, :sponsor]

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

  def styles(conn, _params) do
    render(conn, :styles)
  end

  def story(conn, %{"slug" => slug}) do
    story = Changelog.SponsorStory.get_by_slug(slug)
    render(conn, :story, story: story)
  end

  def show(conn = %{assigns: %{sponsor: sponsor}}, _params) do
    sponsorships =
      sponsor
      |> assoc(:episode_sponsors)
      |> EpisodeSponsor.newest_first()
      |> EpisodeSponsor.preload_episode()
      |> Repo.all()

    conn
    |> assign(:sponsorships, sponsorships)
    |> render(:show)
  end

  defp assign_sponsor(conn = %{params: %{"id" => id}}, _) do
    sponsor = Sponsor |> Repo.get!(id) |> Sponsor.preload_reps()
    assign(conn, :sponsor, sponsor)
  end
end
