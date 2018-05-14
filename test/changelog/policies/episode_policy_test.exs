defmodule Changelog.EpisodePolicyTest do
  use ExUnit.Case

  alias Changelog.EpisodePolicy

  @guest nil
  @user %{id: 1, admin: false}
  @admin %{id: 2, admin: true}
  @host %{id: 3, host: true}

  test "only admins and podcast hosts can new/create" do
    refute EpisodePolicy.create(@guest, %{})
    refute EpisodePolicy.new(@user, %{})
    refute EpisodePolicy.new(@host, %{})
    assert EpisodePolicy.create(@admin, %{})
    assert EpisodePolicy.create(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can get the index" do
    refute EpisodePolicy.index(@guest, %{})
    refute EpisodePolicy.index(@user, %{})
    refute EpisodePolicy.index(@host, %{})
    assert EpisodePolicy.index(@admin, %{})
    assert EpisodePolicy.index(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can show" do
    refute EpisodePolicy.show(@guest, %{})
    refute EpisodePolicy.show(@user, %{})
    refute EpisodePolicy.show(@host, %{})
    assert EpisodePolicy.show(@admin, %{})
    assert EpisodePolicy.show(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can edit/update" do
    refute EpisodePolicy.edit(@guest, %{})
    refute EpisodePolicy.update(@user, %{})
    refute EpisodePolicy.edit(@host, %{})
    assert EpisodePolicy.update(@admin, %{})
    assert EpisodePolicy.edit(@host, %{hosts: [@host]})
  end

  test "only admins can delete" do
    refute EpisodePolicy.delete(@guest, %{})
    refute EpisodePolicy.delete(@user, %{})
    refute EpisodePolicy.delete(@host, %{})
    assert EpisodePolicy.delete(@admin, %{})
  end
end
