defmodule Changelog.Policies.Admin.NewsItemTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.NewsItem

  test "only admins and editors can new/create" do
    refute NewsItem.create(@guest)
    refute NewsItem.new(@user)
    refute NewsItem.new(@host)
    assert NewsItem.create(@admin)
    assert NewsItem.new(@editor)
  end

  test "only admins and editors can get the index" do
    refute NewsItem.index(@guest)
    refute NewsItem.index(@user)
    refute NewsItem.index(@host)
    assert NewsItem.index(@admin)
    assert NewsItem.index(@editor)
  end

  test "only admins and item logger can edit/update" do
    refute NewsItem.edit(@guest, %{})
    refute NewsItem.update(@user, %{})
    refute NewsItem.update(@editor, %{})
    refute NewsItem.edit(@host, %{})
    assert NewsItem.update(@admin, %{})
    assert NewsItem.edit(@editor, %{logger: @editor})
  end

  test "only admins can move/decline/unpublish/delete" do
    for policy <- [:move, :decline, :unpublish, :delete] do
      refute apply(NewsItem, policy, [@guest, %{}])
      refute apply(NewsItem, policy, [@user, %{}])
      refute apply(NewsItem, policy, [@editor, %{}])
      refute apply(NewsItem, policy, [@host, %{}])
      assert apply(NewsItem, policy, [@admin, %{}])
    end
  end

  test "item logger can delete if it's not published" do
    refute NewsItem.delete(@editor, %{logger: @editor, status: :published})
    refute NewsItem.delete(@editor, %{logger: @admin, status: :draft})
    assert NewsItem.delete(@editor, %{logger: @editor, status: :draft})
    assert NewsItem.delete(@editor, %{logger: @editor, status: :queued})
  end
end
