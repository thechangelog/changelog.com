defmodule Changelog.Meta.Feeds do
  import Changelog.Router.Helpers

  def rss_feeds(assigns), do: assigns |> get

  defp get(%{podcast: podcast}) do
    shared ++ [%{url: podcast_url(Changelog.Endpoint, :feed, podcast.slug), title: "#{podcast.name} Podcast Feed"}]
  end

  defp get(_), do: shared

  defp shared do
    [
      %{url: podcast_url(Changelog.Endpoint, :feed, "master"), title: "Changelog Master Feed (All Shows)"}
    ]
  end
end
