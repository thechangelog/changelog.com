defmodule ChangelogWeb.FeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, ListKit, NewsItem, Podcast, Post}

  alias ChangelogWeb.{
    EpisodeView,
    NewsItemView,
    PersonView,
    PodcastView,
    PostView,
    TimeView
  }

  def discussion_link(nil), do: ""

  def discussion_link(episode = %Episode{}) do
    url(~p"/#{episode.podcast.slug}/#{episode.slug}/discuss") |> discussion_link()
  end

  def discussion_link(post = %Post{}), do: discussion_link(post.news_item)

  def discussion_link(item = %NewsItem{}) do
    url(~p"/news/#{NewsItemView.hashid(item)}") |> discussion_link()
  end

  def discussion_link(url) when is_binary(url) do
    content_tag(:p) do
      content_tag(:a, "Leave us a comment", href: url)
    end
    |> safe_to_string()
  end

  def episode_title(%{slug: "master"}, episode), do: EpisodeView.title_with_podcast_aside(episode)

  def episode_title(%{slug: "podcast", is_meta: true}, episode) do
    aside =
      case episode.podcast.slug do
        "news" -> "News"
        "friends" -> "Friends"
        "podcast" -> "Interview"
      end

    "#{episode.title} (#{aside})"
  end

  def episode_title(_podcast, episode), do: episode.title

  def image_link(item = %NewsItem{}) do
    if link = NewsItemView.image_link(item), do: safe_to_string(link)
  end

  def podcast_full_description(%{description: description, extended_description: extended}) do
    [description, extended]
    |> ListKit.compact()
    |> Enum.map(&SharedHelpers.md_to_text/1)
    |> Enum.join(" ")
  end

  def podcast_name_with_metadata(%{slug: "podcast", is_meta: true, name: name}) do
    "#{name}: Software Development, Open Source"
  end

  def podcast_name_with_metadata(podcast) do
    case podcast.slug do
      "brainscience" -> "#{podcast.name}: Neuroscience, Behavior"
      "founderstalk" -> "#{podcast.name}: Startups, CEOs, Leadership"
      "gotime" -> "#{podcast.name}: Golang, Software Engineering"
      "jsparty" -> "#{podcast.name}: JavaScript, CSS, Web Development"
      "practicalai" -> "#{podcast.name}: Machine Learning, Data Science"
      "shipit" -> "#{podcast.name} SRE, Platform Engineering, DevOps"
      _else -> podcast.name
    end
  end

  def podcast_name_with_numbered_episode_title(episode) do
    numbered_title = EpisodeView.numbered_title(episode)
    "#{episode.podcast.name} #{numbered_title}"
  end

  # Exists to special-case /interviews
  def podcast_url(podcast) do
    slug = if Podcast.is_interviews(podcast), do: "interviews", else: podcast.slug
    url(~p"/#{slug}")
  end

  def render_item(item = %{object: episode = %Episode{}}, assigns) do
    episode = episode |> Episode.preload_all() |> Map.put(:news_item, item)
    render("_episode.xml", Map.merge(assigns, %{episode: episode, plusplus: false}))
  end

  def render_item(item = %{object: post = %Post{}}, assigns) do
    post = post |> Map.put(:news_item, item)
    render("_post.xml", Map.put(assigns, :post, post))
  end

  def render_item(item = %{object: nil}, assigns) do
    render("_item.xml", Map.put(assigns, :item, item))
  end

  def render_title(_item = %{object: episode = %Episode{}}, assigns),
    do: render("_episode_title.xml", Map.put(assigns, :episode, Episode.preload_all(episode)))

  def render_title(_item = %{object: post = %Post{}}, assigns),
    do: render("_post_title.xml", Map.put(assigns, :post, post))

  def render_title(item = %{object: nil}, assigns),
    do: render("_item_title.xml", Map.put(assigns, :item, item))

  def video_embed(item = %NewsItem{}) do
    if embed = NewsItemView.video_embed(item), do: safe_to_string(embed)
  end
end
