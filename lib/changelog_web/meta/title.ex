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
  defp get(%{view_module: SearchView, view_template: "search.html", query: query}), do: "Search results for #{query}"
  defp get(%{view_module: SearchView, view_template: "search.html"}), do: "Search"

  # Live page
  defp get(%{view_module: LiveView}) do
    "Live and Upcoming Shows"
  end

  # News item - show
  defp get(%{view_module: NewsItemView, view_template: "show.html", item: item}) do
    item.headline
  end

  # Sign up - subscribe
  defp get(%{view_module: PersonView, view_template: "subscribe.html"}) do
    "Subscribe to Changelog"
  end

  # Sign up - join community
  defp get(%{view_module: PersonView, view_template: "join.html"}) do
    "Join the Community"
  end

  # Sign in
  defp get(%{view_module: AuthView}), do: "Sign In"

  # Source index
  defp get(%{view_module: NewSourceView, view_template: "index.html"}) do
    "All News Sources"
  end

  # Source show page
  defp get(%{view_module: NewsSourceView, view_template: "show.html", source: source}) do
    "Developer News from #{source.name}"
  end

  # Topic index
  defp get(%{view_module: TopicView, view_template: "index.html"}) do
    "All News Topics"
  end

  # Topic show page
  defp get(%{view_module: TopicView, view_template: "show.html", topic: topic}) do
    "Developer News about #{topic.name}"
  end

  # Pages
  defp get(%{view_module: PageView, view_template: template}) do
    case template do
      "community.html" -> "Changelog Developer Community"
      "coc.html"       -> "Code of Conduct"
      "home.html"      -> nil
      "weekly.html"    -> "Subscribe to Changelog Weekly"
      "nightly.html"   -> "Subscribe to Changelog Nightly"
      _else ->
        template
        |> String.replace(".html", "")
        |> String.split("_")
        |> Enum.map(fn(s) -> String.capitalize(s) end)
        |> Enum.join(" ")
    end
  end

  # Podcasts index
  defp get(%{view_module: PodcastView, view_template: "index.html"}) do
    "Changelog Podcasts"
  end

  # Podcast homepage
  defp get(%{view_module: PodcastView, podcast: podcast}) do
    if Enum.any?(podcast.hosts) do
      "#{podcast.name} with #{PersonView.comma_separated_names(podcast.hosts)}"
    else
      podcast.name
    end
  end

  # Podcast show page
  defp get(%{view_module: EpisodeView, view_template: "show.html", podcast: podcast, episode: episode}) do
    "#{podcast.name} #{EpisodeView.numbered_title(episode, "#")}"
  end

  # Posts index (blog)
  defp get(%{view_module: PostView, view_template: "index.html"}) do
    "Blog"
  end

  # Post show page
  defp get(%{view_module: PostView, post: post}) do
    post.title
  end

  defp get(_), do: nil
end
