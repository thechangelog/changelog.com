defmodule ChangelogWeb.Meta.Feeds do

  alias ChangelogWeb.Router.Helpers, as: Routes

  alias ChangelogWeb.{PostView}

  def rss_feeds(assigns), do: assigns |> get

  defp get(%{podcast: podcast}) do
    shared() ++ [%{url: Routes.feed_url(conn(), :podcast, podcast.slug), title: "#{podcast.name} Podcast Feed"}]
  end

  defp get(%{view_module: PostView}) do
    shared() ++ [%{url: Routes.feed_url(conn(), :posts), title: "Posts Feed"}]
  end

  defp get(_), do: shared()

  defp shared do
    [
      %{url: Routes.feed_url(conn(), :news), title: "News Feed (The Proverbial Fire Hose)"},
      %{url: Routes.feed_url(conn(), :podcast, "master"), title: "Master Feed (All Shows)"}
    ]
  end

  defp conn do
    ChangelogWeb.Endpoint
  end
end
