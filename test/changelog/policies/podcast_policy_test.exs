defmodule Changelog.PodcastPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.PodcastPolicy

  test "only admins can new/create" do
    for policy <- [:new, :create] do
      refute apply(PodcastPolicy, policy, [@guest])
      refute apply(PodcastPolicy, policy, [@user])
      refute apply(PodcastPolicy, policy, [@editor])
      refute apply(PodcastPolicy, policy, [@host])
      assert apply(PodcastPolicy, policy, [@admin])
    end
  end

  test "only admins can new/create/edit/update/delete" do
    for policy <- [:edit, :update, :delete] do
      refute apply(PodcastPolicy, policy, [@guest, %{}])
      refute apply(PodcastPolicy, policy, [@user, %{}])
      refute apply(PodcastPolicy, policy, [@editor, %{}])
      refute apply(PodcastPolicy, policy, [@host, %{}])
      refute apply(PodcastPolicy, policy, [@host, %{hosts: [@host]}])
      assert apply(PodcastPolicy, policy, [@admin, %{}])
    end
  end

  test "only admins and hosts can get the index" do
    refute PodcastPolicy.index(@guest)
    refute PodcastPolicy.index(@user)
    refute PodcastPolicy.index(@editor)
    assert PodcastPolicy.index(@host)
    assert PodcastPolicy.index(@admin)
  end

  test "only admins and podcast-specific hosts can show" do
    refute PodcastPolicy.show(@guest, %{})
    refute PodcastPolicy.show(@user, %{})
    refute PodcastPolicy.show(@editor, %{})
    refute PodcastPolicy.show(@host, %{})
    assert PodcastPolicy.show(@admin, %{})
    assert PodcastPolicy.show(@host, %{hosts: [@host]})
  end
end
