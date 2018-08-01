defmodule Changelog.Policies.NewsItemTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins and editors can new/create" do
    refute Policies.NewsItem.create(@guest)
    refute Policies.NewsItem.new(@user)
    refute Policies.NewsItem.new(@host)
    assert Policies.NewsItem.create(@admin)
    assert Policies.NewsItem.new(@editor)
  end

  test "only admins and editors can get the index" do
    refute Policies.NewsItem.index(@guest)
    refute Policies.NewsItem.index(@user)
    refute Policies.NewsItem.index(@host)
    assert Policies.NewsItem.index(@admin)
    assert Policies.NewsItem.index(@editor)
  end

  test "only admins and item logger can edit/update" do
    refute Policies.NewsItem.edit(@guest, %{})
    refute Policies.NewsItem.update(@user, %{})
    refute Policies.NewsItem.update(@editor, %{})
    refute Policies.NewsItem.edit(@host, %{})
    assert Policies.NewsItem.update(@admin, %{})
    assert Policies.NewsItem.edit(@editor, %{logger: @editor})
  end

  test "only admins can move/decline/unpublish/delete" do
    for policy <- [:move, :decline, :unpublish, :delete] do
      refute apply(Policies.NewsItem, policy, [@guest, %{}])
      refute apply(Policies.NewsItem, policy, [@user, %{}])
      refute apply(Policies.NewsItem, policy, [@editor, %{}])
      refute apply(Policies.NewsItem, policy, [@host, %{}])
      assert apply(Policies.NewsItem, policy, [@admin, %{}])
    end
  end

  test "item logger can delete if it's not published" do
    refute Policies.NewsItem.delete(@editor, %{logger: @editor, status: :published})
    refute Policies.NewsItem.delete(@editor, %{logger: @admin, status: :draft})
    assert Policies.NewsItem.delete(@editor, %{logger: @editor, status: :draft})
    assert Policies.NewsItem.delete(@editor, %{logger: @editor, status: :queued})
  end
end
