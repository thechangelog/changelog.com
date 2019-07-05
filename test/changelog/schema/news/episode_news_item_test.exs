defmodule Changelog.EpisodeNewsItemTest do
  use Changelog.SchemaCase

  alias Changelog.{EpisodeNewsItem, EpisodeTopic, NewsItem, Repo}

  test "insert/2 and update/1" do
    episode = insert(:published_episode)
    logger = insert(:person)
    topic1 = insert(:topic)
    topic2 = insert(:topic)

    insert(:episode_topic, episode: episode, topic: topic1)
    insert(:episode_topic, episode: episode, topic: topic2)

    item = EpisodeNewsItem.insert(episode, logger)

    assert item.headline == episode.title
    assert item.story == episode.summary
    assert item.published_at == episode.published_at
    assert NewsItem.preload_topics(item).topics == [topic1, topic2]

    Repo.delete_all(EpisodeTopic)

    episode = Map.merge(episode, %{title: "ohai", summary: "obai"})

    item = EpisodeNewsItem.update(episode)

    assert item.headline == "ohai"
    assert item.story == "obai"
    assert NewsItem.preload_topics(item).topics == []
  end
end
