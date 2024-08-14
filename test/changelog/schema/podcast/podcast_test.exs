defmodule Changelog.PodcastTest do
  use Changelog.SchemaCase

  alias Changelog.Podcast

  describe "insert_changeset" do
    test "with valid attributes" do
      changeset =
        Podcast.insert_changeset(%Podcast{}, %{
          slug: "the-bomb-show",
          name: "The Bomb Show",
          status: :draft
        })

      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Podcast.insert_changeset(%Podcast{}, %{})
      refute changeset.valid?
    end
  end

  test "episode_count returns count of associated eps" do
    podcast = insert(:podcast)
    assert Podcast.episode_count(podcast) == 0
    insert(:published_episode, podcast: podcast)
    insert(:episode, podcast: podcast)
    assert Podcast.episode_count(podcast) == 2
  end

  test "published_episode_count returns count of associated published eps" do
    podcast = insert(:podcast)
    assert Podcast.published_episode_count(podcast) == 0
    insert(:published_episode, podcast: podcast)
    insert(:episode, podcast: podcast)
    assert Podcast.published_episode_count(podcast) == 1
  end

  describe "update_stat_counts/1" do
    setup do
      {:ok, podcast: insert(:podcast)}
    end

    test "it is 0 when podcast has no episodes/downloads", %{podcast: podcast} do
      podcast = Podcast.update_stat_counts(podcast)
      assert podcast.download_count == 0
    end

    test "it is the sum of episode downloads, reach when there are some", %{podcast: podcast} do
      insert(:episode, download_count: 845.34, reach_count: 33, podcast: podcast)
      insert(:episode, download_count: 1095.38, reach_count: 232, podcast: podcast)
      insert(:episode, download_count: 50.5, reach_count: 123)

      podcast = Podcast.update_stat_counts(podcast)

      assert podcast.download_count == 1940.72
      assert podcast.reach_count == 265
    end
  end

  describe "update_subscribers/1" do
    setup do
      {:ok, podcast: insert(:podcast)}
    end

    test "it uses the most recent feed stats, ignoring < 5 subs", %{podcast: podcast} do
      insert(:feed_stat, date: ~D[2024-01-01], podcast: podcast, agents: %{
        "Overcast" => %{
          "raw" => "Overcast/1.0 Podcast Sync (993 subscribers; feed-id=554901; +http://overcast.fm/)"
        },
        "Player FM" => %{
          "raw" => "PlayerFM/1.0 Podcast Sync (5033 subscribers; url=https://player.fm/series/the-changelog-1282967)"
        },
        "Castro" => %{
          "raw" => "Castro 2 Episode Download (1000 subscribers)"
        },
        "Fake Castro" => %{
          "raw" => "Fake Castro 2 Episode Download (3 subscribers)"
        }
      })

      podcast = Podcast.update_subscribers(podcast)

      assert podcast.subscribers["Overcast"] == 993
      assert podcast.subscribers["Player FM"] == 5033
      assert podcast.subscribers["Castro"] == 1000
      assert podcast.subscribers["Fake Castro"] == nil

      insert(:feed_stat, date: ~D[2024-01-02], podcast: podcast, agents: %{
        "Overcast" => %{
          "raw" => "Overcast/1.0 Podcast Sync (994 subscribers; feed-id=554901; +http://overcast.fm/)"
        },
        "Player FM" => %{
          "raw" => "PlayerFM/1.0 Podcast Sync (5133 subscribers; url=https://player.fm/series/the-changelog-1282967)"
        }
      })

      podcast = Podcast.update_subscribers(podcast)

      assert podcast.subscribers["Overcast"] == 994
      assert podcast.subscribers["Player FM"] == 5133
      assert podcast.subscribers["Castro"] == 1000
    end
  end
end
