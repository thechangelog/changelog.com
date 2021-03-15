defmodule Changelog.Policies.Admin.PodcastTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.Podcast

  test "only admins can new/create" do
    for policy <- [:new, :create] do
      refute apply(Podcast, policy, [@guest])
      refute apply(Podcast, policy, [@user])
      refute apply(Podcast, policy, [@editor])
      refute apply(Podcast, policy, [@host])
      assert apply(Podcast, policy, [@admin])
    end
  end

  test "only admins can new/create/edit/update/delete" do
    for policy <- [:edit, :update, :delete] do
      refute apply(Podcast, policy, [@guest, %{}])
      refute apply(Podcast, policy, [@user, %{}])
      refute apply(Podcast, policy, [@editor, %{}])
      refute apply(Podcast, policy, [@host, %{}])
      refute apply(Podcast, policy, [@host, %{active_hosts: [@host]}])
      assert apply(Podcast, policy, [@admin, %{}])
    end
  end

  test "only admins and hosts can get the index" do
    refute Podcast.index(@guest)
    refute Podcast.index(@user)
    refute Podcast.index(@editor)
    assert Podcast.index(@host)
    assert Podcast.index(@admin)
  end

  test "only admins and podcast-specific hosts can show" do
    refute Podcast.show(@guest, %{})
    refute Podcast.show(@user, %{})
    refute Podcast.show(@editor, %{})
    refute Podcast.show(@host, %{})
    assert Podcast.show(@admin, %{})
    assert Podcast.show(@host, %{active_hosts: [@host]})
  end
end
