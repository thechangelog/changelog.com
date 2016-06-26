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
end
