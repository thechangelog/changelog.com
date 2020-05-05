defmodule Changelog.NewsItemTest do
  use Changelog.SchemaCase

  alias Changelog.{NewsItem, Subscription}

  describe "insert_changeset" do
    test "with valid attributes" do
      changeset =
        NewsItem.insert_changeset(%NewsItem{}, %{
          status: :queued,
          type: :link,
          url: "https://github.com/blog/ohai-there",
          headline: "Big NEWS!",
          logger_id: 1
        })

      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = NewsItem.insert_changeset(%NewsItem{}, %{})
      refute changeset.valid?
    end
  end

  describe "slug" do
    test "downcases, removes non-alpha-numeric, converts spaces to dashes, appends hashid" do
      assert NewsItem.slug(%{id: 1, headline: "Oh! Wow?"}) == "oh-wow-z4"
      assert NewsItem.slug(%{id: 1, headline: "ZOMG 🙌 an ^emoJI@"}) == "zomg-an-emoji-z4"

      assert NewsItem.slug(%{id: 1, headline: "The 4 best things EVAR"}) ==
               "the-4-best-things-evar-z4"

      assert NewsItem.slug(%{id: 1, headline: "🎮 An NES emulator written in Go 🎮"}) ==
               "an-nes-emulator-written-in-go-z4"
    end
  end

  describe "subscribe_participants/1" do
    test "creates subs for all episode participants that haven't disabled the setting" do
      host = insert(:person, handle: "letterman")
      guest1 = insert(:person, handle: "madonna")
      guest2 = insert(:person, handle: "dennis")

      guest3 =
        insert(:person, handle: "leary", settings: %{subscribe_to_participated_episodes: false})

      episode = insert(:published_episode)
      insert(:episode_host, person: host, episode: episode)
      insert(:episode_guest, person: guest1, episode: episode)
      insert(:episode_guest, person: guest2, episode: episode)
      insert(:episode_guest, person: guest3, episode: episode)
      item = episode |> episode_news_item() |> insert()

      NewsItem.subscribe_participants(item)
      subscribed_ids = item |> Subscription.on_item() |> Repo.all() |> Enum.map(& &1.person_id)

      assert Subscription.subscribed_count(item) == 3
      assert Enum.member?(subscribed_ids, host.id)
      assert Enum.member?(subscribed_ids, guest1.id)
      assert Enum.member?(subscribed_ids, guest2.id)
      refute Enum.member?(subscribed_ids, guest3.id)
    end

    test "generates subs for all news item contributors" do
      fred = insert(:person)
      wilma = insert(:person)
      item = insert(:news_item, submitter: fred, author: fred, logger: wilma)

      NewsItem.subscribe_participants(item)
      subscribed_ids = item |> Subscription.on_item() |> Repo.all() |> Enum.map(& &1.person_id)

      assert Subscription.subscribed_count(item) == 2
      assert Enum.member?(subscribed_ids, fred.id)
      assert Enum.member?(subscribed_ids, wilma.id)
    end

    test "does not generate subs for news item contributors who have the setting disabled" do
      fred = insert(:person, settings: %{subscribe_to_contributed_news: false})
      wilma = insert(:person, settings: %{subscribe_to_contributed_news: false})
      item = insert(:news_item, submitter: fred, author: fred, logger: wilma)

      NewsItem.subscribe_participants(item)
      subscribed_ids = item |> Subscription.on_item() |> Repo.all() |> Enum.map(& &1.person_id)

      assert Subscription.subscribed_count(item) == 0
      refute Enum.member?(subscribed_ids, fred.id)
      refute Enum.member?(subscribed_ids, wilma.id)
    end
  end
end
