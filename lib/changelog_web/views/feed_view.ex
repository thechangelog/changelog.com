defmodule ChangelogWeb.FeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, ListKit, NewsItem, Post}

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

  def episode_title(%{slug: "master"}, episode), do: EpisodeView.title_with_podcast_aside(episode)
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

  def podcast_name_with_metadata(podcast) do
    case podcast.slug do
      "brainscience" -> "#{podcast.name}: Neuroscience, Behavior"
      "founderstalk" -> "#{podcast.name}: Startups, CEOs, Leadership"
      "gotime" -> "#{podcast.name}: Golang, Software Engineering"
      "jsparty" -> "#{podcast.name}: JavaScript, CSS, Web Development"
      "podcast" -> "#{podcast.name}: Software Development, Open Source"
      "practicalai" -> "#{podcast.name}: Machine Learning, Data Science"
      "shipit" -> "#{podcast.name} DevOps, Infra, Cloud Native"
      _else -> podcast.name
    end
  end

  def podcast_name_with_numbered_episode_title(episode) do
    numbered_title = EpisodeView.numbered_title(episode)

    if EpisodeView.is_changelog_news(episode) do
      "Changelog News: #{episode.title}"
    else
      "#{episode.podcast.name} #{numbered_title}"
    end
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
