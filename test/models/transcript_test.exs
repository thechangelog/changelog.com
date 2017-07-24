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

  # describe "parse_raw" do
  #   test "The Changelog 200" do
  #     podcast = insert(:podcast, name: "The Changelog")
  #     episode = insert(:episode, slug: "200", title: "JavaScript and Robots", podcast: podcast)
  #     adam = insert(:person, name: "Adam Stacoviak")
  #     jerod = insert(:person, name: "Jerod Santo")
  #     raquel = insert(:person, name: "Raquel Vélez")

  #     insert(:episode_host, episode: episode, person: adam)
  #     insert(:episode_host, episode: episode, person: jerod)
  #     insert(:episode_guest, episode: episode, person: raquel)

  #     raw = File.read!("#{fixtures_path()}/transcripts/the-changelog-200.md")
  #     transcript = %Transcript{episode_id: episode.id, raw: raw}
  #     transcript = Transcript.parse_raw(transcript)

  #     assert length(transcript.fragments) == 400
  #   end
  # end
end
