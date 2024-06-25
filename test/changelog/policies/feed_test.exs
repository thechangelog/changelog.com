defmodule Changelog.Policies.FeedTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Feed

  test "only active members can index" do
    refute Feed.index(@guest)
    assert Feed.index(@member)
  end

  test "only active members can new/create" do
    refute Feed.new(@user)
    assert Feed.new(@member)

    refute Feed.create(@guest)
    assert Feed.create(@member)
  end

  test "only active members can manage their own feeds" do
    refute Feed.update(@user, %{owner: @member})
    assert Feed.update(@member, %{owner: @member})

    refute Feed.delete(@user, %{owner: @member})
    assert Feed.delete(@member, %{owner: @member})
  end
end
