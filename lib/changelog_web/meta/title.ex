defmodule ChangelogWeb.Meta.Title do
  alias ChangelogWeb.{
    AlbumView,
    AuthView,
    EpisodeView,
    EpisodeRequestView,
    LiveView,
    NewsItemView,
    NewsSourceView,
    PageView,
    PersonView,
    PodcastView,
    PostView,
    TopicView,
    SearchView
  }

  @default "Podcasts for developers"

  def get(conn) do
    view = Phoenix.Controller.view_module(conn)
    template = Phoenix.Controller.view_template(conn)
    assigns = Map.merge(conn.assigns, %{view_module: view, view_template: template})

    title(assigns) || @default
  end

  # Search views
  defp title(%{view_module: SearchView, view_template: "search.html", query: ""}), do: "Search"

  defp title(%{view_module: SearchView, view_template: "search.html", query: query}),
    do: "Search results for #{query}"

  # Live page
  defp title(%{view_module: LiveView, podcast: podcast, episode: episode}),
    do: "#{podcast.name} Live! #{episode.title}"

  defp title(%{view_module: LiveView}), do: "Live and upcoming shows"

  # News item - show
  defp title(%{view_module: NewsItemView, view_template: "show.html", item: item}) do
    item.headline
  end

  # News item - top
  defp title(%{view_module: NewsItemView, view_template: "top.html", filter: filter}) do
    suffix =
      case filter do
        "week" -> "this week"
        "month" -> "this month"
        "all" -> "of all time"
      end

    "Top developer news #{suffix}"
  end

  # News - submit
  defp title(%{view_module: NewsItemView, view_template: "new.html"}), do: "Submit news"

  # Sign up - subscribe
  defp title(%{view_module: PersonView, view_template: "subscribe.html"}),
    do: "Subscribe to Changelog"

  # Sign up - join community
  defp title(%{view_module: PersonView, view_template: "join.html"}), do: "Join the community"

  # Sign in
  defp title(%{view_module: AuthView}), do: "Sign In"

  # Album index
  defp title(%{view_module: AlbumView, view_template: "index.html"}), do: "Changelog Beats"

  # Album show
  defp title(%{view_module: AlbumView, view_template: "show.html", album: album}),
    do: "#{album.name} by Breakmaster Cylinder on Changelog Beats"

  # Source index
  defp title(%{view_module: NewsSourceView, view_template: "index.html"}), do: "All news sources"

  # Source show pages
  defp title(%{view_module: NewsSourceView, view_template: "show.html", source: source}) do
    "Developer news from #{source.name}"
  end

  # Topic index
  defp title(%{view_module: TopicView, view_template: "index.html"}), do: "All podcast topics"

  # Topic show page
  defp title(%{view_module: TopicView, topic: topic}) do
    "#{topic.name} podcast episodes"
  end

  # Person show page
  defp title(%{view_module: PersonView, person: person}) do
    "Podcast episodes featuring #{person.name}"
  end

  # Guest guide
  defp title(%{view_module: PageView, view_template: "guest.html", podcast: podcast}) do
    if podcast.slug == "podcast" do
      "Changelog's guest guide"
    else
      "Changelog's guest guide for #{podcast.name}"
    end
  end

  # Pages
  defp title(%{view_module: PageView, view_template: template}) do
    case template do
      "community.html" ->
        "Changelog developer community"

      "coc.html" ->
        "Code of conduct"

      "index.html" ->
        "Podcasts for developers"

      "weekly.html" ->
        "Subscribe to Changelog Weekly"

      "nightly.html" ->
        "Subscribe to Changelog Nightly"

      "sponsor_story.html" ->
        "Partner story"

      "ten.html" ->
        "Celebrating ten years of Changelog"

      _else ->
        template
        |> String.replace(".html", "")
        |> String.split("_")
        |> Enum.map(fn s -> String.capitalize(s) end)
        |> Enum.join(" ")
    end
  end

  # Podcasts index
  defp title(%{view_module: PodcastView, view_template: "index.html"}),
    do: "Podcasts for developers"

  # Podcast homepages
  defp title(%{view_module: PodcastView, podcast: podcast, tab: "popular"}) do
    "Popular episodes of #{podcast.name}"
  end

  defp title(%{view_module: PodcastView, podcast: podcast, tab: "recommended"}) do
    "Recommended episodes of #{podcast.name}"
  end

  defp title(%{view_module: PodcastView, podcast: %{name: name, slug: slug}}) do
    case slug do
      "backstage" -> "Changelog's #{name} podcast"
      "master" -> name
      "news" -> "Changelog News podcast + newsletter"
      "podcast" -> "#{name} podcast"
      _else -> "The #{name} podcast"
    end
  end

  # Episode page
  defp title(%{
         view_module: EpisodeView,
         view_template: "show.html",
         podcast: _podcast,
         episode: episode
       }) do
    EpisodeView.title_with_guest_focused_subtitle_and_podcast_aside(episode)
  end

  # News episode page
  defp title(%{
         view_module: EpisodeView,
         view_template: "news.html",
         podcast: _podcast,
         episode: episode
       }) do
    EpisodeView.title_with_guest_focused_subtitle_and_podcast_aside(episode)
  end

  # Episode request form
  defp title(%{view_module: EpisodeRequestView, view_template: "new.html", podcast: podcast}) do
    "Request an episode of #{podcast.name}"
  end

  defp title(%{view_module: EpisodeRequestView, view_template: "new.html"}) do
    "Request an episode"
  end

  # Posts index (blog)
  defp title(%{view_module: PostView, view_template: "index.html"}),
    do: "Solid takes from Changelog contributors"

  # Post show page
  defp title(%{view_module: PostView, post: post}), do: post.title

  defp title(_), do: nil
end
