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

  test "handles not loaded associations correctly" do
    user_with_not_loaded = Map.put(@user, :active_membership, %Ecto.Association.NotLoaded{})

    refute Feed.index(user_with_not_loaded)
    refute Feed.new(user_with_not_loaded)
    refute Feed.create(user_with_not_loaded)
    refute Feed.plusplus(user_with_not_loaded)
  end

  test "handles nil associations correctly" do
    user_with_nil_membership = Map.put(@user, :active_membership, nil)

    refute Feed.index(user_with_nil_membership)
    refute Feed.new(user_with_nil_membership)
    refute Feed.create(user_with_nil_membership)
    refute Feed.plusplus(user_with_nil_membership)
  end
end
