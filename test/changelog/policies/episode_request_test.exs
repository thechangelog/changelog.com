defmodule Changelog.Policies.EpisodeRequestTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins and podcast hosts can get the index" do
    refute Policies.EpisodeRequest.index(@guest, %{})
    refute Policies.EpisodeRequest.index(@user, %{})
    refute Policies.EpisodeRequest.index(@editor, %{})
    refute Policies.EpisodeRequest.index(@host, %{})
    assert Policies.EpisodeRequest.index(@admin, %{})
    assert Policies.EpisodeRequest.index(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can show" do
    refute Policies.EpisodeRequest.show(@guest, %{})
    refute Policies.EpisodeRequest.show(@user, %{})
    refute Policies.EpisodeRequest.show(@editor, %{})
    refute Policies.EpisodeRequest.show(@host, %{})
    assert Policies.EpisodeRequest.show(@admin, %{})
    assert Policies.EpisodeRequest.show(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can edit/update/decline/fail/pend" do
    refute Policies.EpisodeRequest.edit(@guest, %{})
    refute Policies.EpisodeRequest.update(@user, %{})
    refute Policies.EpisodeRequest.update(@editor, %{})
    refute Policies.EpisodeRequest.edit(@host, %{})
    refute Policies.EpisodeRequest.decline(@host, %{})
    assert Policies.EpisodeRequest.update(@admin, %{})
    assert Policies.EpisodeRequest.edit(@host, %{hosts: [@host]})
    assert Policies.EpisodeRequest.decline(@host, %{hosts: [@host]})
    refute Policies.EpisodeRequest.fail(@host, %{})
    assert Policies.EpisodeRequest.fail(@host, %{hosts: [@host]})
    refute Policies.EpisodeRequest.pend(@host, %{})
    assert Policies.EpisodeRequest.pend(@admin, %{})
  end

  test "only admins can delete" do
    for policy <- [:delete] do
      refute apply(Policies.EpisodeRequest, policy, [@guest, %{}])
      refute apply(Policies.EpisodeRequest, policy, [@user, %{}])
      refute apply(Policies.EpisodeRequest, policy, [@editor, %{}])
      refute apply(Policies.EpisodeRequest, policy, [@host, %{}])
      assert apply(Policies.EpisodeRequest, policy, [@admin, %{}])
    end
  end
end
