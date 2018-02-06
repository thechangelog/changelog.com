defmodule ChangelogWeb.FeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, NewsItem, Podcast, Post}
  alias ChangelogWeb.{EpisodeView, NewsItemView, PersonView, PodcastView,
                      PostView, TimeView}

  def image_link(item = %NewsItem{}) do
    if link = NewsItemView.image_link(item), do: safe_to_string(link)
  end

  def render_item(_item = %{object: episode = %Episode{}}, assigns), do: render("_episode.xml", Map.put(assigns, :episode, Episode.preload_all(episode)))
  def render_item(_item = %{object: post = %Post{}}, assigns), do: render("_post.xml", Map.put(assigns, :post, post))
  def render_item(item = %{object: nil}, assigns), do: render("_item.xml", Map.put(assigns, :item, item))

  def render_title(_item = %{object: episode = %Episode{}}, assigns), do: render("_episode_title.xml", Map.put(assigns, :episode, Episode.preload_all(episode)))
  def render_title(_item = %{object: post = %Post{}}, assigns), do: render("_post_title.xml", Map.put(assigns, :post, post))
  def render_title(item = %{object: nil}, assigns), do: render("_item_title.xml", Map.put(assigns, :item, item))

  def podcast_title(podcast, episode) do
    title = EpisodeView.numbered_title(episode)

    if Podcast.is_master(podcast) do
      "#{episode.podcast.name} - #{title}"
    else
      title
    end
  end
end
