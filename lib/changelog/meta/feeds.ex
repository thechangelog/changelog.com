defmodule Changelog.Meta.Feeds do
  alias Changelog.{PostView}

  import Changelog.Router.Helpers

  def rss_feeds(assigns), do: assigns |> get

  defp get(%{podcast: podcast}) do
    shared ++ [%{url: feed_url(conn, :podcast, podcast.slug), title: "#{podcast.name} Podcast Feed"}]
  end

  defp get(%{view_module: PostView}) do
    shared ++ [%{url: feed_url(conn, :posts), title: "Posts Feed"}]
  end

  defp get(_), do: shared

  defp shared do
    [
      %{url: feed_url(conn, :all), title: "Fire Hose Feed (All Shows + All Posts)"},
      %{url: feed_url(conn, :podcast, "master"), title: "Master Feed (All Shows)"}
    ]
  end

  defp conn do
    Changelog.Endpoint
  end
end
