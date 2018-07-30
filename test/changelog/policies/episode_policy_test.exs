defmodule Changelog.EpisodePolicyTest do
  use Changelog.PolicyCase

  alias Changelog.EpisodePolicy

  test "only admins and podcast hosts can new/create" do
    refute EpisodePolicy.create(@guest, %{})
    refute EpisodePolicy.new(@user, %{})
    refute EpisodePolicy.new(@editor, %{})
    refute EpisodePolicy.new(@host, %{})
    assert EpisodePolicy.create(@admin, %{})
    assert EpisodePolicy.create(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can get the index" do
    refute EpisodePolicy.index(@guest, %{})
    refute EpisodePolicy.index(@user, %{})
    refute EpisodePolicy.index(@editor, %{})
    refute EpisodePolicy.index(@host, %{})
    assert EpisodePolicy.index(@admin, %{})
    assert EpisodePolicy.index(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can show" do
    refute EpisodePolicy.show(@guest, %{})
    refute EpisodePolicy.show(@user, %{})
    refute EpisodePolicy.show(@editor, %{})
    refute EpisodePolicy.show(@host, %{})
    assert EpisodePolicy.show(@admin, %{})
    assert EpisodePolicy.show(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can edit/update" do
    refute EpisodePolicy.edit(@guest, %{})
    refute EpisodePolicy.update(@user, %{})
    refute EpisodePolicy.update(@editor, %{})
    refute EpisodePolicy.edit(@host, %{})
    assert EpisodePolicy.update(@admin, %{})
    assert EpisodePolicy.edit(@host, %{hosts: [@host]})
  end

  test "only admins can delete/publish/unpublish" do
    for policy <- [:delete, :publish, :unpublish] do
      refute apply(EpisodePolicy, policy, [@guest, %{}])
      refute apply(EpisodePolicy, policy, [@user, %{}])
      refute apply(EpisodePolicy, policy, [@editor, %{}])
      refute apply(EpisodePolicy, policy, [@host, %{}])
      assert apply(EpisodePolicy, policy, [@admin, %{}])
    end
  end
end
