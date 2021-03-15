defmodule Changelog.Policies.Admin.EpisodeTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.Episode

  test "only admins and podcast hosts can new/create/index/show/edit/update/delete" do
    for policy <- [:new, :create, :index, :show, :edit, :update, :delete] do
      refute apply(Episode, policy, [@guest, %{}])
      refute apply(Episode, policy, [@user, %{}])
      refute apply(Episode, policy, [@editor, %{}])
      refute apply(Episode, policy, [@host, %{}])
      assert apply(Episode, policy, [@admin, %{}])
      assert apply(Episode, policy, [@host, %{active_hosts: [@host]}])
    end
  end

  test "only admins can publish/unpublish" do
    for policy <- [:publish, :unpublish] do
      refute apply(Episode, policy, [@guest, %{}])
      refute apply(Episode, policy, [@user, %{}])
      refute apply(Episode, policy, [@editor, %{}])
      refute apply(Episode, policy, [@host, %{}])
      refute apply(Episode, policy, [@host, %{active_hosts: [@host]}])
      assert apply(Episode, policy, [@admin, %{}])
    end
  end
end
