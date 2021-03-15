defmodule Changelog.Policies.Admin.EpisodeRequestTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.EpisodeRequest

  test "only admins and podcast hosts can get the index" do
    refute EpisodeRequest.index(@guest, %{})
    refute EpisodeRequest.index(@user, %{})
    refute EpisodeRequest.index(@editor, %{})
    refute EpisodeRequest.index(@host, %{})
    assert EpisodeRequest.index(@admin, %{})
    assert EpisodeRequest.index(@host, %{active_hosts: [@host]})
  end

  test "only admins and podcast hosts can show" do
    refute EpisodeRequest.show(@guest, %{})
    refute EpisodeRequest.show(@user, %{})
    refute EpisodeRequest.show(@editor, %{})
    refute EpisodeRequest.show(@host, %{})
    assert EpisodeRequest.show(@admin, %{})
    assert EpisodeRequest.show(@host, %{active_hosts: [@host]})
  end

  test "only admins and podcast hosts can edit/update/decline/fail/pend" do
    refute EpisodeRequest.edit(@guest, %{})
    refute EpisodeRequest.update(@user, %{})
    refute EpisodeRequest.update(@editor, %{})
    refute EpisodeRequest.edit(@host, %{})
    refute EpisodeRequest.decline(@host, %{})
    assert EpisodeRequest.update(@admin, %{})
    assert EpisodeRequest.edit(@host, %{active_hosts: [@host]})
    assert EpisodeRequest.decline(@host, %{active_hosts: [@host]})
    refute EpisodeRequest.fail(@host, %{})
    assert EpisodeRequest.fail(@host, %{active_hosts: [@host]})
    refute EpisodeRequest.pend(@host, %{})
    assert EpisodeRequest.pend(@admin, %{})
  end

  test "only admins can delete" do
    for policy <- [:delete] do
      refute apply(EpisodeRequest, policy, [@guest, %{}])
      refute apply(EpisodeRequest, policy, [@user, %{}])
      refute apply(EpisodeRequest, policy, [@editor, %{}])
      refute apply(EpisodeRequest, policy, [@host, %{}])
      assert apply(EpisodeRequest, policy, [@admin, %{}])
    end
  end
end
