defmodule ChangelogWeb.FeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, ListKit, NewsItem, Post}
  alias ChangelogWeb.{Endpoint, EpisodeView, NewsItemView, PersonView,
                      PodcastView, PostView, TimeView}

  def discussion_link(nil), do: ""
  def discussion_link(episode = %Episode{}), do: discussion_link(episode.news_item)
  def discussion_link(post = %Post{}), do: discussion_link(post.news_item)
  def discussion_link(item = %NewsItem{}) do
    url = news_item_url(Endpoint, :show, NewsItemView.hashid(item))
    discussion_link(url)
  end
  def discussion_link(url) when is_binary(url) do
    content_tag(:p) do
      content_tag(:a, "Discuss on Changelog News", href: url)
    end |> safe_to_string()
  end

  def episode_title(%{slug: "master"}, episode) do
    prefix = episode.title
    suffix =
      [episode.podcast.name, EpisodeView.number_with_pound(episode)]
      |> ListKit.compact_join()

    "#{prefix} (#{suffix})"
  end
  def episode_title(_podcast, episode), do: EpisodeView.numbered_title(episode)

  def image_link(item = %NewsItem{}) do
    if link = NewsItemView.image_link(item), do: safe_to_string(link)
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

  def render_title(_item = %{object: episode = %Episode{}}, assigns), do: render("_episode_title.xml", Map.put(assigns, :episode, Episode.preload_all(episode)))
  def render_title(_item = %{object: post = %Post{}}, assigns), do: render("_post_title.xml", Map.put(assigns, :post, post))
  def render_title(item = %{object: nil}, assigns), do: render("_item_title.xml", Map.put(assigns, :item, item))

  def video_embed(item = %NewsItem{}) do
    if embed = NewsItemView.video_embed(item), do: safe_to_string(embed)
  end
end
