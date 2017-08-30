defmodule ChangelogWeb.Meta.Title do

  alias ChangelogWeb.{AuthView, EpisodeView, LiveView, PageView, PersonView,
                      PodcastView, PostView, SearchView}

  @suffix "Changelog"

  def page_title(assigns), do: assigns |> get |> put_suffix

  # no need for the suffix on these
  def share_title(assigns), do: assigns |> get

  defp put_suffix(nil), do: @suffix
  defp put_suffix(title), do: title <> " | " <> @suffix

  defp get(%{view_module: AuthView}), do: "Sign In"

  defp get(%{view_module: SearchView, view_template: "search.html", query: query}), do: query
  defp get(%{view_module: SearchView, view_template: "search.html"}), do: "Search"

  defp get(%{view_module: EpisodeView, view_template: "show.html", podcast: podcast, episode: episode}) do
    "#{podcast.name} #{EpisodeView.numbered_title(episode, "#")}"
  end

  defp get(%{view_module: LiveView}) do
    "Live and Upcoming Shows"
  end

  defp get(%{view_module: PageView, view_template: template}) do
    case template do
      "community.html" -> "Join Changelog's Global Hacker Community"
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

  defp get(%{view_module: PodcastView, view_template: "index.html"}) do
    "All Changelog Podcasts"
  end

  defp get(%{view_module: PodcastView, view_template: "archive.html", podcast: podcast}) do
    "#{podcast.name} Episode Archive"
  end

  defp get(%{view_module: PodcastView, podcast: podcast}) do
    if Enum.any?(podcast.hosts) do
      "#{podcast.name} with #{PersonView.comma_separated_names(podcast.hosts)}"
    else
      podcast.name
    end
  end

  defp get(%{view_module: PostView, post: post}) do
    post.title
  end

  defp get(_), do: nil
end
