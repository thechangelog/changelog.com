defmodule Changelog.EpisodeTest do
  use Changelog.SchemaCase

  import Mock

  alias Changelog.{Episode}

  describe "admin_changeset/2" do
    test "with valid attributes" do
      changeset = Episode.admin_changeset(%Episode{}, %{slug: "181", title: "some content"})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Episode.admin_changeset(%Episode{}, %{})
      refute changeset.valid?
    end

    test "purges audio-related attrs whenever slug changes" do
      episode = build(:episode,
        audio_file: %{file_name: "test.mp3"},
        audio_bytes: 42,
        audio_duration: 2600,
        plusplus_file: %{file_name: "test++.mp3"},
        plusplus_bytes: 43,
        plusplus_duration: 600)

      changeset = Episode.admin_changeset(episode, %{slug: "newslug"})

      for attr <- [:audio_file, :audio_bytes, :audio_duration, :plusplus_file, :plusplus_bytes, :plusplus_duration] do
        assert Map.has_key?(changeset.changes, attr)
      end
    end

    test "doesn't purge audio-related attrs whenever slug doesn't change" do
      episode = build(:episode,
        audio_file: %{file_name: "test.mp3"},
        audio_bytes: 42,
        audio_duration: 2600,
        plusplus_file: %{file_name: "test++.mp3"},
        plusplus_bytes: 43,
        plusplus_duration: 600)

      changeset = Episode.admin_changeset(episode, %{title: "new title"})

      for attr <- [:audio_file, :audio_bytes, :audio_duration, :plusplus_file, :plusplus_bytes, :plusplus_duration] do
        refute Map.has_key?(changeset.changes, attr)
      end
    end
  end

  test "with_numbered_slug" do
    insert(:episode, slug: "bonus-episode-dont-find-me")

    yes1 = insert(:episode, slug: "204")
    yes2 = insert(:episode, slug: "99")

    found_titles =
      Episode.with_numbered_slug()
      |> Repo.all()
      |> Enum.map(& &1.title)

    assert found_titles == [yes1.title, yes2.title]
  end

  describe "update_stat_counts" do
    test "it defaults to 0 when episode has no imports or stats" do
      episode = insert(:episode, import_count: 0.0)
      episode = Episode.update_stat_counts(episode)
      assert episode.download_count == 0
      assert episode.reach_count == 0
    end

    test "it uses import count when episode has import count but not stats" do
      episode = insert(:episode, import_count: 83.3)
      episode = Episode.update_stat_counts(episode)
      assert episode.download_count == 83.3
    end

    test "it adds together import count and stat downloads counts, sums uniques" do
      episode = insert(:episode, import_count: 98.5)
      insert(:episode_stat, date: ~D[2016-01-01], episode: episode, downloads: 100.75, uniques: 4)
      insert(:episode_stat, date: ~D[2016-01-02], episode: episode, downloads: 84.0, uniques: 45)
      insert(:episode_stat, date: ~D[2016-01-03], episode: episode, downloads: 53.4)
      insert(:episode_stat, downloads: 100.0)
      episode = Episode.update_stat_counts(episode)
      assert episode.download_count == 98.5 + 100.75 + 84 + 53.4
      assert episode.reach_count == 4 + 45
    end
  end

  describe "update_transcript/2" do
    test "it opens a GitHub issue when transcript parsing fails" do
      with_mocks([
        {Changelog.Transcripts.Parser, [], [parse_text: fn _, _ -> {:error, "whoops"} end]},
        {Changelog.Github.Issuer, [], [create: fn _, _ -> {:ok, "it worked"} end]}
      ]) do
        episode = insert(:episode)
        Episode.update_transcript(episode, "Kaizen!\n")
        assert called(Changelog.Transcripts.Parser.parse_text(:_, :_))
        assert called(Changelog.Github.Issuer.create(:_, :_))
      end
    end

    test "it calls the Notifier when transcript is first set" do
      with_mocks([
        {Changelog.Notifier, [], [notify: fn _ -> true end]},
        {Changelog.TypesenseSearch, [], [save_item: fn _ -> true end]}
      ]) do
        episode = insert(:episode)
        Episode.update_transcript(episode, "**Host:** Welcome!\n\n**Guest:** Thanks!\n\n")

        wait_for_passing(1000, fn ->
          assert called(Changelog.Notifier.notify(:_))
          assert called(Changelog.TypesenseSearch.save_item(:_))
        end)
      end
    end

    test "it does not call the Notifier when transcript is updated" do
      with_mocks([
        {Changelog.Notifier, [], [notify: fn _ -> true end]},
        {Changelog.TypesenseSearch, [], [save_item: fn _ -> true end]}
      ]) do
        episode =
          insert(:episode,
            transcript: [%{"title" => "Host", "person_id" => nil, "text" => "Welcome!"}]
          )

        Episode.update_transcript(episode, "**Host:** Welcome!")

        wait_for_passing(1000, fn ->
          assert called(Changelog.TypesenseSearch.save_item(:_))
          refute called(Changelog.Notifier.notify(:_))
        end)
      end
    end

    test "it does not call the Notifier when transcript is not set" do
      with_mocks([
        {Changelog.Notifier, [], [notify: fn _ -> true end]},
        {Changelog.TypesenseSearch, [], [save_item: fn _ -> true end]}
      ]) do
        episode = insert(:episode)
        Episode.update_transcript(episode, "")

        wait_for_passing(1000, fn ->
          assert called(Changelog.TypesenseSearch.save_item(:_))
          refute called(Changelog.Notifier.notify(:_))
        end)
      end
    end
  end

  describe "search" do
    setup do
      {:ok,
       phoenix:
         insert(:published_episode,
           slug: "phoenix-episode",
           title: "Phoenix",
           summary: "A web framework for Elixir",
           notes: "Chris McCord"
         ),
       rails:
         insert(:published_episode,
           slug: "rails-episode",
           title: "Rails",
           summary: "A web framework for Ruby",
           notes: "DHH"
         )}
    end

    test "finds episode by matching title" do
      episode_titles =
        Episode
        |> Episode.search("Rails")
        |> Repo.all()
        |> Enum.map(& &1.title)

      assert episode_titles == ["Rails"]
    end

    test "finds episode by matching summary" do
      episode_titles =
        Episode
        |> Episode.search("Elixir")
        |> Repo.all()
        |> Enum.map(& &1.title)

      assert episode_titles == ["Phoenix"]
    end

    test "finds episode by matching notes" do
      episode_titles =
        Episode
        |> Episode.search("McCord")
        |> Repo.all()
        |> Enum.map(& &1.title)

      assert episode_titles == ["Phoenix"]
    end
  end

  describe "sponsors_duration/1" do
    test "episode where all sponsors have timestamps" do
      sponsors = [
        %{starts_at: 12.5, ends_at: 72.5},
        %{starts_at: 345, ends_at: 436.3},
        %{starts_at: 123.456, ends_at: 564.12}
      ]

      episode = build(:episode, episode_sponsors: sponsors)

      assert Episode.sponsors_duration(episode) == 592
    end

    test "episode with chapters and some start/end timestamps" do
      sponsors = [
        %{starts_at: nil, ends_at: nil},
        %{starts_at: 12.0, ends_at: nil},
        %{starts_at: 0, ends_at: 345}
      ]

      episode = build(:episode, episode_sponsors: sponsors, audio_chapters: [%{}])

      assert Episode.sponsors_duration(episode) == 0 + 0 + 345
    end

    test "episode without chapters and some start/end timestamps" do
      sponsors = [
        %{starts_at: nil, ends_at: nil},
        %{starts_at: 12.0, ends_at: nil},
        %{starts_at: 0, ends_at: 345}
      ]

      episode = build(:episode, episode_sponsors: sponsors, audio_chapters: [])

      assert Episode.sponsors_duration(episode) == 60 + 60 + 345
    end
  end

  describe "has_transcript/1" do
    test "is false when transcript is nil" do
      refute Episode.has_transcript(build(:episode, transcript: nil))
    end

    test "is false when transcript is nil and has_transcript virtual field is false" do
      refute Episode.has_transcript(build(:episode, transcript: nil, has_transcript: false))
    end

    test "is false when transcript is empty" do
      refute Episode.has_transcript(build(:episode, transcript: []))
    end

    test "is true when transcript is nil (due to exclusion) but has_transcript is true" do
      assert Episode.has_transcript(build(:episode, transcript: nil, has_transcript: true))
    end

    test "is true otherwise" do
      assert Episode.has_transcript(build(:episode, transcript: [{}]))
    end
  end

  describe "is_public/1" do
    test "is false when episode isn't published" do
      refute Episode.is_public(build(:episode))
    end

    test "is false when episode is published but in the future" do
      refute Episode.is_public(build(:scheduled_episode))
    end

    test "is true when episode is published in the past" do
      assert Episode.is_public(build(:published_episode))
    end
  end

  describe "is_publishable/1" do
    test "is false when episode is missing required fields" do
      refute Episode.is_publishable(insert(:episode))
    end

    test "is false when episode is published" do
      refute Episode.is_publishable(insert(:published_episode))
    end

    test "is false when episode is News but missing email fields" do
      news = insert(:podcast, slug: "news")
      episode = stub_audio_file(insert(:publishable_episode, podcast: news))
      refute Episode.is_publishable(episode)
    end

    test "is true when episode has all fields and isn't published" do
      assert Episode.is_publishable(stub_audio_file(insert(:publishable_episode)))
    end
  end
end
