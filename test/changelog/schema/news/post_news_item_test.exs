defmodule Changelog.PostNewsItemTest do
  use Changelog.SchemaCase

  alias Changelog.{PostNewsItem, PostTopic, NewsItem, Repo}

  test "insert/2 and update/1" do
    post = insert(:published_post)
    logger = insert(:person)
    topic1 = insert(:topic)
    topic2 = insert(:topic)

    insert(:post_topic, post: post, topic: topic1)
    insert(:post_topic, post: post, topic: topic2)

    item = PostNewsItem.insert(post, logger)

    assert item.headline == post.title
    assert item.story == post.tldr
    assert item.published_at == post.published_at
    assert NewsItem.preload_topics(item).topics == [topic1, topic2]

    Repo.delete_all(PostTopic)

    post = Map.merge(post, %{title: "ohai", tldr: "obai"})

    item = PostNewsItem.update(post)

    assert item.headline == "ohai"
    assert item.story == "obai"
    assert NewsItem.preload_topics(item).topics == []
  end
end
