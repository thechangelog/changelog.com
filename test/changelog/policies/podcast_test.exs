defmodule Changelog.Policies.PodcastTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins can new/create" do
    for policy <- [:new, :create] do
      refute apply(Policies.Podcast, policy, [@guest])
      refute apply(Policies.Podcast, policy, [@user])
      refute apply(Policies.Podcast, policy, [@editor])
      refute apply(Policies.Podcast, policy, [@host])
      assert apply(Policies.Podcast, policy, [@admin])
    end
  end

  test "only admins can new/create/edit/update/delete" do
    for policy <- [:edit, :update, :delete] do
      refute apply(Policies.Podcast, policy, [@guest, %{}])
      refute apply(Policies.Podcast, policy, [@user, %{}])
      refute apply(Policies.Podcast, policy, [@editor, %{}])
      refute apply(Policies.Podcast, policy, [@host, %{}])
      refute apply(Policies.Podcast, policy, [@host, %{hosts: [@host]}])
      assert apply(Policies.Podcast, policy, [@admin, %{}])
    end
  end

  test "only admins and hosts can get the index" do
    refute Policies.Podcast.index(@guest)
    refute Policies.Podcast.index(@user)
    refute Policies.Podcast.index(@editor)
    assert Policies.Podcast.index(@host)
    assert Policies.Podcast.index(@admin)
  end

  test "only admins and podcast-specific hosts can show" do
    refute Policies.Podcast.show(@guest, %{})
    refute Policies.Podcast.show(@user, %{})
    refute Policies.Podcast.show(@editor, %{})
    refute Policies.Podcast.show(@host, %{})
    assert Policies.Podcast.show(@admin, %{})
    assert Policies.Podcast.show(@host, %{hosts: [@host]})
  end
end
