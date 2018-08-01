defmodule Changelog.Policies.EpisodeTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins and podcast hosts can new/create" do
    refute Policies.Episode.create(@guest, %{})
    refute Policies.Episode.new(@user, %{})
    refute Policies.Episode.new(@editor, %{})
    refute Policies.Episode.new(@host, %{})
    assert Policies.Episode.create(@admin, %{})
    assert Policies.Episode.create(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can get the index" do
    refute Policies.Episode.index(@guest, %{})
    refute Policies.Episode.index(@user, %{})
    refute Policies.Episode.index(@editor, %{})
    refute Policies.Episode.index(@host, %{})
    assert Policies.Episode.index(@admin, %{})
    assert Policies.Episode.index(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can show" do
    refute Policies.Episode.show(@guest, %{})
    refute Policies.Episode.show(@user, %{})
    refute Policies.Episode.show(@editor, %{})
    refute Policies.Episode.show(@host, %{})
    assert Policies.Episode.show(@admin, %{})
    assert Policies.Episode.show(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can edit/update" do
    refute Policies.Episode.edit(@guest, %{})
    refute Policies.Episode.update(@user, %{})
    refute Policies.Episode.update(@editor, %{})
    refute Policies.Episode.edit(@host, %{})
    assert Policies.Episode.update(@admin, %{})
    assert Policies.Episode.edit(@host, %{hosts: [@host]})
  end

  test "only admins can delete/publish/unpublish" do
    for policy <- [:delete, :publish, :unpublish] do
      refute apply(Policies.Episode, policy, [@guest, %{}])
      refute apply(Policies.Episode, policy, [@user, %{}])
      refute apply(Policies.Episode, policy, [@editor, %{}])
      refute apply(Policies.Episode, policy, [@host, %{}])
      assert apply(Policies.Episode, policy, [@admin, %{}])
    end
  end
end
