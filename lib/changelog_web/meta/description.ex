defmodule ChangelogWeb.Meta.Description do
  import ChangelogWeb.Helpers.SharedHelpers,
    only: [md_to_text: 1, truncate: 2]

  alias ChangelogWeb.{EpisodeView, LiveView, NewsItemView, NewsSourceView,
                      PageView, PersonView, PodcastView, PostView, TopicView}

  def description(assigns), do: get(assigns)

  defp get(%{view_module: EpisodeView, episode: episode}), do: episode.summary |> md_to_text() |> truncate(320)
  defp get(%{view_module: NewsItemView, item: item}), do: item.story |> md_to_text() |> truncate(320)
  defp get(%{view_module: NewsSourceView, source: source}), do: source.description
  defp get(%{view_module: PodcastView, view_template: "index.html"}), do: podcasts_summary()
  defp get(%{view_module: PodcastView, podcast: podcast}), do: podcast.description
  defp get(%{view_module: LiveView, view_template: "index.html"}), do: podcasts_summary()
  defp get(%{view_module: LiveView, podcast: podcast}), do: podcast.description
  defp get(%{view_module: PostView, post: post}) do
    if post.tldr do
      post.tldr |> md_to_text() |> truncate(320)
    else
      post.title
    end
  end
  defp get(%{view_module: PageView, view_template: "community.html"}) do
    "Join developers from all over the world with a backstage pass to everything we do"
  end
  defp get(%{view_module: PageView, view_template: "weekly.html"}) do
    "Our editorialized take on this week in dev culture, software development, open source, building startups, creative work, and the people involved"
  end
  defp get(%{view_module: PageView, view_template: "nightly.html"}) do
    "Get the hottest new repos trending on GitHub in your inbox every night. No fluff, just repos!"
  end
  defp get(%{view_module: PersonView, person: %{bio: bio}}) when is_binary(bio) do
    bio |> md_to_text() |> truncate(320)
  end
  defp get(%{view_module: TopicView, topic: topic}), do: topic.description
  defp get(_), do: "News and podcasts for developers"

  defp podcasts_summary do
    "Weekly shows about developer culture, software development, open source, building startups, artificial intelligence, and the people involved"
  end
end
