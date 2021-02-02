defmodule Changelog.Policies.EpisodeTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins and podcast hosts can new/create/index/show/edit/update/delete" do
    for policy <- [:new, :create, :index, :show, :edit, :update, :delete] do
      refute apply(Policies.Episode, policy, [@guest, %{}])
      refute apply(Policies.Episode, policy, [@user, %{}])
      refute apply(Policies.Episode, policy, [@editor, %{}])
      refute apply(Policies.Episode, policy, [@host, %{}])
      assert apply(Policies.Episode, policy, [@admin, %{}])
      assert apply(Policies.Episode, policy, [@host, %{active_hosts: [@host]}])
    end
  end

  test "only admins can publish/unpublish" do
    for policy <- [:publish, :unpublish] do
      refute apply(Policies.Episode, policy, [@guest, %{}])
      refute apply(Policies.Episode, policy, [@user, %{}])
      refute apply(Policies.Episode, policy, [@editor, %{}])
      refute apply(Policies.Episode, policy, [@host, %{}])
      refute apply(Policies.Episode, policy, [@host, %{active_hosts: [@host]}])
      assert apply(Policies.Episode, policy, [@admin, %{}])
    end
  end
end
