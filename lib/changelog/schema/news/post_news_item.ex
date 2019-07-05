defmodule Changelog.PostNewsItem do
  use Changelog.Schema

  alias Changelog.{Post, NewsItem, Search}
  alias ChangelogWeb.PostView

  def insert(post, logger) do
    %NewsItem{
      type: :link,
      object_id: Post.object_id(post),
      url: PostView.url(post, :show),
      headline: post.title,
      story: post.tldr,
      published_at: post.published_at,
      logger_id: logger.id,
      news_item_topics: post_topics(post)}
    |> NewsItem.insert_changeset()
    |> Repo.insert!()
  end

  def update(post) do
    if item = Post.get_news_item(post) do
      item
      |> NewsItem.preload_topics()
      |> change(%{
        headline: post.title,
        story: post.tldr,
        news_item_topics: post_topics(post)})
      |> Repo.update!()
      |> update_search()
    end
  end

  defp post_topics(post) do
    post
    |> Post.preload_topics()
    |> Map.get(:post_topics)
    |> Enum.map(fn(t) -> Map.take(t, [:topic_id, :position]) end)
  end

  defp update_search(item) do
    Task.start_link(fn -> Search.update_item(item) end)
    item
  end
end
