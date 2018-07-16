defmodule Changelog.PodcastPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.PodcastPolicy

  test "only admins can new/create" do
    refute PodcastPolicy.create(@guest)
    refute PodcastPolicy.new(@user)
    refute PodcastPolicy.new(@editor)
    refute PodcastPolicy.new(@host)
    assert PodcastPolicy.create(@admin)
  end

  test "only admins can get the index" do
    refute PodcastPolicy.index(@guest)
    refute PodcastPolicy.index(@user)
    refute PodcastPolicy.index(@editor)
    refute PodcastPolicy.index(@host)
    assert PodcastPolicy.index(@admin)
  end

  test "only admins can and podcast hosts can show" do
    refute PodcastPolicy.show(@guest, %{})
    refute PodcastPolicy.show(@user, %{})
    refute PodcastPolicy.show(@editor, %{})
    refute PodcastPolicy.show(@host, %{})
    assert PodcastPolicy.show(@admin, %{})
    assert PodcastPolicy.show(@host, %{hosts: [@host]})
  end

  test "only admins and podcast hosts can edit/update" do
    refute PodcastPolicy.edit(@guest, %{})
    refute PodcastPolicy.update(@user, %{})
    refute PodcastPolicy.update(@editor, %{})
    refute PodcastPolicy.edit(@host, %{})
    assert PodcastPolicy.update(@admin, %{})
    assert PodcastPolicy.edit(@host, %{hosts: [@host]})
  end

  test "only admins can delete" do
    refute PodcastPolicy.delete(@guest, %{})
    refute PodcastPolicy.delete(@user, %{})
    refute PodcastPolicy.delete(@editor, %{})
    refute PodcastPolicy.delete(@host, %{})
    assert PodcastPolicy.delete(@admin, %{})
  end
end
