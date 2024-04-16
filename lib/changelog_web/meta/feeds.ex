defmodule ChangelogWeb.Meta.Feeds do
  use ChangelogWeb, :verified_routes

  alias ChangelogWeb.{Meta, PodcastView, PostView}

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
    shared() ++ [%{url: ~p"/posts/feed", title: "Posts Feed"}]
  end

  defp rss(_), do: shared()

  defp shared do
    [
      %{url: url(~p"/feed"), title: "Combined Feed (Pods + Posts)"},
      %{url: url(~p"/master/feed"), title: "Master Feed (All Pods)"}
    ]
  end
end
