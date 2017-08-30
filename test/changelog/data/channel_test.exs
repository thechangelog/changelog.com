defmodule Changelog.ChannelTest do
  use Changelog.DataCase

  alias Changelog.Channel

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = Channel.admin_changeset(%Channel{}, %{name: "Ruby on Rails", slug: "ruby-on-rails"})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Channel.admin_changeset(%Channel{}, %{})
      refute changeset.valid?
    end
  end
end
