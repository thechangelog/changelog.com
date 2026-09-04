defmodule Changelog.EpisodeNewsItemTest do
  use Changelog.SchemaCase

  import Mock

  alias Changelog.{EpisodeNewsItem, EpisodeTopic, NewsItem, Repo, TypesenseSearch}

  setup_with_mocks([{TypesenseSearch, [], [update_item: fn _ -> :ok end]}], _context) do
    :ok
  end

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

  test "insert/3 reconciles the canonical item instead of creating a duplicate" do
    episode = insert(:published_episode, title: "Original", summary: "First")
    logger_1 = insert(:person)
    logger_2 = insert(:person)

    item = EpisodeNewsItem.insert(episode, logger_1, true)

    updated_episode =
      episode
      |> Ecto.Changeset.change(title: "Updated", summary: "Second")
      |> Repo.update!()

    updated_item = EpisodeNewsItem.insert(updated_episode, logger_2, false)

    assert Repo.aggregate(NewsItem.with_episode(updated_episode), :count) == 1
    assert updated_item.id == item.id
    assert updated_item.feed_only == false
    assert updated_item.logger_id == logger_2.id
    assert updated_item.headline == "Updated"
    assert updated_item.story == "Second"
  end

  test "feed-only retries do not demote an existing non-feed-only canonical item" do
    episode = insert(:published_episode)
    logger = insert(:person)

    item = EpisodeNewsItem.insert(episode, logger, false)
    retried_item = EpisodeNewsItem.insert(episode, logger, true)

    assert Repo.aggregate(NewsItem.with_episode(episode), :count) == 1
    assert retried_item.id == item.id
    assert retried_item.feed_only == false
  end

  test "insert_published_feed_only_once/2 does not mutate an existing canonical item" do
    episode = insert(:published_episode)
    logger = insert(:person)

    item = EpisodeNewsItem.insert(episode, logger, false)

    assert {:existing, existing_item} =
             EpisodeNewsItem.insert_published_feed_only_once(episode, logger)

    assert existing_item.id == item.id
    assert Repo.get!(NewsItem, item.id).feed_only == false
  end
end
