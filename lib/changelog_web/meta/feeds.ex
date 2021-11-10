defmodule ChangelogWeb.Meta.Feeds do
  alias ChangelogWeb.Router.Helpers, as: Routes

  alias ChangelogWeb.{Meta, PostView}

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
          url: Routes.feed_url(conn(), :podcast, podcast.slug),
          title: "#{podcast.name} Podcast Feed"
        }
      ]
  end

  defp rss(%{view_module: PostView}) do
    shared() ++ [%{url: Routes.feed_url(conn(), :posts), title: "Posts Feed"}]
  end

  defp rss(_), do: shared()

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
