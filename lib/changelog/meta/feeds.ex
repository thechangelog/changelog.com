defmodule Changelog.Meta.Feeds do
  alias Changelog.{PostView}

  import Changelog.Router.Helpers

  def rss_feeds(assigns), do: assigns |> get

  defp get(%{podcast: podcast}) do
    shared ++ [%{url: podcast_url(conn, :feed, podcast.slug), title: "#{podcast.name} Podcast Feed"}]
  end

  defp get(%{view_module: PostView}) do
    shared ++ [%{url: post_url(conn, :feed), title: "Posts Feed"}]
  end

  defp get(_), do: shared

  defp shared do
    [
      %{url: page_url(conn, :feed), title: "Fire Hose Feed (All Shows + All Posts)"},
      %{url: podcast_url(conn, :feed, "master"), title: "Master Feed (All Shows)"}
    ]
  end

  defp conn do
    Changelog.Endpoint
  end
end
