defmodule Changelog.TranscriptTest do
  use Changelog.ModelCase

  alias Changelog.Transcript

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = Transcript.admin_changeset(%Transcript{}, %{episode_id: 1, raw: "ohai"})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Transcript.admin_changeset(%Transcript{}, %{})
      refute changeset.valid?
    end
  end

  describe "update_fragments" do
    test "The Changelog 200" do
      podcast = insert(:podcast, name: "The Changelog")
      episode = insert(:episode, slug: "200", title: "JavaScript and Robots", podcast: podcast)
      adam = insert(:person, name: "Adam Stacoviak")
      jerod = insert(:person, name: "Jerod Santo")
      raquel = insert(:person, name: "Raquel Vélez")

      insert(:episode_host, episode: episode, person: adam)
      insert(:episode_host, episode: episode, person: jerod)
      insert(:episode_guest, episode: episode, person: raquel)

      raw = File.read!("#{fixtures_path()}/transcripts/the-changelog-200.md")

      transcript = insert(:transcript, episode: episode, raw: raw)
      transcript = Transcript.update_fragments(transcript)

      assert length(transcript.fragments) == 216

      people_ids =
        transcript.fragments
        |> Enum.map(&(&1.person_id))
        |> Enum.uniq
        |> Enum.reject(&is_nil/1)

      assert people_ids == [adam.id, jerod.id, raquel.id]

      titles =
        transcript.fragments
        |> Enum.map(&(&1.title))
        |> Enum.uniq

      assert titles == ["Adam Stacoviak", "Jerod Santo", "Raquel Vélez", "Break"]
    end
  end
end
