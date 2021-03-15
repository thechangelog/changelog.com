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

  describe "recommend_podcasts/2" do
    test "should return a list of similar podcasts" do
      podcast = insert(:podcast)

      author = insert(:person, twitter_handle: "ohai")
      t1 = insert(:topic, name: "iOS", slug: "ios", twitter_handle: "OfficialiOS")
      t2 = insert(:topic, name: "Machine Learning", slug: "machine-learning")

      e1 = insert(:episode, podcast: podcast, slug: "114", audio_bytes: 26_238_621)

      i1 =
        insert(:news_item,
          author: author,
          object_id: "#{podcast.id}:#{e1.id}",
          type: :audio,
          status: :published,
          published_at: NaiveDateTime.utc_now()
        )

      e2 = insert(:episode, podcast: podcast, slug: "181", audio_bytes: 59_310_792)

      i2 =
        insert(:news_item,
          author: author,
          click_count: 10,
          object_id: "#{podcast.id}:#{e2.id}",
          type: :audio,
          status: :published,
          published_at: NaiveDateTime.utc_now()
        )

      e3 = insert(:episode, podcast: podcast, slug: "182", audio_bytes: 56_304_828)

      i3 =
        insert(:news_item,
          author: author,
          click_count: 50,
          object_id: "#{podcast.id}:#{e3.id}",
          type: :audio,
          status: :published,
          published_at: NaiveDateTime.utc_now()
        )

      e4 = insert(:episode, podcast: podcast, slug: "183", audio_bytes: 63_723_737)

      i4 =
        insert(:news_item,
          author: author,
          click_count: 100,
          object_id: "#{podcast.id}:#{e4.id}",
          type: :audio,
          status: :published,
          published_at: NaiveDateTime.utc_now()
        )

      insert(:news_item_topic, news_item: i1, topic: t1)
      insert(:news_item_topic, news_item: i2, topic: t2)
      insert(:news_item_topic, news_item: i3, topic: t2)
      insert(:news_item_topic, news_item: i4, topic: t2)

      i1
      |> NewsItem.load_object()
      |> Repo.preload([:news_item_topics, :topics])

      assert {:ok, [rec1, rec2, rec3]} = NewsItem.recommend_podcasts(e1, 3)
      assert rec1["ranking"] > rec2["ranking"]
      assert rec2["ranking"] > rec3["ranking"]
    end
  end
end
