defmodule ChangelogWeb.Meta.Description do
  alias ChangelogWeb.{
    AlbumView,
    EpisodeView,
    LiveView,
    Meta,
    NewsItemView,
    NewsSourceView,
    PageView,
    PersonView,
    PodcastView,
    PostView,
    Helpers.SharedHelpers,
    TopicView
  }

  def get(conn) do
    assigns = Meta.prep_assigns(conn)
    description(assigns)
  end

  defp description(%{view_module: AlbumView, view_template: "index.html"}) do
    "Original music by Breakmaster Cylinder featured on all Changelog podcasts"
  end

  defp description(%{view_module: AlbumView, album: album}), do: album.description

  defp description(%{view_module: EpisodeView, episode: episode}),
    do: EpisodeView.text_description(episode)

  defp description(%{view_module: NewsItemView, item: item}),
    do: item.story |> SharedHelpers.md_to_text() |> SharedHelpers.truncate(320)

  defp description(%{view_module: NewsSourceView, source: source}), do: source.description

  defp description(%{view_module: PodcastView, view_template: "index.html"}),
    do: podcasts_summary()

  defp description(%{view_module: PodcastView, podcast: podcast}), do: podcast.description
  defp description(%{view_module: LiveView, view_template: "index.html"}), do: podcasts_summary()
  defp description(%{view_module: LiveView, podcast: podcast}), do: podcast.description

  defp description(%{view_module: PostView, post: post}) do
    if post.tldr do
      post.tldr |> SharedHelpers.md_to_text() |> SharedHelpers.truncate(320)
    else
      post.title
    end
  end

  defp description(%{view_module: PageView, view_template: "index.html"}) do
    podcasts_summary()
  end

  defp description(%{view_module: PageView, view_template: "community.html"}) do
    "Join developers from all over the world with a backstage pass to everything we do"
  end

  defp description(%{view_module: PageView, view_template: "nightly.html"}) do
    "Get the hottest new repos trending on GitHub in your inbox every night. No fluff, just repos!"
  end

  defp description(%{view_module: PersonView, person: %{bio: bio}}) when is_binary(bio) do
    bio |> SharedHelpers.md_to_text() |> SharedHelpers.truncate(320)
  end

  defp description(%{view_module: TopicView, topic: topic}), do: topic.description
  defp description(_), do: "News and podcasts for developers"

  defp podcasts_summary do
    "Weekly shows about software development, developer culture, open source, building startups, artificial intelligence, brain science, and the people involved."
  end
end
