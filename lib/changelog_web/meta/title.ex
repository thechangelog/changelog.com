defmodule ChangelogWeb.Meta.Title do

  alias ChangelogWeb.{AuthView, EpisodeView, LiveView, NewsItemView, NewsSourceView,
                      PageView, PersonView, PodcastView, PostView, TopicView, SearchView}

  @suffix "News and podcasts for developers | Changelog"

  def page_title(assigns), do: assigns |> get |> put_suffix

  # no need for the suffix on these
  def share_title(assigns), do: assigns |> get

  defp put_suffix(nil), do: @suffix
  defp put_suffix(title), do: title <> " | " <> @suffix

  # Search views
  defp get(%{view_module: SearchView, view_template: "search.html", query: ""}), do: "Search"
  defp get(%{view_module: SearchView, view_template: "search.html", query: query}), do: "Search results for #{query}"

  # Live page
  defp get(%{view_module: LiveView}), do: "Live and upcoming shows"

  # News item - show
  defp get(%{view_module: NewsItemView, view_template: "show.html", item: item}) do
    item.headline
  end

  # News item - top
  defp get(%{view_module: NewsItemView, view_template: "top.html", filter: filter}) do
    suffix = case filter do
      "week" -> "this week"
      "month" -> "this month"
      "all" -> "of all time"
    end

    "Top developer news #{suffix}"
  end

  # News - submit
  defp get(%{view_module: NewsItemView, view_template: "new.html"}), do: "Submit news"

  # Sign up - subscribe
  defp get(%{view_module: PersonView, view_template: "subscribe.html"}), do: "Subscribe to Changelog"

  # Sign up - join community
  defp get(%{view_module: PersonView, view_template: "join.html"}), do: "Join the community"

  # Sign in
  defp get(%{view_module: AuthView}), do: "Sign In"

  # Source index
  defp get(%{view_module: NewsSourceView, view_template: "index.html"}), do: "All news sources"

  # Source show pages
  defp get(%{view_module: NewsSourceView, view_template: "show.html", source: source}) do
    "Developer news from #{source.name}"
  end

  # Topic index
  defp get(%{view_module: TopicView, view_template: "index.html"}), do: "All news topics"

  # Topic show pages
  defp get(%{view_module: TopicView, topic: topic, tab: "news"}) do
    "Developer news about #{topic.name}"
  end
  defp get(%{view_module: TopicView, topic: topic, tab: "podcasts"}) do
    "Developer podcasts about #{topic.name}"
  end
  defp get(%{view_module: TopicView, topic: topic}) do
    "Developer news and podcasts about #{topic.name}"
  end

  # Pages
  defp get(%{view_module: PageView, view_template: template}) do
    case template do
      "community.html"     -> "Changelog developer community"
      "coc.html"           -> "Code of conduct"
      "home.html"          -> nil
      "weekly.html"        -> "Subscribe to Changelog Weekly"
      "nightly.html"       -> "Subscribe to Changelog Nightly"
      "sponsor_story.html" -> "Partner story"
      _else ->
        template
        |> String.replace(".html", "")
        |> String.split("_")
        |> Enum.map(fn(s) -> String.capitalize(s) end)
        |> Enum.join(" ")
    end
  end

  # Podcasts index
  defp get(%{view_module: PodcastView, view_template: "index.html"}), do: "All Changelog podcasts"

  # Podcast homepages
  defp get(%{view_module: PodcastView, podcast: podcast, tab: "recommended"}) do
    "Recommended episodes of #{podcast.name}"
  end
  defp get(%{view_module: PodcastView, podcast: podcast}) do
    if Enum.any?(podcast.hosts) do
      "#{podcast.name} with #{PersonView.comma_separated_names(podcast.hosts)}"
    else
      podcast.name
    end
  end

  # Episode page
  defp get(%{view_module: EpisodeView, view_template: "show.html", podcast: podcast, episode: episode}) do
    "#{podcast.name} #{EpisodeView.numbered_title(episode, "#")} #{episode.subtitle}"
  end

  # Posts index (blog)
  defp get(%{view_module: PostView, view_template: "index.html"}), do: "Blog"

  # Post show page
  defp get(%{view_module: PostView, post: post}), do: post.title

  defp get(_), do: nil
end
