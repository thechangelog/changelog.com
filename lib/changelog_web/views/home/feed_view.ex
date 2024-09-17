defmodule ChangelogWeb.Home.FeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Podcast}
  alias ChangelogWeb.{HomeView, PodcastView}

  def cover_options(pods) do
    extra = [
      %{name: Podcast.plusplus().name, url: PodcastView.cover_url(Podcast.plusplus(), :original)},
      %{name: Podcast.changelog().name, url: PodcastView.cover_url(Podcast.changelog(), :original)},
      %{name: "The Changelog (legacy)", url: url(~p"/images/podcasts/podcast-legacy.jpg")}
    ]

    stock =
    pods
    |> Enum.map(fn pod ->
      %{name: pod.name, url: PodcastView.cover_url(pod, :original)}
    end)

    extra ++ stock
  end
end
