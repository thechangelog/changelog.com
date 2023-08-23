defmodule ChangelogWeb.Meta.Feeds do
  alias ChangelogWeb.Router.Helpers, as: Routes

  alias ChangelogWeb.{Endpoint, Meta, PodcastView, PostView}

  def get(type, conn) do
    assigns = Meta.prep_assigns(conn)

    case type do
      :rss -> rss(assigns)
    end
  end

  defp rss(%{podcast: podcast}) do
    shared() ++
      [
        %{
          url: PodcastView.feed_url(podcast),
          title: "#{podcast.name} Podcast Feed"
        }
      ]
  end

  defp rss(%{view_module: PostView}) do
    shared() ++ [%{url: Routes.feed_url(Endpoint, :posts), title: "Posts Feed"}]
  end

  defp rss(_), do: shared()

  defp shared do
    [
      %{url: Routes.feed_url(Endpoint, :news), title: "News Feed (The Proverbial Fire Hose)"},
      %{url: Routes.feed_url(Endpoint, :podcast, "master"), title: "Master Feed (All Shows)"}
    ]
  end
end
