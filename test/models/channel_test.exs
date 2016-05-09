defmodule Changelog.ChannelTest do
  use Changelog.ModelCase

  alias Changelog.Channel

  @valid_attrs %{name: "Ruby on Rails", slug: "ruby-on-rails"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Channel.changeset(%Channel{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Channel.changeset(%Channel{}, @invalid_attrs)
    refute changeset.valid?
  end
end
