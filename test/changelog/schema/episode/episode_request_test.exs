defmodule Changelog.EpisodeRequestTest do
  use Changelog.SchemaCase

  alias Changelog.EpisodeRequest

  describe "submission_changeset/2" do
    test "valid attributes" do
      changeset =
        EpisodeRequest.submission_changeset(%EpisodeRequest{}, %{
          pitch: "You gonna love this",
          submitter_id: 1,
          podcast_id: 1
        })

      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeRequest.submission_changeset(%EpisodeRequest{}, %{pitch: "whoops"})
      refute changeset.valid?
    end
  end
end
