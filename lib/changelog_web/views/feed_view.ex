defmodule ChangelogWeb.FeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, NewsItem, Post}

  alias ChangelogWeb.{
    Endpoint,
    EpisodeView,
    NewsItemView,
    PersonView,
    PodcastView,
    PostView,
    TimeView
  }

  def discussion_link(nil), do: ""

  def discussion_link(episode = %Episode{}) do
    Endpoint
    |> Routes.episode_url(:discuss, episode.podcast.slug, episode.slug)
    |> discussion_link()
  end

  def discussion_link(post = %Post{}), do: discussion_link(post.news_item)

  def discussion_link(item = %NewsItem{}) do
    url = Routes.news_item_url(Endpoint, :show, NewsItemView.hashid(item))
    discussion_link(url)
  end

  def discussion_link(url) when is_binary(url) do
    content_tag(:p) do
      content_tag(:a, "Discuss on Changelog News", href: url)
    end
    |> safe_to_string()
  end

  def enclosure_url(episode = %{podcast: %{slug: "podcast"}}) do
    "https://chtbl.com/track/382DG4/" <> EpisodeView.audio_url(episode)
  end

  def enclosure_url(episode), do: EpisodeView.audio_url(episode)

  def episode_title(%{slug: "master"}, episode), do: EpisodeView.title_with_podcast_aside(episode)
  def episode_title(_podcast, episode), do: episode.title

  def image_link(item = %NewsItem{}) do
    if link = NewsItemView.image_link(item), do: safe_to_string(link)
  end

  def podcast_name_with_metadata(podcast) do
    case podcast.slug do
      "brainscience" -> "#{podcast.name}: Neuroscience & Behavior"
      "founderstalk" -> "#{podcast.name}: Startups & Leadership"
      "jsparty" -> "#{podcast.name}: JavaScript & Web Dev"
      "podcast" -> "#{podcast.name}: Software Dev & Open Source"
      "practicalai" -> "#{podcast.name}: Machine Learning & Data Science"
      _else -> podcast.name
    end
  end

  def render_item(item = %{object: episode = %Episode{}}, assigns) do
    episode = episode |> Episode.preload_all() |> Map.put(:news_item, item)
    render("_episode.xml", Map.put(assigns, :episode, episode))
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
