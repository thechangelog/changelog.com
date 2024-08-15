defmodule Changelog.FeedTest do
  use Changelog.SchemaCase

  alias Changelog.Feed

  @valid_attrs %{name: "Custom Feed", owner_id: 1}
  @invalid_attrs %{}

  test "insert_changeset/2 with valid attributes" do
    changeset = Feed.insert_changeset(%Feed{}, @valid_attrs)
    assert changeset.valid?
  end

  test "insert_changeset/2 with invalid attributes" do
    changeset = Feed.insert_changeset(%Feed{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "update_agents/1" do
    setup do
      {:ok, feed: insert(:feed)}
    end

    test "it uses the most recent feed stats", %{feed: feed} do
      insert(:feed_stat, date: ~D[2024-01-01], feed: feed, agents: %{
        "PocketCasts" => %{
          "raw" => "PocketCasts/1.0 (Pocket Casts Feed Parser; +http://pocketcasts.com/)"
        },
        "Player FM" => %{
          "raw" => "PlayerFM/1.0 Podcast Sync"
        },
        "Castro" => %{
          "raw" => "Castro 2 Episode Download (1000 subscribers)"
        }
      })

      feed = Feed.update_agents(feed)

      assert length(feed.agents) == 3

      insert(:feed_stat, date: ~D[2024-01-02], feed: feed, agents: %{
        "PocketCasts" => %{
          "raw" => "PocketCasts/1.0 (Pocket Casts Feed Parser; +http://pocketcasts.com/)"
        },
        "Deno" => %{
          "raw" => "Deno 1.23"
        }
      })

      feed = Feed.update_agents(feed)

      assert length(feed.agents) == 4
    end
  end
end
